# Makefile fragment for defs.makes.mk
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
ifeq ($(__make_defs),)
__make_defs = TRUE

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
	mkdir -p $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ;
endef

define pkg_clean
	if [ -n "$(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR)" ] && \
	   [ -d $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ]; then \
		$(MAKE) -C $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) -f Makefile clean; \
	fi
endef

endif
