# Makefile fragment for defs.cmakes.mk
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
ifeq ($(__cmake_defs),)
__cmake_defs = TRUE

include $(WIND_USR_MK)/defs.packages.mk

define pkg_install
	cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) && \
	export MAKEFLAGS='$(FILTERED_MAKEFLAGS)' &&  \
	$(PKG_MAKE_INSTALL_VAR) $(MAKE) -C $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) -f Makefile $(PKG_MAKE_INSTALL_OPT)
endef

define pkg_build
	cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) && \
	export MAKEFLAGS='$(FILTERED_MAKEFLAGS)' &&  \
	echo "MAKE_OPT: $(PKG_MAKE_OPT)" && \
	$(PKG_MAKE_BUILD_VAR) $(MAKE) -j$(nproc) -C $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) -f Makefile $(PKG_MAKE_OPT)
endef

define pkg_configure
	mkdir -p $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ; \
	cd $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) && \
	if [ -f $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR)/CMakeLists.txt ]; then \
		cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ; \
		cmake $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) \
		    -DCMAKE_TOOLCHAIN_FILE=$(TGT_CMAKE_TOOLCHAIN_FILE) \
		    -DCMAKE_INSTALL_PREFIX=$(ROOT_DIR) \
		    -DCMAKE_PREFIX_PATH=$(ROOT_DIR) \
		    $(CMAKE_OPT) ; \
	fi
endef

endif