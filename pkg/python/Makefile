# Makefile - for PYTHON
#
# Copyright (c) 2020 Wind River Systems, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# modification history
# --------------------
# 24apr20,akh  created
#
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PACKAGES += python

PKG_NAME = Python
PKG_VER = 3.8.0
PKG_TYPE = unpack

PKG_FILE_NAME = $(PKG_NAME)-$(PKG_VER).tgz
PKG_URL = https://www.python.org/ftp/python/$(PKG_VER)/$(PKG_FILE_NAME)
PKG_MD5_CHECKSUM = f1069ad3cae8e7ec467aa98a6565a62a48ef196cb8f1455a245a08db5e1792df

PKG_LICENSE = Python

PKG_BUILD_DIR = build
PKG_SRC_DIR = $(PKG_NAME)-$(PKG_VER)
PKG_PATCH_DIR = files

PKG_CONFIGURE_OPT = \
		--build=x86_64-pc-linux-gnu \
		--host=$(TGT_ARCH)-wrs-vxworks \
		--enable-shared                            \
		--prefix=$(WIND_CC_SYSROOT)/usr/3pp/develop/usr        \
		--with-libm=no                             \
		--with-ensurepip=no                        \
		--with-openssl=$(WIND_CC_SYSROOT)/usr/h/public     \
		OPENSSL_LIBS="-lcrypto -lssl -lnet"        \
		CONFIG_SITE=$(TOP_BUILDDIR)/pkg/python/files/config.vx.app                  \
		CFLAGS="-w"                                \
		PKG_CONFIG_PATH=$(WIND_CC_SYSROOT)/usr/3pp/develop/usr/lib/pkgconfig \
		CC=wr-cc CXX=wr-c++ CPP='wr-cc -E' LD=wr-ld AR=wr-ar NM=wr-nm OBJCOPY=wr-objcopy OBJDUMP=wr-objdump RANLIB=wr-ranlib READELF=wr-readelf SIZE=wr-size STRIP=wr-strip

# build python and sharedlibs
PKG_MAKE_OPT = platform

# install python and shared libs
PKG_MAKE_INSTALL_OPT = libpython3.so && \
		       install -m 755 $(BUILD_DIR)/python/$(PKG_BUILD_DIR)/python $(WIND_CC_SYSROOT)/usr/3pp/develop/usr/bin/python3.8 && \
		       cp $(BUILD_DIR)/python/$(PKG_BUILD_DIR)/libpython* $(WIND_CC_SYSROOT)/usr/3pp/develop/usr/lib/.

include $(WIND_USR_MK)/rules.packages.mk
