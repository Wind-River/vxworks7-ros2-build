/* fcntl.h standard header extensions for UNIX compatibility */

/*
 * Copyright (c) 2024 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this software
 * may be licensed only pursuant to the terms of an applicable Wind River
 * license agreement.
 */

/*
modification history
--------------------
20nov26 akh - POSIX semantics: EINVAL for len <= 0 or offset < 0, never change
              existing contents or shrink the file, keep the file offset
16sep24 akh - created
*/

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>

/*
 * posix_fallocate - ensure that storage for [offset, offset + len) is allocated
 *
 * Extends the file to offset + len if it is shorter, by writing one zero byte at
 * the new last offset; a range inside the file changes nothing (its blocks are
 * allocated already). Never changes existing contents, never shrinks the file,
 * and leaves the descriptor's file offset as it was. Returns 0 or an error number
 * (errno is not set): EINVAL for len <= 0 or offset < 0, EBADF, EFBIG, or the
 * error of fstat()/lseek()/write().
 */
int posix_fallocate(int fd, off_t offset, off_t len) {
    struct stat st;
    off_t end, cur;
    int err;

    if (offset < 0 || len <= 0)
        return EINVAL;
    if (offset > (off_t)(~(unsigned long long)0 >> 1) - len)
        return EFBIG;                   /* offset + len overflows off_t */
    end = offset + len;

    if (fstat(fd, &st) != 0)
        return errno;
    if (end <= st.st_size)
        return 0;                       /* inside the file: nothing to do */

    if ((cur = lseek(fd, 0, SEEK_CUR)) == -1)
        return errno;
    err = 0;
    if (lseek(fd, end - 1, SEEK_SET) == -1 || write(fd, "", 1) != 1)
        err = errno ? errno : EIO;
    (void)lseek(fd, cur, SEEK_SET);     /* keep the file offset */
    return err;
}
