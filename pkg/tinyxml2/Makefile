# Makefile - for tinyxml2
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
# 26jun18,rcw  Updated
# 08nov17,cai  add git clone option for getting the code.
# 02oct17,cai  created
#
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PACKAGES += tinyxml2

PKG_NAME = tinyxml2
PKG_VER = 6.2.0

PKG_URL = https://github.com/leethomason/tinyxml2.git
PKG_TYPE = git
PKG_COMMIT_ID = 8c8293ba8969a46947606a93ff0cb5a083aab47a

PKG_LICENSE = ZLib

PKG_BUILD_DIR = build
PKG_SRC_DIR = src

PKG_MAKE_INSTALL_OPT=install

tinyxml2.deploy : tinyxml2.install
	@$(call echo_action,Deploying,$*)
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)
	install -d $(DEPLOY_DIR)/bin
	install -m 755 $(BUILD_DIR)/tinyxml2/$(PKG_BUILD_DIR)/xmltest* $(DEPLOY_DIR)/bin
	cp $(ROOT_DIR)/lib/libtinyxml2*.so $(DEPLOY_DIR)/lib/.
	@$(MAKE_STAMP)

include $(WIND_USR_MK)/defs.cmake.mk
include $(WIND_USR_MK)/rules.packages.mk
