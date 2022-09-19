/* vdprintf.c - vdprintf implementaion extensions for UNIX compatibility */

/*
 * Copyright (c) 2020 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this software
 * may be licensed only pursuant to the terms of an applicable Wind River
 * license agreement.
 */

/*
modification history
--------------------
14mar20, akh  created
*/

#include <unistd.h>
#ifdef __VXWORKS__
#include "xstdio.h"
#else
#include <stdarg.h>
#endif

static void *prout(void *fd , const char *buf, size_t n)
{
	return (write(*(int*)fd, buf, n));
}

int vdprintf(int fd, const char *restrict fmt, va_list ap)
{
        int ans;

	ans = _Printf(&prout, (void *)&fd, fmt, ap, 0);
	return (ans);

}
