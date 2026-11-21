/* posix_fallocate_test - posix_fallocate() of unixextra, non-interactive

Usage: posix_fallocate_test [file]          (default /tmp/posix_fallocate_test.dat)

Checks posix_fallocate() against POSIX: it extends a file to offset + len, never
changes existing contents, never shrinks the file, and fails with EINVAL for
len <= 0 or offset < 0 (it returns the error, it does not set errno). Each case
prints PASS/FAIL; the last line is "UNIXEXTRA posix_fallocate: PASS|FAIL".
Exit status: number of failed cases.

[vxWorks *]# /bd0a/posix_fallocate_test
...
UNIXEXTRA posix_fallocate: PASS
*/

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static int failed;

static void check(int ok, const char *what)
{
    printf("%s %s\n", ok ? "PASS" : "FAIL", what);
    if (!ok)
        failed++;
}

static off_t size_of(int fd)
{
    struct stat st;
    return fstat(fd, &st) == 0 ? st.st_size : -1;
}

/* the file still starts with "ABCDEFGH" (lseek + read: no pread() on VxWorks) */
static int contents_kept(int fd)
{
    char buf[8];
    return lseek(fd, 0, SEEK_SET) == 0 && read(fd, buf, sizeof(buf)) == (ssize_t)sizeof(buf)
           && memcmp(buf, "ABCDEFGH", 8) == 0;
}

int main(int argc, char *argv[])
{
    const char *file = argc > 1 ? argv[1] : "/tmp/posix_fallocate_test.dat";
    const off_t mb = 1024 * 1024;
    int fd;

    unlink(file);
    fd = open(file, O_RDWR | O_CREAT | O_TRUNC, 0666);
    if (fd < 0) {
        printf("open %s: %s\nUNIXEXTRA posix_fallocate: FAIL\n", file, strerror(errno));
        return 1;
    }

    /* 1) extend an empty file */
    check(posix_fallocate(fd, 0, mb) == 0 && size_of(fd) == mb, "1 extend an empty file to 1 MiB");

    /* 2) extend beyond the end from an offset */
    check(posix_fallocate(fd, mb, 4096) == 0 && size_of(fd) == mb + 4096,
          "2 extend from offset 1 MiB by 4 KiB");

    /* 3) a range inside the file changes neither size nor contents */
    if (lseek(fd, 0, SEEK_SET) != 0 || write(fd, "ABCDEFGH", 8) != 8) {
        printf("write: %s\nUNIXEXTRA posix_fallocate: FAIL\n", strerror(errno));
        return 1;
    }
    check(posix_fallocate(fd, 0, 4) == 0 && size_of(fd) == mb + 4096 && contents_kept(fd),
          "3 range inside the file: size and contents kept");

    /* 4) a range starting inside, ending beyond: extends, contents kept */
    check(posix_fallocate(fd, 4, mb + 8192) == 0 && size_of(fd) == mb + 8196 && contents_kept(fd),
          "4 range from inside to beyond the end: extends, contents kept");

    /* 5) invalid arguments: EINVAL, file unchanged */
    check(posix_fallocate(fd, 0, 0) == EINVAL && posix_fallocate(fd, 16, 0) == EINVAL
          && posix_fallocate(fd, 0, -1) == EINVAL && posix_fallocate(fd, -1, 16) == EINVAL
          && size_of(fd) == mb + 8196 && contents_kept(fd),
          "5 len <= 0 or offset < 0: EINVAL, file unchanged");

    /* 6) a bad descriptor: EBADF */
    check(posix_fallocate(-1, 0, 16) == EBADF, "6 bad descriptor: EBADF");

    close(fd);
    unlink(file);

    printf("UNIXEXTRA posix_fallocate: %s\n", failed ? "FAIL" : "PASS");
    return failed;
}
