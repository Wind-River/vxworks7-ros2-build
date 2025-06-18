/* flock_test - test program for flock

Usage: ./flock_test <filename> <sn>
       ./flock_test <sn>
       ./flock_test

[vxWorks *]# echo "" > /tmp/stamp

Example usages:
"sn" — shared, non-blocking lock (LOCK_SH | LOCK_NB)
"s"  — shared, blocking lock (LOCK_SH)
"xn" — exclusive, non-blocking (LOCK_EX | LOCK_NB)
"x"  — exclusive, blocking (LOCK_EX)

# exclusive, blocking example

Terminal 1:
[vxWorks *]# /bd0a/flock_test
Launching process '/bd0a/flock_test' ...
Process '/bd0a/flock_test' (process Id = 0xffff8000003fe580) launched.
Press <RETURN> to acquire an exclusive (blocking) lock on /tmp/stamp ... 
done

Terminal 2:
[vxWorks *]# /bd0a/flock_test
Launching process '/bd0a/flock_test' ...
Process '/bd0a/flock_test' (process Id = 0xffff8000003fb8d0) launched.
Press <RETURN> to acquire an exclusive (blocking) lock on /tmp/stamp ... 

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
    char *fname = "/tmp/stamp";

    /* parse input parameters
     * flock_test [filename] [lock_opt:sn] */

    if (argc > 1)
    {
        if (argv[1][0] == 's' || argv[1][1] == 'n')
        {
            lock = (argv[1][0] == 's') ? LOCK_SH : LOCK_EX;
            lock |= (argv[1][1] == 'n') ? LOCK_NB : 0;
        }
        else
        {
            fname = argv[1];
            if (argv[2][0] == 's' || argv[2][1] == 'n')
            {
                lock = (argv[2][0] == 's') ? LOCK_SH : LOCK_EX;
                lock |= (argv[2][1] == 'n') ? LOCK_NB : 0;
            }
        }
    }

    fd = open (fname, O_RDWR);
    if (fd == -1 )
    {
        printf("open %s failed with %d (%s)\n", fname, errno, strerror(errno));
        if(errno == ENOENT)
            printf("Create it first: [vxWorks *]# echo > %s\n", fname);
        exit (-1);
    }

    if (argc > 2)
        if (argv[2][0] == 's' || argv[2][1] == 'n')
        {
            lock = (argv[2][0] == 's') ? LOCK_SH : LOCK_EX;
            lock |= (argv[2][1] == 'n') ? LOCK_NB : 0;
        }

    printf ("Press <RETURN> to acquire %s %s lock on %s ... ",
        (lock & LOCK_EX)?"an exclusive":"a shared", (lock & LOCK_NB)?"(non-blocking)":"(blocking)", fname);
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
