/* vdprintf_test - vdprintf() of unixextra, non-interactive

Usage: vdprintf_test

vdprintf() formats like vprintf() but writes to a file descriptor. Formats into a
pipe and checks the bytes written and the return value (the number of bytes,
as printf()). Each case prints PASS/FAIL; the last line is
"UNIXEXTRA vdprintf: PASS|FAIL". Exit status: number of failed cases.

[vxWorks *]# /bd0a/vdprintf_test
...
UNIXEXTRA vdprintf: PASS
*/

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

/* not declared by any SDK header: unixextra does not install one for it */
int vdprintf(int fd, const char *fmt, va_list ap);

static int failed;

static void check(int ok, const char *what)
{
    printf("%s %s\n", ok ? "PASS" : "FAIL", what);
    if (!ok)
        failed++;
}

static int to_fd(int fd, const char *fmt, ...)
{
    va_list ap;
    int n;

    va_start(ap, fmt);
    n = vdprintf(fd, fmt, ap);
    va_end(ap);
    return n;
}

/* format into a pipe; the result must equal 'want' and the return value its length */
static int formats(const char *want, const char *fmt, ...)
{
    int p[2], n;
    char buf[512];
    ssize_t got;
    va_list ap;

    if (pipe(p) != 0)
        return 0;
    va_start(ap, fmt);
    n = vdprintf(p[1], fmt, ap);
    va_end(ap);
    close(p[1]);
    got = read(p[0], buf, sizeof(buf) - 1);
    close(p[0]);
    if (got < 0)
        return 0;
    buf[got] = '\0';
    if (strcmp(buf, want) != 0 || n != (int)strlen(want)) {
        printf("    got \"%s\" (returned %d), want \"%s\" (%d)\n", buf, n, want, (int)strlen(want));
        return 0;
    }
    return 1;
}

int main(void)
{
    char big[301];

    check(formats("hello", "hello"), "1 plain text");
    check(formats("42 -7 ff 0x1f", "%d %i %x %#x", 42, -7, 255, 31), "2 integers");
    check(formats("[abc  ] [  xyz]", "[%-5s] [%5s]", "abc", "xyz"), "3 strings, width and alignment");
    check(formats("3.14 2.500e+00", "%.2f %.3e", 3.14159, 2.5), "4 floating point");
    check(formats("100%", "%d%%", 100), "5 literal %");
    check(formats("", "%s", ""), "6 empty output: returns 0");
    memset(big, 'x', 300);
    big[300] = '\0';
    check(formats(big, "%s", big), "7 300-byte output");
    check(to_fd(-1, "x") < 0, "8 bad descriptor: returns a negative value");

    printf("UNIXEXTRA vdprintf: %s\n", failed ? "FAIL" : "PASS");
    return failed;
}
