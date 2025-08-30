# Makefile fragment for defs.ros2.mk
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
# 13mar25,akh created
#

ifeq ($(__ros2_defs),)
__ros2_defs = TRUE

include $(WIND_USR_MK)/defs.vxworks.mk

define ros2_patch
        for pn in $(1); do \
	        N=$$(basename $$pn); \
                if ls $(BUILD_DIR)/$(PKG_NAME)/$(PKG_SRC_DIR)/$$N/usr_src/0001-* 1> /dev/null 2>&1; then \
                        PATCHES="$(BUILD_DIR)/$(PKG_NAME)/$(PKG_SRC_DIR)/$$N/usr_src/*.patch"; \
                        for PATCH in $$PATCHES; do \
                                cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/src/$$pn ; \
                                $(PATCH) -p1 < $$PATCH ; \
                        done; \
                fi \
	done;
endef

define ros2_ignore
	for i in $(1); do \
		if [ -d "$(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/src/$$i" ]; then \
			touch "$(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/src/$$i/COLCON_IGNORE"; \
			echo "Ignoring $$i (COLCON_IGNORE created)"; \
		else \
			echo "Skipping $$i (directory does not exist)"; \
		fi \
	done;
endef

endif
