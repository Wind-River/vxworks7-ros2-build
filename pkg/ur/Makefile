# Makefile - for Universal Robots
#
# Copyright (c) 2025 Wind River Systems, Inc.
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
# 20feb25,akh  created
#

# SYNOPSIS        automate the build of ROS 2
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk
include $(WIND_USR_MK)/defs.ros2.mk

PKG_NAME = ur
PKG_VER = $(ROS_DISTRO)

PACKAGES += ${PKG_NAME}

# use the same branch for the patches
PKG_URL = https://github.com/Wind-River/vxworks7-layer-for-ros2.git
# layer branch is calculated as $(ROS_DISTRO)-release-$(WIND_RELEASE_ID)
ifeq ($(ROS_DISTRO),rolling)
PKG_COMMIT_ID = $(ROS_DISTRO)-$(WIND_RELEASE_ID)
else
PKG_COMMIT_ID = $(ROS_DISTRO)-release-$(WIND_RELEASE_ID)
endif
PKG_TYPE = git

PKG_REPO_URL = $(PACKAGE_DIR)/${PKG_NAME}/${PKG_NAME}.repos

PKG_LICENSE = BSD

PKG_BUILD_DIR = ros2_ws
PKG_SRC_DIR = patches

PKG_BUILD_TYPE = Release

include $(PACKAGE_DIR)/${PKG_NAME}/packages.mk

$(PKG_NAME).unpack: $(PKG_NAME).download
	@$(call echo_action,Unpacking,$*)
	$(call pkg_unpack,$(PKG_NAME))
	mkdir -p $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	cp $(PKG_REPO_URL) $(PKG_NAME).repos ; \
	mkdir src; \
	vcs import src < $(PKG_NAME).repos
	@$(MAKE_STAMP)

$(PKG_NAME).patch: $(PKG_NAME).unpack
	@$(call echo_action,Patching,$*)
	$(call ros2_patch,$(PKG_PATCH_DIRS))
	@$(MAKE_STAMP)

$(PKG_NAME).configure: $(PKG_NAME).patch
	@$(call echo_action,Configuring,$*)
	$(call ros2_ignore,$(ROS_IGNORE_DIRS))
	@$(MAKE_STAMP)

$(PKG_NAME).build: $(PKG_NAME).configure
	@$(call echo_action,Building,$*)
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	. $(ROOT_DIR)/setup.bash; \
        export COLCON_HOME=$(ROOT_DIR)/.colcon; \
	colcon build --install-base $(ROOT_DIR) --merge-install \
	  --mixin vxworks build-testing-off warnings-low --packages-skip-build-finished --packages-up-to-regex $(PKG_PKGS_UP_TO);
	@$(MAKE_STAMP)

$(PKG_NAME).install : $(PKG_NAME).build
	@$(call echo_action,Installing build artifacts,$*)
	cp -r $(ROOT_DIR)/bin/* $(DEPLOY_DIR)/bin/.
	cp -r $(ROOT_DIR)/lib/* $(DEPLOY_DIR)/lib/.
	cp -r $(ROOT_DIR)/share $(DEPLOY_DIR)/.
	@$(MAKE_STAMP)

include $(WIND_USR_MK)/rules.packages.mk

