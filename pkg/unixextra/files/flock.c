/*	$NetBSD: flock.c,v 1.6 2008/04/28 20:24:12 martin Exp $	*/

/*-
 * Copyright (c) 2001 The NetBSD Foundation, Inc.
 * All rights reserved.
 *
 * This code is derived from software contributed to The NetBSD Foundation
 * by Todd Vierling.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Emulate flock() with fcntl(), where available.
 * Otherwise, don't do locking; just pretend success.
 *
 * VxWorks has no flock() and no descriptor-owned locks (F_OFD_SETLK), only
 * POSIX fcntl() record locks, which belong to the PROCESS. BSD flock() locks
 * belong to the open file: a lock through a second descriptor of the same
 * file conflicts with the first, also within one process. To give that back,
 * this keeps a per-process table of the descriptors holding a flock() on each
 * file (dev, ino):
 *
 *   - LOCK_EX through one descriptor conflicts with any lock through another
 *     descriptor of the file in this process; LOCK_SH conflicts with LOCK_EX.
 *     The conflict is reported as with BSD flock(): EWOULDBLOCK with LOCK_NB;
 *     without LOCK_NB EDEADLK (BSD would wait forever on itself).
 *   - The process' fcntl() lock is taken when the first descriptor locks the
 *     file and released when the last one unlocks it (an fcntl() unlock would
 *     drop the lock of every descriptor at once).
 *   - Between processes, fcntl() decides as before (F_SETLK / F_SETLKW).
 *
 * NOT emulated (VxWorks limitation, POSIX fcntl() semantics): closing ANY
 * descriptor of a file drops all fcntl() locks the process holds on it, also
 * the flock() of another descriptor. Code that opens and closes a second
 * descriptor of a file it holds locked loses the lock (BSD flock() keeps it).
 * Table entries of descriptors closed without LOCK_UN are dropped when the
 * file is next flock()ed.
 */

#include <sys/file.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <sched.h>
#include <stdatomic.h>
#include <stdlib.h>
#include <unistd.h>

#define FLOCK_MAX_HOLDERS 16

struct flock_holder {
	int fd;
	int type;			/* LOCK_SH or LOCK_EX */
};

struct flock_file {
	struct flock_file *next;
	dev_t dev;
	ino_t ino;
	int n;
	struct flock_holder h[FLOCK_MAX_HOLDERS];
};

/* guards the table; held only for table updates, never across a blocking
 * fcntl(). (Not a pthread mutex: unixextra's own pthread.h shim is first on
 * the include path.) */
static atomic_flag flock_busy = ATOMIC_FLAG_INIT;
static struct flock_file *flock_files;

static void
flock_table_lock(void)
{
	while (atomic_flag_test_and_set_explicit(&flock_busy, memory_order_acquire))
		sched_yield();
}

static void
flock_table_unlock(void)
{
	atomic_flag_clear_explicit(&flock_busy, memory_order_release);
}

static struct flock_file *
flock_find(dev_t dev, ino_t ino, int create)
{
	struct flock_file *f;

	for (f = flock_files; f != NULL; f = f->next)
		if (f->dev == dev && f->ino == ino)
			return f;
	if (!create || (f = calloc(1, sizeof(*f))) == NULL)
		return NULL;
	f->dev = dev;
	f->ino = ino;
	f->next = flock_files;
	flock_files = f;
	return f;
}

/* drop holders whose descriptor was closed (or reused for another file) */
static void
flock_prune(struct flock_file *f)
{
	struct stat st;
	int i;

	for (i = 0; i < f->n; ) {
		if (fstat(f->h[i].fd, &st) != 0 ||
		    st.st_dev != f->dev || st.st_ino != f->ino)
			f->h[i] = f->h[--f->n];
		else
			i++;
	}
}

static int
flock_holder_of(struct flock_file *f, int fd)
{
	int i;

	for (i = 0; i < f->n; i++)
		if (f->h[i].fd == fd)
			return i;
	return -1;
}

static int
flock_fcntl(int fd, int type, int wait)
{
	struct flock fl = {0};
	int rc;

	fl.l_type = (short)type;
	fl.l_whence = SEEK_SET;
	rc = fcntl(fd, wait ? F_SETLKW : F_SETLK, &fl);
	if (rc && (errno == EAGAIN || errno == EACCES))
		errno = EWOULDBLOCK;
	return rc;
}

int
flock(int fd, int op)
{
	struct flock_file *f;
	struct stat st;
	int want, nb, me, i, others_sh = 0, others_ex = 0, prev, rc, saved;

	switch (op & (LOCK_EX|LOCK_SH|LOCK_UN)) {
	case LOCK_EX:
	case LOCK_SH:
	case LOCK_UN:
		want = op & (LOCK_EX|LOCK_SH|LOCK_UN);
		break;
	default:
		errno = EINVAL;
		return -1;
	}
	nb = op & LOCK_NB;

	if (fstat(fd, &st) != 0)
		return -1;			/* EBADF */

	flock_table_lock();
	f = flock_find(st.st_dev, st.st_ino, want != LOCK_UN);
	if (f == NULL) {
		flock_table_unlock();
		if (want == LOCK_UN)
			return 0;		/* nothing locked on this file */
		errno = ENOLCK;
		return -1;
	}
	flock_prune(f);
	me = flock_holder_of(f, fd);

	if (want == LOCK_UN) {
		if (me >= 0) {
			f->h[me] = f->h[--f->n];
			if (f->n == 0)		/* last holder: release it */
				(void)flock_fcntl(fd, F_UNLCK, 0);
		}
		flock_table_unlock();
		return 0;
	}

	for (i = 0; i < f->n; i++) {
		if (i == me)
			continue;
		if (f->h[i].type == LOCK_EX)
			others_ex++;
		else
			others_sh++;
	}
	if (others_ex || (want == LOCK_EX && others_sh)) {
		/* conflicts with another descriptor of this process */
		flock_table_unlock();
		errno = nb ? EWOULDBLOCK : EDEADLK;
		return -1;
	}

	if (others_sh) {
		/* LOCK_SH next to other shared holders: the process already
		 * holds the fcntl() read lock */
		if (me < 0) {
			if (f->n == FLOCK_MAX_HOLDERS) {
				flock_table_unlock();
				errno = ENOLCK;
				return -1;
			}
			me = f->n++;
			f->h[me].fd = fd;
		}
		f->h[me].type = LOCK_SH;
		flock_table_unlock();
		return 0;
	}

	/* only holder (or none): take / convert the process' fcntl() lock.
	 * Record it first, so other threads see the conflict while fcntl()
	 * may block without the table lock. */
	prev = 0;
	if (me < 0) {
		if (f->n == FLOCK_MAX_HOLDERS) {
			flock_table_unlock();
			errno = ENOLCK;
			return -1;
		}
		me = f->n++;
		f->h[me].fd = fd;
	} else
		prev = f->h[me].type;
	f->h[me].type = want;
	flock_table_unlock();

	rc = flock_fcntl(fd, want == LOCK_EX ? F_WRLCK : F_RDLCK, !nb);
	if (rc == 0)
		return 0;

	saved = errno;
	flock_table_lock();
	me = flock_holder_of(f, fd);
	if (me >= 0) {
		if (prev)			/* a failed conversion keeps the old lock */
			f->h[me].type = prev;
		else
			f->h[me] = f->h[--f->n];
	}
	flock_table_unlock();
	errno = saved;
	return -1;
}
