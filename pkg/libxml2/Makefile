# Makefile - for libxml2
#
# Copyright (c) 2024 Wind River Systems, Inc.
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
# 20mar24,akh  Created
#
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk


PKG_NAME = libxml2
PACKAGES += $(PKG_NAME)

PKG_VER = 2.12.6
PKG_FILE_NAME = v$(PKG_VER).tar.gz

PKG_URL = https://github.com/GNOME/$(PKG_NAME)/archive/refs/tags/$(PKG_FILE_NAME)
PKG_TYPE = unpack

PKG_LICENSE = MIT

PKG_PATCH_DIR = files
PKG_BUILD_DIR = build
PKG_SRC_DIR = ${PKG_NAME}-$(PKG_VER)

PKG_MAKE_INSTALL_OPT=install

libxml2.deploy : libxml2.install
	@$(call echo_action,Deploying,$*)
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR) && \
	cmake --install . --component runtime --prefix $(DEPLOY_DIR)
	mkdir -p $(DEPLOY_DIR)/python
	cp -P $(ROOT_DIR)/python/*libxml2* $(DEPLOY_DIR)/python/
	@$(MAKE_STAMP)

include $(WIND_USR_MK)/defs.cmake.mk
include $(WIND_USR_MK)/rules.packages.mk
