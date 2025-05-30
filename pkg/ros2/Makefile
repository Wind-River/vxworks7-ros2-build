# Makefile - for ros2
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
# 15nov19,rcw  created
# 12mar18,akh  created
#

# SYNOPSIS        automate the build of ROS 2
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk
include $(WIND_USR_MK)/defs.ros2.mk

PACKAGES += ros2

PKG_NAME = ros2
PKG_VER = $(ROS_DISTRO)

PKG_URL = https://github.com/Wind-River/vxworks7-layer-for-ros2.git
# layer branch is calculated as $(ROS_DISTRO)-release-$(WIND_RELEASE_ID)
ifeq ($(ROS_DISTRO),rolling)
PKG_COMMIT_ID = $(ROS_DISTRO)-$(WIND_RELEASE_ID)
PKG_REPO_COMMIT_ID = $(ROS_DISTRO)
else
PKG_COMMIT_ID = $(ROS_DISTRO)-release-$(WIND_RELEASE_ID)
PKG_REPO_COMMIT_ID = $(ROS_DISTRO)-release
endif
PKG_TYPE = git

PKG_REPO_URL = https://raw.githubusercontent.com/ros2/ros2/${PKG_REPO_COMMIT_ID}/${PKG_NAME}.repos

PKG_LICENSE = BSD

PKG_BUILD_DIR = ros2_ws
PKG_SRC_DIR = patches

PKG_BUILD_TYPE := Debug

include $(PACKAGE_DIR)/ros2/files/$(ROS_DISTRO)/packages.mk

ros2.unpack: ros2.download
	@$(call echo_action,Unpacking,$*)
	$(call pkg_unpack,$(PKG_NAME))
	mkdir -p $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	curl -o $(PKG_NAME).repos $(PKG_REPO_URL); \
	mkdir src; \
	vcs import src < $(PKG_NAME).repos
	@$(MAKE_STAMP)

ros2.patch: ros2.unpack
	@$(call echo_action,Patching,$*)
	$(call ros2_patch,$(ROS2_PATCH_DIRS))
	@$(MAKE_STAMP)

ros2.configure: ros2.patch
	@$(call echo_action,Configuring,$*)
	$(call ros2_ignore,$(ROS_IGNORE_DIRS))
	mkdir -p $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon/mixin/default;
	cp files/$(ROS_DISTRO)/*.mixin $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon/mixin/default/.;
	envsubst < files/$(ROS_DISTRO)/vxworks.mixin.template > $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon/mixin/default/vxworks.mixin
	@$(MAKE_STAMP)

ros2.build: ros2.configure
	@$(call echo_action,Building,$*)
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	export COLCON_HOME=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon; \
	colcon build --install-base $(ROOT_DIR) --merge-install \
	  --mixin $(ROS2_MIXINS) --packages-skip-build-finished --packages-up-to-regex $(PKG_PKGS_UP_TO);
	@$(MAKE_STAMP)

ros2.install : ros2.build
	@$(call echo_action,Installing mixin,$*)
	cp -r $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon $(ROOT_DIR)
	@$(MAKE_STAMP)

ros2.deploy : ros2.install
	@$(call echo_action,Installing runtime dependencies,$*)
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) setuptools
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) catkin_pkg
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) empy==3.3.4
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) pyelftools
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) packaging
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) lark-parser
	@$(call echo_action,Installing build artifacts,$*)
	cp -r $(ROOT_DIR)/bin/* $(DEPLOY_DIR)/bin/.
	cp -r $(ROOT_DIR)/lib/* $(DEPLOY_DIR)/lib/.
	cp -r $(ROOT_DIR)/share $(DEPLOY_DIR)/.
	cp files/$(ROS_DISTRO)/vxscript $(DEPLOY_DIR)/.
	@$(MAKE_STAMP)
	
include $(WIND_USR_MK)/rules.packages.mk

