# Makefile - for turtlebot3
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
# 01dec18,akh  created
#

# SYNOPSIS        automate the build of ROS2
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PKG_NAME = turtlebot3
PKG_VER =  dashing

PACKAGES += ${PKG_NAME}

PKG_URL = https://github.com/Wind-River/vxworks7-layer-for-ros2.git
PKG_TYPE = git
PKG_COMMIT_ID = dashing-release-SR0620

PKG_REPO_COMMIT_ID = dashing-devel
PKG_REPO_URL = https://raw.githubusercontent.com/ROBOTIS-GIT/${PKG_NAME}/${PKG_REPO_COMMIT_ID}/${PKG_NAME}.repos

PKG_LICENSE = BSD

PKG_BUILD_DIR = ros2_ws
PKG_SRC_DIR = patches

PKG_BUILD_TYPE = Debug

include $(PACKAGE_DIR)/${PKG_NAME}/packages.mk

define ros2_patch
        for pn in $(1); do \
	        N=$$(basename $$pn); \
                if ls $(BUILD_DIR)/ros2/$(PKG_SRC_DIR)/$$N/usr_src/0001-* 1> /dev/null 2>&1; then \
                        PATCHES="$(BUILD_DIR)/ros2/$(PKG_SRC_DIR)/$$N/usr_src/*.patch"; \
                        for PATCH in $$PATCHES; do \
                                cd $(BUILD_DIR)/ros2/$(PKG_BUILD_DIR)/src/$$pn ; \
                                $(PATCH) -p1 < $$PATCH ; \
                        done; \
                fi \
	done;
endef

$(PKG_NAME).download:
	@$(MAKE_STAMP)

$(PKG_NAME).unpack: $(PKG_NAME).download
	@$(call echo_action,Unpacking,$*)
	cd $(BUILD_DIR)/ros2/$(PKG_BUILD_DIR); \
	curl -o $(PKG_NAME).repos $(PKG_REPO_URL); \
	vcs import src < $(PKG_NAME).repos
	@$(MAKE_STAMP)

$(PKG_NAME).patch: $(PKG_NAME).unpack
	@$(call echo_action,Patching,$*)
	$(call ros2_patch,$(PKG_PATCH_DIRS))
	@$(MAKE_STAMP)

$(PKG_NAME).configure: $(PKG_NAME).patch
	@$(call echo_action,Configuring,$*)
	for i in $(PKG_IGNORE_DIRS); do \
		touch $(BUILD_DIR)/ros2/$(PKG_BUILD_DIR)/src/$$i/COLCON_IGNORE; \
	done;
	@$(MAKE_STAMP)

$(PKG_NAME).build: $(PKG_NAME).configure
	@$(call echo_action,Building,$*)
	cd $(BUILD_DIR)/ros2/$(PKG_BUILD_DIR); \
	export PATH=$(3PP_HOST_DIR)/bin:$(PATH); \
	export PYTHONPATH=$(3PP_HOST_DIR)/lib/python3.8/site-packages:$(PYTHONPATH); \
        colcon build --merge-install --install-base $(ROOT_DIR) --cmake-force-configure --packages-up-to $(PKG_PKGS_UP_TO) \
		--cmake-args \
                -DCMAKE_BUILD_TYPE:STRING=$(PKG_BUILD_TYPE) \
                -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
		-DCMAKE_TOOLCHAIN_FILE=$(TGT_CMAKE_TOOLCHAIN_FILE) \
		-DPYTHON_SOABI=cpython-38-vxworks \
                -DBUILD_TESTING:BOOL=OFF
	@$(MAKE_STAMP)

$(PKG_NAME).install : $(PKG_NAME).build
	@$(call echo_action,Installing,$*)
	cp $(ROOT_DIR)/lib/lib* $(DEPLOY_DIR)/lib/.
	cp $(ROOT_DIR)/lib/hls_lfcd_lds_driver/*  $(DEPLOY_DIR)/bin/.
	cp $(ROOT_DIR)/lib/turtlebot3_node/*  $(DEPLOY_DIR)/bin/.
	cp -r $(ROOT_DIR)/lib/python3.8/* $(DEPLOY_DIR)/lib/python3.8/.
	@$(MAKE_STAMP)

include $(WIND_USR_MK)/rules.packages.mk

