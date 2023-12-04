# Makefile - for netifaces
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

PKG_NAME = netifaces
PACKAGES += $(PKG_NAME)

PKG_VER = 0_11_0
PKG_VER_DOTS = 0.11.0
PKG_FILE_NAME = release_$(PKG_VER).tar.gz

PKG_URL = https://github.com/al45tair/netifaces/archive/refs/tags/$(PKG_FILE_NAME)
PKG_TYPE = unpack

PKG_LICENSE = MIT

PKG_BUILD_DIR = ${PKG_NAME}-release_$(PKG_VER)
PKG_SRC_DIR = ${PKG_NAME}-release_$(PKG_VER)

include $(WIND_USR_MK)/defs.python.mk
include $(WIND_USR_MK)/rules.packages.mk

