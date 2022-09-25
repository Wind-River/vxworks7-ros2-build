/* flock_test - test program for flock
 *
 */

#include <sys/file.h>
#include <fcntl.h>
#include <errno.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

int main (
    int	   argc,	/* number of arguments */
    char * argv[]	/* array of arguments */
    )
{
    int fd, lock = LOCK_EX;
	const char *fname = "/tmp/stamp";

	/* parse input parameters
	 * flock_test [filename] [lock_opt:sn]
	 */
    if (argc > 1)
        if (argv[1][0] == 's' || argv[1][1] == 'n')
        {
            lock = (argv[1][0] == 's') ? LOCK_SH : LOCK_EX;
            lock |= (argv[1][1] == 'n') ? LOCK_NB : 0;
            fd = open (fname, O_RDWR);
        }
        else
            fd = open (argv[1], O_RDWR);
    else
        fd = open (fname, O_RDWR);

    if (fd == -1 )
        { printf ("open %s failed with %d\n", fname, errno); exit (-1);}

    if (argc > 2)
        if (argv[2][0] == 's' || argv[2][1] == 'n')
        {
            lock = (argv[2][0] == 's') ? LOCK_SH : LOCK_EX;
            lock |= (argv[2][1] == 'n') ? LOCK_NB : 0;
        }

    printf ("Press <RETURN> to acquire %s %s lock on %s ... ",
        (lock & LOCK_EX)?"an exclusive":"a shared", (lock & LOCK_NB)?"(non-blocking)":"", fname);
    fflush(stdout);
    getchar();

    if (flock(fd, lock) == -1) {
        if (errno == EWOULDBLOCK)
           {printf("file %s already locked\n", fname);exit(-1);}
    }

    printf ("done\n");
    fflush(stdout);

    printf ("Press <RETURN> to release lock on %s ... ", fname);
    fflush(stdout);
    getchar();

    if (flock(fd, LOCK_UN) == -1)
        {printf("unflock %s failed", fname);exit(-1);}

    printf ("done\n");
    fflush(stdout);

    close (fd);
    return 0;
}
