# toolchain.cmake - toolchain.cmake template file
#
# Copyright (c) 2020 Wind River Systems, Inc.
#
# The right to copy, distribute, modify or otherwise make use
# of this software may be licensed only pursuant to the terms
# of an applicable Wind River license agreement.
#
# modification history
# --------------------
# 15aug20,l_z  Written
#
# DESCRIPTION
# This is toolchain.cmake template file
#
# Usage:
#    export WIND_CC_SYSROOT=<VSB_DIR>
#    Build RTP
#        cmake -D CMAKE_TOOLCHAIN_FILE=$WIND_CC_SYSROOT/mk/toolchain.cmake [-DVX_TARGET_TYPE=RTP] <SRC_DIR>
#    Build DKM
#        cmake -D CMAKE_TOOLCHAIN_FILE=$WIND_CC_SYSROOT/mk/toolchain.cmake -DVX_TARGET_TYPE=DKM <SRC_DIR>
#

# tell cmake to find VxWorks.cmake from 
# <DIR of toolchain.cmake>/cmake/Modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# if VX_TARGET_TYPE isn't specifed with -D, VX_TARGET_TYPE is RTP
if (NOT DEFINED VX_TARGET_TYPE)
    set(VX_TARGET_TYPE RTP)
endif()

# VX_TARGET_TYPE check
if (NOT VX_TARGET_TYPE STREQUAL "DKM" AND NOT VX_TARGET_TYPE STREQUAL "RTP")
    message(FATAL_ERROR "VX_TARGET_TYPE only could be DKM or RTP.")
endif()

# load VxWorks.cmake
set(CMAKE_SYSTEM_NAME VxWorks)
set(CMAKE_SYSTEM_VERSION 7)

# set compiler
if(EXISTS $ENV{WIND_CC_SYSROOT})
    # set C/C++ compiler
    set(CMAKE_C_COMPILER wr-cc)
    set(CMAKE_CXX_COMPILER wr-c++)
else()
    message(FATAL_ERROR "VxWorks compiler not found. Please set either WIND_CC_SYSROOT or WIND_CC_SDK_TARGET.")
endif()

# set cmake sysroot to VSB directory
set(CMAKE_SYSROOT $ENV{WIND_CC_SYSROOT})

if (VX_TARGET_TYPE STREQUAL "DKM")
    # set DKM build flags to compiler
    set(CMAKE_C_FLAGS_INIT "-dkm")
    set(CMAKE_CXX_FLAGS_INIT "-dkm")

    # set root to find a package
    set(__VXWORKS_PREFIX_PATH__ /usr/3pp/develop/krnl)
    # set VxWorks kernel header path
    set(__VXWORKS_INCLUDE_PATH__
        /krnl/h/published/UTILS_UNIX
        /share/h
        /krnl/h/system
        /krnl/h/public)

    # set VxWorks kernel library path
    set(__VXWORKS_LIBRARY_PATH__
        /krnl/%TOOL%
        /krnl/%CPU%/common)
endif()

if (VX_TARGET_TYPE STREQUAL "RTP")
    # set VxWorks develop root to find package
    set(__VXWORKS_PREFIX_PATH__ /usr/3pp/develop/usr)

    # set VxWorks user header path
    set(__VXWORKS_INCLUDE_PATH__
        /usr/h/published/UTILS_UNIX
        /share/h
        /usr/h
        /usr/h/system
        /usr/h/public)

    # set VxWorks user header path
    set(__VXWORKS_LIBRARY_PATH__
        /usr/lib/common)
endif()

set (__VXWORKS_INSTALL_PREFIX__ $ENV{WIND_CC_SYSROOT}${__VXWORKS_PREFIX_PATH__})

if (NOT CMAKE_FIND_NO_INSTALL_PREFIX)
    list(APPEND __VXWORKS_PREFIX_PATH__
        # Project install destination.
        "${CMAKE_INSTALL_PREFIX}"
    )
    if(CMAKE_STAGING_PREFIX)
        list(APPEND __VXWORKS_PREFIX_PATH__
        # User-supplied staging prefix.
        "${CMAKE_STAGING_PREFIX}")
    endif()
    list(APPEND CMAKE_FIND_ROOT_PATH ${CMAKE_INSTALL_PREFIX})
endif()


# CMake find_* commands will look in the sysroot, and the
# CMAKE_FIND_ROOT_PATH entries by default in all cases, 
# as well as looking in the host system root prefix
#
# for cross build, cmake prefer to set CMAKE_FIND_ROOT_PATH,
# however, VSB header/library doesn't follow Linux root layout,
# so leave CMAKE_FIND_ROOT_PATH empty even we ask cmake
# only search CMAKE_FIND_ROOT_PATH, it actually search from
# CMAKE_SYSTEM_PREFIX_PATH, CMAKE_SYSTEM_INCLUDE_PATH and
# CMAKE_SYSTEM_LIBRARY_PATH

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

