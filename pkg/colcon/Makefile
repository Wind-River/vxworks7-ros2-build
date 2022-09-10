# Makefile - for colcon
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
# 02may20,akh  created
#

include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PACKAGES += colcon

PKG_NAME = colcon
PKG_VER = $(ROS_DISTRO)

PKG_FILE_NAME = colcon.repos
PKG_COMMIT_ID = 8ce711f4c47bd3336e3f24f685e8b481d2bbcfe7
PKG_URL = https://raw.githubusercontent.com/colcon/colcon.readthedocs.org/$(PKG_COMMIT_ID)/$(PKG_FILE_NAME)
PKG_FILE_NAME2 = requirements.txt
PKG_URL2 = https://raw.githubusercontent.com/colcon/colcon.readthedocs.org/$(PKG_COMMIT_ID)/$(PKG_FILE_NAME2)
PKG_TYPE = unpack

PKG_LICENSE = BSD

PKG_BUILD_DIR = colcon_ws

colcon.unpack: colcon.download
	@$(call echo_action,Unpacking,$*)
	$(call pkg_unpack,$(PKG_NAME))
	mkdir -p $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	mkdir src; \
	vcs import src < $(DOWNLOADS_DIR)/$(PKG_NAME).repos
	@$(MAKE_STAMP)

colcon.patch: colcon.unpack
	@$(call echo_action,Patching,$*)
	@$(MAKE_STAMP)

colcon.configure: colcon.patch
	@$(call echo_action,Configuring,$*)
	pip3 install --upgrade --force-reinstall setuptools
	pip3 install testresources
	cd $(DOWNLOADS_DIR) && $(call fetch_web,$(PKG_NAME),$(PKG_URL2),$(PKG_FILE_NAME2))
	pip3 install -r $(DOWNLOADS_DIR)/$(PKG_FILE_NAME2)
	@$(MAKE_STAMP)

colcon.build: colcon.configure
	@$(call echo_action,Building,$*)
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	./src/colcon-core/bin/colcon build --merge-install --install-base=$(3PP_HOST_DIR) --paths src/* 
	@$(MAKE_STAMP)

colcon.install : colcon.build
	@$(call echo_action,Installing,$*)
	@$(MAKE_STAMP)

include $(WIND_USR_MK)/rules.packages.mk

