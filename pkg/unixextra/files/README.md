# `unixextra` library

It is an extension of the VxWorks `unix` library. The library is created to enable ROS 2 compilation.
It can be built natively by

```bash
$ make
$ make install DESTDIR=~/tmp
```

Also individual files can be added in the library. It is done since some files got merged in the VxWorks sources

```bash
$ make SOURCES=fmatch.c
$ make install SOURCES=fmatch.c DESTDIR=~/tmp
```
