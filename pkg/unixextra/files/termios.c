/* termios.c - termios implementaion extensions for UNIX compatibility */

/*
 * Copyright (c) 2019-2020 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this software
 * may be licensed only pursuant to the terms of an applicable Wind River
 * license agreement.
*/

/*
modification history
--------------------
13mar20, akh  added copyright
05jul19, tde  modified
06apr19, akh  created
*/

#include <vxWorks.h>
#include <ioLib.h>
#include <sioLib.h>
#include <termios.h>

int
cfsetospeed(struct termios *t, speed_t speed)
{

        t->c_ospeed = speed;
        return (0);
}
speed_t
cfgetospeed(struct termios *t)
{
        return (t->c_ospeed);
}

int
cfsetispeed(struct termios *t, speed_t speed)
{

        t->c_ispeed = speed;
        return (0);
}

int
tcgetattr(int fd, struct termios *t)
{
        int ret;
        int options = 0;

        options = ioctl(fd, FIOGETOPTIONS, NULL);

        if (options == ERROR)
            return ret;

        t->c_iflag = 0;
        t->c_oflag = 0;
        t->c_lflag = 0;
        if (options & OPT_ECHO)
            t->c_lflag |= ECHO;

        if (options & OPT_LINE)
            t->c_lflag |= ICANON;

        if ( options & OPT_CRMOD) {
            t->c_oflag |= ONLCR;
		    t->c_iflag |= ICRNL;
		    /*t->c_iflag |= INLCR;
		    t->c_iflag |= IGNCR;*/
        }

        if ( options & OPT_TANDEM) {
            t->c_iflag |= IXOFF;
		    t->c_iflag |= IXON;
        }

        ret = ioctl(fd, SIO_HW_OPTS_GET, &t->c_cflag);
        if (ret ==  0)
                ret = ioctl(fd, SIO_BAUD_GET, &t->c_ospeed);
        return (ret);
}

int
tcsetattr(int fd, int opt, const struct termios *t)
{
        int ret;
        int options;

        /* translation needed between termios flags and vxWorks OPT_XXX flags */
        options = 0;

        if (t->c_lflag & ECHO)
            options |= OPT_ECHO;

        if (t->c_lflag & ICANON)
            options |= OPT_LINE;

        if ((t->c_iflag & ICRNL) || (t->c_oflag & ONLCR))
            options |= OPT_CRMOD;

        if (t->c_iflag & IGNCR)
            options &= ~OPT_CRMOD;

        if ((t->c_iflag & IXOFF) || (t->c_iflag & IXON))
            options |= OPT_TANDEM;

        if ((options & (OPT_ECHO | OPT_LINE| OPT_CRMOD | OPT_TANDEM))
                == (OPT_ECHO | OPT_LINE| OPT_CRMOD | OPT_TANDEM))
            options = OPT_TERMINAL;

        switch (opt) {
        case TCSANOW:
            ret = ioctl(fd, FIOSETOPTIONS, options);
            if (ret == 0 )
                        ret = ioctl(fd, SIO_HW_OPTS_SET, &t->c_cflag);
            if (ret ==  0)
                        ret = ioctl(fd, SIO_BAUD_SET, &t->c_ospeed);
            return (ret);
        default:
            printf(" OPT %d  \r\n", opt);
        }
        return (-1);
}

int
cfmakeraw(struct termios *t)
{
	t->c_iflag &= ~(IGNBRK | BRKINT | ISTRIP
	                | INLCR | IGNCR | ICRNL | IXON);
	t->c_oflag &= ~OPOST;
	t->c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG );
	t->c_cflag &= ~(CSIZE | PARENB);
	t->c_cflag |= CS8;
}

int tcflush(int fildes, int queue_selector)
{
	return 0;
}

