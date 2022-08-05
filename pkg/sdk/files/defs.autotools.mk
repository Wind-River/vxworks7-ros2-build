# defs.autotools.mk - defs.autotools.mk template file
#
# Copyright (c) 2020-2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify or otherwise make use
# of this software may be licensed only pursuant to the terms
# of an applicable Wind River license agreement.
#
# DESCRIPTION
# This is defs.autoconf.mk template file
#

ifndef __DEFS_AUTOTOOLS_MK_INCLUDED
__DEFS_AUTOTOOLS_MK_INCLUDED = TRUE

# if in VSB build envionment, use VSB_DIR as wr-cc sysroot
ifdef VSB_DIR
    export WIND_CC_SYSROOT = $(VSB_DIR)
endif

# examine the WIND_CC_SYSROOT
ifndef WIND_CC_SYSROOT
  $(error WIND_CC_SYSROOT is not set, please export WIND_CC_SYSROOT)
endif

# set cc tools extension
ifeq ($(WIND_HOST_TYPE), x86-win32)
  EXTENSION = .exe
else
  EXTENSION =
endif

# autoconf cc tools
AUTOTOOLS_ENV = CC=wr-cc$(EXTENSION) CXX=wr-c++$(EXTENSION) LD=wr-ld$(EXTENSION) \
                AR=wr-ar$(EXTENSION) NM=wr-nm$(EXTENSION)                        \
                OBJCOPY=wr-objcopy$(EXTENSION) OBJDUMP=wr-objdump$(EXTENSION)    \
                RANLIB=wr-ranlib$(EXTENSION) READELF=wr-readelf$(EXTENSION)      \
                SIZE=wr-size$(EXTENSION) STRIP=wr-strip$(EXTENSION)

# vsb debug or optimize flags
CFLAGS_VSB_OPTION =

# SSP_OPTION is renamed to CFLAGS_VSB_OPTION to support
# more vsb options, to keep compatibility, set SSP_OPTION
# with same value
SSP_OPTION = $(CFLAGS_VSB_OPTION)

# --host option
AUTOTOOLS_HOST = $(TGT_ARCH)-wrs-vxworks


# --build option
ifeq ($(WIND_HOST_TYPE), x86-win32)
  AUTOTOOLS_BUILD = x86_64-pc-msys2
else
  AUTOTOOLS_BUILD = x86_64-pc-linux-gnu
endif

endif
