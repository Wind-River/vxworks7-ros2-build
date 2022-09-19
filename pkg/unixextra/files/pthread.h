/* pthread.h standard header extensions for UNIX compatibility */

/*
 * Copyright (c) 2022 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this software
 * may be licensed only pursuant to the terms of an applicable Wind River
 * license agreement.
 */

/*
modification history
--------------------
07aug22 akh - created
*/

#ifndef _PTHREAD_UNIX
#define _PTHREAD_UNIX

#ifdef __VXWORKS__
#include <../public/pthread.h>
#else
#include <bits/pthreadtypes.h>
#include <stddef.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

int pthread_getname_np (pthread_t thread, const char* name, size_t len);
int pthread_setname_np (pthread_t thread, const char* name);

#ifdef __cplusplus
}
#endif
#endif /* _PTHREAD_UNIX */
