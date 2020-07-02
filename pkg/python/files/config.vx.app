#! /bin/sh
# config.vx.app - autoconf configuration file for VxWorks
#
# Copyright (c) 2017-2020 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use
# of this software may be licensed only pursuant to the terms
# of an applicable Wind River license agreement.
#
# modification history
# --------------------
# 09jan20,w_c  add ac_cv_lib_dl_dlopen (V7IOT-92)
# 06dec19,l_z  add riscv support
# 26sep19,p_x  disable ac_cv_prog_cc_g
# 30aug19,pfl  disable ac_cv_func_posix_spawn
# 24may19,l_z  disable AF_UNIX by setting ac_cv_header_sys_un_h
# 25feb19,syc  remove ac_cv_func_chown
# 01feb19,syc  remove ac_cv_func_fchown
# 24jan19,syc  remove ac_cv_func_readlink
# 13dec18,wyt  add ac_cv_func_dlopen
# 23sep17,brk  create

#defined in UNIX layer, but just a wrapper to select()
ac_cv_func_poll=no

# forces define of PY_FORMAT_LONG_LONG (Python)
ac_cv_have_long_long_format=yes

#Python wants these explicit when cross compiling
ac_cv_file__dev_ptmx=no
ac_cv_file__dev_ptc=no

ac_cv_buggy_getaddrinfo=no

ac_cv_func_gettimeofday=yes

#ignore empty header in UNIX layer
ac_cv_header_langinfo_h=no

#avoid not finding pthread in various extra libs,
ac_cv_pthread_is_default=yes

#posix_spawn support is incomplete, skipped for now
ac_cv_func_posix_spawn=no

ac_cv_func_dlopen=yes

ac_cv_func_fchown=no

ac_cv_func_chown=no

ac_cv_header_sys_un_h=no

#gcc fails to compile endian test
case $host in
	ppc*-vxworks* )
		ac_cv_c_bigendian=yes ;;
	arm*-vxworks* | aarch64*-vxworks*)
		ac_cv_c_bigendian=no ;;
	x86*-vxworks* | i686*-vxworks* )
		ac_cv_c_bigendian=no ;;
	riscv*-vxworks* )
		ac_cv_c_bigendian=no ;;
esac

#disable debugging for production
ac_cv_prog_cc_g=no

# This option add '-ldl' to build parameter
# Disable it to let wr-cc choose use 'dl' or not other
# than Python itself
ac_cv_lib_dl_dlopen=no
