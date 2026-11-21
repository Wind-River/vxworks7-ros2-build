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
20nov26, akh  prout: return the descriptor, not write()'s byte count: _Printf
              passes the callback's result back as its argument (NULL = error),
              so every format with more than one output piece crashed
14mar20, akh  created
*/

#include <unistd.h>
#ifdef __VXWORKS__
#include "xstdio.h"
#else
#include <stdarg.h>
#endif

/* _Printf output function: write a piece to the descriptor at *fd; return the
 * argument for the next piece (fd itself), or NULL on error */
static void *prout(void *fd , const char *buf, size_t n)
{
	return (write(*(int *)fd, buf, n) == (ssize_t)n ? fd : NULL);
}

int vdprintf(int fd, const char *restrict fmt, va_list ap)
{
        int ans;

	ans = _Printf(&prout, (void *)&fd, fmt, ap, 0);
	return (ans);

}
