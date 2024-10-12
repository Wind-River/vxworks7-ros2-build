/* fcntl.h standard header extensions for UNIX compatibility */

/*
 * Copyright (c) 2024 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this software
 * may be licensed only pursuant to the terms of an applicable Wind River
 * license agreement.
 */

/*
modification history
--------------------
16sep24 akh - created
*/

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

int posix_fallocate(int fd, off_t offset, off_t len) {
    /* Move file pointer to the desired offset */
    if (lseek(fd, offset + len - 1, SEEK_SET) == -1) {
        return errno;
    }

    /* Write a single byte at the end of the allocated range to ensure spacea */
    if (write(fd, "", 1) != 1) {
        return errno;
    }

    return 0;
}
