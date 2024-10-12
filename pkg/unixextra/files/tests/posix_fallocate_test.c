#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>

/*
 * ls -la /tmp/testfile.dat
 */

int main() {
    const char *filename = "/tmp/testfile.dat";
    int fd;
    off_t length = 1024 * 1024; /* Allocate 1 MB */
    struct stat st;

    /* Open a file for read and write, create it if it doesn't exist */
    fd = open(filename, O_RDWR | O_CREAT, 0666);
    if (fd == -1) {
        perror("Failed to open file");
        return EXIT_FAILURE;
    }

    /* Allocate space for the file */
    int ret = posix_fallocate(fd, 0, length);
    if (ret != 0) {
        errno = ret;
        perror("posix_fallocate failed");
        close(fd);
        return EXIT_FAILURE;
    }

    /* Check the file size using fstat */
    if (fstat(fd, &st) == -1) {
        perror("fstat failed");
        close(fd);
        return EXIT_FAILURE;
    }

    printf("File size after allocation: %ld bytes\n", st.st_size);

    if (st.st_size == length) {
        printf("Space successfully allocated.\n");
    } else {
        printf("Space allocation failed.\n");
    }

    /* Close the file */
    close(fd);
    return EXIT_SUCCESS;
}
