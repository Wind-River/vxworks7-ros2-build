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
16sep24 akh - created
*/

#ifndef _FCNTL_UNIX
#define _FCNTL_UNIX

#ifdef __VXWORKS__
#include <../public/fcntl.h>
#else
#include <fcntl.h>
#endif

#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

int posix_fallocate(int fd, off_t offset, off_t len);

#ifdef __cplusplus
}
#endif
#endif /* _FCNTL_UNIX */
