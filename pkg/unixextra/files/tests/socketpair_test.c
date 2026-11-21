/* socketpair_test - socketpair() of unixextra, non-interactive

Usage: socketpair_test

unixextra's socketpair() returns a pair of connected stream sockets (over TCP
loopback; it implements SOCK_STREAM only, for event send/receive). Checks that
data sent on either end arrives, in order, on the other, and that closing one end
gives end-of-file on the other. Each case prints PASS/FAIL; the last line is
"UNIXEXTRA socketpair: PASS|FAIL". Exit status: number of failed cases.

[vxWorks *]# /bd0a/socketpair_test
...
UNIXEXTRA socketpair: PASS
*/

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

/* not declared by any SDK header: unixextra does not install one for it */
int socketpair(int domain, int type, int protocol, int sv[2]);

static int failed;

static void check(int ok, const char *what)
{
    printf("%s %s\n", ok ? "PASS" : "FAIL", what);
    if (!ok)
        failed++;
}

/* send msg on 'from', receive it completely on 'to' */
static int transfer(int from, int to, const char *msg)
{
    char buf[256];
    size_t n = strlen(msg), got = 0;
    ssize_t r;

    if (send(from, msg, n, 0) != (ssize_t)n)
        return 0;
    while (got < n) {
        r = recv(to, buf + got, n - got, 0);
        if (r <= 0)
            return 0;
        got += (size_t)r;
    }
    return memcmp(buf, msg, n) == 0;
}

int main(void)
{
    int sv[2] = {-1, -1}, i, ok = 1;
    char c;

    check(socketpair(AF_UNIX, SOCK_STREAM, 0, sv) == 0 && sv[0] >= 0 && sv[1] >= 0 && sv[0] != sv[1],
          "1 socketpair() returns two descriptors");
    if (sv[0] < 0 || sv[1] < 0) {
        printf("socketpair: %s\nUNIXEXTRA socketpair: FAIL\n", strerror(errno));
        return 1;
    }

    check(transfer(sv[0], sv[1], "ping 0 -> 1"), "2 data sent on sv[0] arrives on sv[1]");
    check(transfer(sv[1], sv[0], "pong 1 -> 0"), "3 data sent on sv[1] arrives on sv[0]");

    for (i = 0; i < 100 && ok; i++) {
        char msg[32];
        snprintf(msg, sizeof(msg), "event %03d;", i);
        ok = transfer(i % 2 ? sv[1] : sv[0], i % 2 ? sv[0] : sv[1], msg);
    }
    check(ok, "4 100 messages, alternating directions, in order");

    close(sv[0]);
    check(recv(sv[1], &c, 1, 0) == 0, "5 close sv[0]: end-of-file on sv[1]");
    close(sv[1]);

    printf("UNIXEXTRA socketpair: %s\n", failed ? "FAIL" : "PASS");
    return failed;
}
