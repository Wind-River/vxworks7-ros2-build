/* POSIX advisory locking test
 * bundle HRFS
 * INCLUDE_HRFS_FORMAT
 * INCLUDE_HRFS_ACCESS_TIMESTAMP
 * INCLUDE_XBD_RAMDRV
 * INCLUDE_XBD_PART_LIB
 * INCLUDE_POSIX_ADVISORY_FILE_LOCKING
 *
 * INCLUDE_IPIFCONFIG_CMD
 * INCLUDE_IPTELNETS
 *
 * -> cmd
 * [vxWorks *]# ifconfig gei0 192.168.0.1
 *
 * [vxWorks *]# C xbdRamDiskDevCreate (512, 512*2000, 0, "/tmp")
 * [vxWorks *]# C hrfsFormat ("/tmp", 0ll, 0, 1000)
 * [vxWorks *]# echo stamp > /tmp/stamp
 * [vxWorks *]# cd /romfs
 *
 * exclusive write lock
 * [vxWorks *]# test_adv_lock.vxe
 *
 * or blocking|non-blocking read lock
 * [vxWorks *]# test_adv_lock.vxe [r|rn]
 *
 * or blocking|non-blocking write lock
 * [vxWorks *]# test_adv_lock.vxe [w|wn]
 *
 * telnet 192.168.0.1
 * -> cmd
 * [vxWorks *]# cd /romfs
 * [vxWorks *]# test_adv_lock.vxe
 * */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#ifdef __VXWORKS__
#include <sys/fcntlcom.h>
#endif
#include <fcntl.h>

int main (
    int	   argc,	/* number of arguments */
    char * argv[]	/* array of arguments */
    ) {
	int fd, cmd = F_SETLKW, rc;
	struct flock fl = {0};
	const char *fname = "/tmp/stamp";

    fl.l_type   = F_WRLCK;  /* F_RDLCK, F_WRLCK, F_UNLCK    */
    fl.l_whence = SEEK_SET; /* SEEK_SET, SEEK_CUR, SEEK_END */
    fl.l_start  = 0;        /* Offset from l_whence         */
    fl.l_len    = 0;        /* length, 0 = to EOF           */
//    fl.l_pid    = getpid(); /* our PID                      */

    if (argc == 1)
        fd = open (fname, O_RDWR);

    if (argc > 1)
        {
        if (argv[1][0] == 'r' || argv[1][0] == 'w')
            {
            fl.l_type = (argv[1][0] == 'r')?F_RDLCK:F_WRLCK;
            fd = open (fname, (argv[1][0] == 'r')?O_RDONLY:O_RDWR);
            cmd = (argv[1][1] == 'n')?F_SETLK:F_SETLKW;
            }
        else
            {
            if (argc > 2)
                {
                if (argv[2][0] == 'r' || argv[2][0] == 'w')
                    {
                    fl.l_type = (argv[2][0] == 'r')?F_RDLCK:F_WRLCK;
                    fd = open (fname, (argv[2][0] == 'r')?O_RDONLY:O_RDWR);
                    cmd = (argv[2][1] == 'n')?F_SETLK:F_SETLKW;
                    }
                }
            else
                fd = open (argv[1], O_RDWR);
            }
        }

    if (fd == -1 )
        { printf ("open failed with %d\n", errno); exit (-1);}

    printf ("Press <RETURN> to acquire a %s %slock on %s ... ",
        (fl.l_type == F_RDLCK)?"read":"write", (cmd == F_SETLK)?"non-blocking ":"", fname);
    fflush(stdout);
    getchar();

    rc = fcntl(fd, cmd, &fl);  /* F_GETLK, F_SETLK, F_SETLKW */
    if (rc == -1 ) {
        printf ("fcntl failed to lock %s with %d\n", fname, errno);
        exit (-1);
    }
    printf ("done\n");
    fflush(stdout);

    printf ("Press <RETURN> to release lock on %s ... ", fname);
    fflush(stdout);
    getchar();

    fl.l_type   = F_UNLCK;  /* F_RDLCK, F_WRLCK, F_UNLCK    */
    rc = fcntl(fd, F_SETLK, &fl);  /* F_GETLK, F_SETLK, F_SETLKW */
    if (rc == -1 ) {
        printf ("fcntl failed to unlock %s with %d\n", fname, errno);
        exit (-1);
    }
    printf ("done\n");
    fflush(stdout);

    close (fd);
    return 0;
}
