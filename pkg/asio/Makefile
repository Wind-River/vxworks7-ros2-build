# Makefile - for ASIO
#
# Copyright (c) 2019 Wind River Systems, Inc.
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
# 26jun18,rcw updated
# 12mar18,akh  created
#
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PACKAGES += asio

PKG_NAME = asio
PKG_VER = 1.12.0
PKG_TYPE = unpack

PKG_URL = https://github.com/chriskohlhoff/asio/archive/asio-1-12-0.tar.gz
PKG_FILE_NAME = asio-1-12-0.tar.gz
PKG_MD5_CHECKSUM = 9bacab7c7c9a0e81410571f14e36cbe4

PKG_LICENSE = Boost

PKG_BUILD_DIR = build
PKG_SRC_DIR = asio-asio-1-12-0/asio
PKG_PATCH_DIR = files

PKG_LIBS := -lunix -lnet

PKG_CONFIGURE_OPT = $(TGT_CONFIGURE_OPT) LIBS="$(PKG_LIBS)"
PKG_CONFIGURE_OPT += --without-boost
PKG_MAKE_INSTALL_OPT = $(TGT_MAKE_INSTALL_OPT)

include $(WIND_USR_MK)/rules.packages.mk

