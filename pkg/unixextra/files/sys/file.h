/* sys/file.h standard header extensions for UNIX compatibility */

/*
 * Copyright (c) 2021 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this software
 * may be licensed only pursuant to the terms of an applicable Wind River
 * license agreement.
 */

/*
modification history
--------------------
13dec21 akh - created
*/

#ifndef _SYS_FILE_UNIX
#define _SYS_FILE_UNIX

/* Operations for the flock call. */
#define        LOCK_SH        1
#define        LOCK_EX        2
#define        LOCK_UN        8
#define        LOCK_NB        4

#ifdef __cplusplus
extern "C" {
#endif

int flock (int fd, int op);

#ifdef __cplusplus
}
#endif
#endif
