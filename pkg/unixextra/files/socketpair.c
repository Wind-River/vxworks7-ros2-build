/* socketpair */

/*
 * Copyright 2019 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
07dec20,akh  updated.
09dec19,yat  created.
*/

#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

/*******************************************************************************
*
* socketpair - create a pair of connected sockets
*
* The socketpair() function creates an unbound pair of connected sockets in a
* specified domain, of a specified type, under the protocol optionally specified
* by the protocol argument. The file descriptors used in referencing the
* created sockets be returned in socket_vector[0] and socket_vector[1].
*
* Note: we only need socketpair() to send/receive events.
*       This function only implements streaming.
*/

int socketpair
    (
    int domain,
    int type,
    int protocol,
    int sv[2]
    )
    {
    struct addrinfo * res = NULL;
    struct addrinfo   hints;
    int               ret;
    int               listenSock  = -1;
    int               connectSock = -1;
    int               acceptSock  = -1;
    socklen_t         addrlen;

    (void) memset (&hints, 0, sizeof(hints));
    hints.ai_family   = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    ret = getaddrinfo(NULL, "0", &hints, &res);
    if (ret < 0)
        goto fail;
    listenSock = socket(res->ai_family, SOCK_STREAM, res->ai_protocol);
    if (listenSock == -1)
        goto fail;

    connectSock = socket(res->ai_family, SOCK_STREAM, res->ai_protocol);
    if (connectSock == -1)
        goto fail;

    /* Bind to an ephemeral port */
    if (bind(listenSock, res->ai_addr, (socklen_t) res->ai_addrlen) != 0)
        goto fail;

    addrlen = (socklen_t) res->ai_addrlen;

    if (getsockname(listenSock, res->ai_addr, &addrlen) != 0)
        goto fail;

    if (listen(listenSock, 1) != 0)
        goto fail;

    if (connect(connectSock, res->ai_addr, (socklen_t) res->ai_addrlen) != 0)
        goto fail;

    acceptSock = accept(listenSock, NULL, NULL);
    if (acceptSock == -1)
        goto fail;

    sv[0] = connectSock;
    sv[1] = acceptSock;
    close (listenSock);
    freeaddrinfo(res);
    return 0;
fail:
    if (res != NULL)
        freeaddrinfo(res);
    if (listenSock != -1)
        close (listenSock);
    if (connectSock != -1)
        close (connectSock);
    return -1;
    }
