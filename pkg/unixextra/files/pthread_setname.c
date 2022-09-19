/* pthread_setname_np */

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

int pthread_setname_np (pthread_t thread, const char* name)
{
#ifdef __VXWORKS__
    WIND_TCB *pTcb;

    taskTcbGet(PTHREAD_TO_NATIVE_TASK (thread), &pTcb);
    strncpy(pTcb->user.pName, name, strlen(name)<16?strlen(name)+1:15);
#endif
    return 0;
}
