/* string.h standard header extensions for UNIX compatibility */

/*
 * Copyright (c) 2019 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this software
 * may be licensed only pursuant to the terms of an applicable Wind River
 * license agreement.
 */

/*
modification history
--------------------
13jun19 akh - created
*/

#ifndef _STRING_UNIX
#define _STRING_UNIX

#ifdef __VXWORKS__
#include <../public/string.h>
#else
#include <string.h>
#include <stddef.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

void *memccpy(void *t, const void *f, int c, size_t n);

#ifdef __cplusplus
}
#endif
#endif /* _STRING_UNIX */
