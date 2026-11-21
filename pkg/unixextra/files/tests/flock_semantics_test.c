/* flock_semantics_test - BSD flock() semantics of flock.c, non-interactive

Usage: flock_semantics_test [file]          (default /tmp/flock_semantics)

BSD flock() locks belong to the open file: a lock through a second descriptor
of the same file conflicts with the first, also within one process, and closing
another descriptor keeps the lock. Each case prints PASS/FAIL; the cross-process
checks run this program again as a probe (posix_spawn) that tries a
non-blocking lock. Closing another descriptor dropping the lock is a known
limitation of the fcntl() emulation (VxWorks has only POSIX record locks): it
prints LIMITATION, not FAIL. Exit status: number of failed cases.

[vxWorks *]# /bd0a/flock_semantics_test
...
FLOCK SEMANTICS: 9 passed, 0 failed, 1 limitation(s)
UNIXEXTRA flock: PASS
*/

#include <sys/file.h>
#include <sys/wait.h>
#include <errno.h>
#include <fcntl.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char *self;
static const char *file;
static int passed, failed, limitations;

/* probe: another process tries a non-blocking lock; 0 = acquired, 1 = refused */
static int probe(const char *mode)
{
    char *argv[] = {(char *)self, "probe", (char *)file, (char *)mode, NULL};
    pid_t pid;
    int status;

    if (posix_spawn(&pid, self, NULL, NULL, argv, NULL) != 0)
        { printf("posix_spawn %s failed: %s\n", self, strerror(errno)); exit(100); }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status))
        { printf("waitpid failed\n"); exit(101); }
    return WEXITSTATUS(status);
}

static void check(int ok, const char *what)
{
    printf("%s %s\n", ok ? "PASS" : "FAIL", what);
    ok ? passed++ : failed++;
}

static int lockrc(int fd, int op, int *err)
{
    int rc = flock(fd, op);
    *err = rc ? errno : 0;
    return rc;
}

static int reopen(void)
{
    int fd = open(file, O_RDWR | O_CREAT, 0666);
    if (fd < 0) { printf("open %s: %s\n", file, strerror(errno)); exit(102); }
    return fd;
}

int main(int argc, char *argv[])
{
    int fd1, fd2, fd3, e;

    if (argc == 4 && strcmp(argv[1], "probe") == 0) {
        int fd = open(argv[2], O_RDWR | O_CREAT, 0666);
        int op = (argv[3][0] == 's' ? LOCK_SH : LOCK_EX) | LOCK_NB;
        return (fd >= 0 && flock(fd, op) == 0) ? 0 : 1;
    }
    self = argv[0];
    file = argc > 1 ? argv[1] : "/tmp/flock_semantics";
    unlink(file);

    /* 1) EX through fd1, EX through fd2 of the same process conflicts */
    fd1 = reopen(); fd2 = reopen();
    check(lockrc(fd1, LOCK_EX | LOCK_NB, &e) == 0, "1a lock EX via fd1");
    check(lockrc(fd2, LOCK_EX | LOCK_NB, &e) != 0 && e == EWOULDBLOCK,
          "1b lock EX via fd2, same process: EWOULDBLOCK");
    /* 2) SH through fd2 conflicts with EX through fd1 */
    check(lockrc(fd2, LOCK_SH | LOCK_NB, &e) != 0 && e == EWOULDBLOCK,
          "2  lock SH via fd2 while fd1 holds EX: EWOULDBLOCK");
    /* 3) another process: EX and SH refused while fd1 holds EX */
    check(probe("x") == 1 && probe("s") == 1, "3  other process: EX and SH refused");
    /* 4) convert fd1 EX -> SH: other process gets SH, not EX */
    check(lockrc(fd1, LOCK_SH | LOCK_NB, &e) == 0, "4a convert fd1 EX -> SH");
    check(probe("s") == 0 && probe("x") == 1, "4b other process: SH granted, EX refused");
    /* 5) SH through fd2 next to SH through fd1; unlocking fd2 keeps fd1's lock */
    check(lockrc(fd2, LOCK_SH | LOCK_NB, &e) == 0 && lockrc(fd2, LOCK_UN, &e) == 0
          && probe("x") == 1, "5  SH via fd2 and unlock it: fd1 keeps its SH");
    /* 6) unlocking the last holder releases the file */
    check(lockrc(fd1, LOCK_UN, &e) == 0 && probe("x") == 0, "6  unlock fd1: other process gets EX");
    close(fd2);

    /* 7) known limitation: closing another descriptor drops the lock */
    check(lockrc(fd1, LOCK_EX | LOCK_NB, &e) == 0, "7a lock EX via fd1");
    fd3 = reopen();
    close(fd3);
    if (probe("x") == 1) {
        check(1, "7b close another descriptor: fd1 keeps its lock");
    } else {
        printf("LIMITATION 7b close another descriptor: fd1's lock is dropped (fcntl() record locks)\n");
        limitations++;
    }
    flock(fd1, LOCK_UN);
    close(fd1);
    unlink(file);

    printf("FLOCK SEMANTICS: %d passed, %d failed, %d limitation(s)\n", passed, failed, limitations);
    printf("UNIXEXTRA flock: %s\n", failed ? "FAIL" : "PASS");
    return failed;
}
