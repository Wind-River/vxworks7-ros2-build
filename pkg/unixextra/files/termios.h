/* termios.h - termios header extensions for UNIX compatibility */

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

#ifndef __INCtermiosh
#define __INCtermiosh

#include <sioLibCommon.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Standard speeds
 */
#define B0      0
#define B50     50
#define B75     75
#define B110    110
#define B134    134
#define B150    150
#define B200    200
#define B300    300
#define B600    600
#define B1200   1200
#define B1800   1800
#define B2400   2400
#define B4800   4800
#define B9600   9600
#define B19200  19200
#define B38400  38400
#define B57600  57600
#define B115200 115200
#define B230400 230400
#define B460800 460800
#define B500000 500000
#define B576000 576000
#define B921600 921600
#define B1000000 1000000
#define B1152000 1152000
#define B1500000 1500000
#define B2000000 2000000
#define B2500000 2500000
#define B3000000 3000000
#define B3500000 3500000
#define B4000000 4000000

/*
 * Special Control Characters
 *
 * Index into c_cc[] character array.
 *
 *      Name         Subscript  Enabled by
 */
#define VINTR            0
#define VQUIT            1
#define VERASE           2
#define VKILL            3
#define VEOF             4
#define VMIN            16      /* !ICANON */
#define VTIME           17      /* !ICANON */
#define	NCCS		    20

/*
 * Input flags - software input processing
 */
#define IGNBRK          0x00000001      /* ignore BREAK condition */
#define BRKINT	        0x00000002      /* BREAK will flush and send SIGINT */
#define INPCK           0x00000020      /* enable checking of parity errors */
#define ISTRIP          0x00000040      /* strip 8th bit off chars */
#define INLCR           0x00000100      /* map NL into CR */
#define IGNCR           0x00000200      /* ignore CR */
#define ICRNL           0x00000400      /* map CR to NL (ala CRMOD) */
#define IXON            0x00002000      /* enable output flow control */
#define IXOFF           0x00010000      /* enable input flow control */

/*
 * Output flags - software output processing
 */
#define OPOST           0x00000001      /* enable following output processing */
#define ONLCR	        0x00000004		/* NL to CRNL */
#define OCRNL	        0x00000010		/* CR to NL */

/*
 * Local flags
 */
#define ISIG            0x00000001      /* enable signals INTR, QUIT, [D]SUSP */
#define ICANON          0x00000002      /* canonicalize input lines */
#define ECHO            0x00000010      /* enable echoing */
#define ECHOE           0x00000020      /* visually erase chars */
#define ECHOK           0x00000040      /* echo NL after line kill */
#define ECHONL	        0x00000100

#define IEXTEN          0
#define PARMRK          0
#define TCIFLUSH        0
#define NOFLSH          0
#define IGNPAR          0

#define TCSANOW         0               /* make change immediate */
#define TCSADRAIN       1               /* drain output, then change */
#define TCSAFLUSH       2               /* drain output, flush input */
#define TCSASOFT        0x10            /* flag - don't alter h.w. state */



#define CSTOPB          0x00000400      /* send 2 stop bits */
#define CCTS_OFLOW      0x00010000      /* CTS flow control of output */
#define CRTS_IFLOW      0x00020000      /* RTS flow control of input */
#define CRTSCTS         (CCTS_OFLOW | CRTS_IFLOW)



typedef unsigned int  tcflag_t;
typedef unsigned char	cc_t;
typedef unsigned int  speed_t;

struct termios {
	tcflag_t	c_iflag;	/* input flags */
	tcflag_t	c_oflag;	/* output flags */
	tcflag_t	c_cflag;	/* control flags */
	tcflag_t	c_lflag;	/* local flags */
	cc_t		c_cc[NCCS];	/* control chars */
	speed_t		c_ispeed;	/* input speed */
	speed_t		c_ospeed;	/* output speed */
};

int cfsetospeed(struct termios *t, speed_t speed);
speed_t cfgetospeed(struct termios *t);
int cfsetispeed(struct termios *t, speed_t speed);
int tcgetattr(int fd, struct termios *t);
int tcsetattr(int fd, int opt, const struct termios *t);
int tcflush(int fildes, int queue_selector);


#ifdef __cplusplus
}
#endif

#include <sys/ttycom.h>
#endif
