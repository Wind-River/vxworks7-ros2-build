# Makefile - for eigen
#
# Copyright (c) 2023 Wind River Systems, Inc.
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
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PACKAGES += eigen

PKG_NAME = eigen
PKG_VER = 3.4.0
PKG_FILE_NAME = eigen-$(PKG_VER).tar.bz2

PKG_URL = https://gitlab.com/libeigen/eigen/-/archive/$(PKG_VER)/eigen-$(PKG_VER).tar.bz2
PKG_TYPE = unpack

PKG_LICENSE = Bsd

PKG_BUILD_DIR = build
PKG_SRC_DIR = eigen-$(PKG_VER)

WGET_OPT = --no-check-certificate -O
CURL = ""

CMAKE_OPT += -DEIGEN_TEST_CXX11=ON
# PKG_MAKE_INSTALL_OPT = $(TGT_MAKE_INSTALL_OPT)
PKG_MAKE_INSTALL_OPT = install

include $(WIND_USR_MK)/defs.cmake.mk
include $(WIND_USR_MK)/rules.packages.mk
