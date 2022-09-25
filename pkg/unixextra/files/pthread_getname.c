/* pthread_getname_np */

/*
 * Copyright 2022 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
07aug22,akh  created.
*/

#ifdef __VXWORKS__
#include <pthread.h>
#include <string.h>
#include <taskLib.h>
#include <private/taskLibP.h>
#include <private/pthreadLibP.h>

#define PTHREAD_TO_NATIVE_TASK(thId)     (((pthreadCB *)(thId))->vxTaskId)
#else
#include "pthread.h"
#endif

int pthread_getname_np (pthread_t thread, const char* name, size_t len)
{
#ifdef __VXWORKS__
    char * tn;

    tn = taskName(PTHREAD_TO_NATIVE_TASK (thread));
    strncpy(name, tn, len);
#endif
    return 0;
}
