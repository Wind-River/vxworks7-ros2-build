# Makefile - for unixextra
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
# 26jun18,rcw updated
# 12mar18,akh  created
#

# SYNOPSIS        extra UNIX functions not included into -lunix
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PACKAGES += unixextra

PKG_NAME = unixextra
PKG_VER = 1.0
#PKG_TYPE = src

PKG_LICENSE = BSD

PKG_BUILD_DIR = src
PKG_SRC_DIR = src
PKG_PATCH_DIR = files

PKG_CONFIGURE_OPT = $(TGT_CONFIGURE_OPT)
MAJOR_VERSION := $(shell echo $(WIND_RELEASE_ID) | cut -d. -f1)
ifeq ($(shell [ $(MAJOR_VERSION) -gt 23 ] && echo yes),yes)
PKG_MAKE_OPT = SOURCES="flock.c socketpair.c vdprintf.c posix_fallocate.c" TESTS=
endif
PKG_MAKE_INSTALL_OPT = $(TGT_MAKE_INSTALL_OPT) DESTDIR=$(WIND_CC_SYSROOT) PREFIX=/usr INCLUDE_PATH=h/published/UTILS_UNIX LIBRARY_PATH=lib/common
PKG_MAKE_BUILD_VAR = $(AUTOTOOLS_ENV)

unixextra.download :
	@$(MAKE_STAMP)

unixextra.check : unixextra.download 
	@$(MAKE_STAMP)

unixextra.unpack : unixextra.check
	@$(call echo_action,Unpacking,unixextra)
	mkdir -p $(BUILD_DIR)/$(PKG_NAME)/$(PKG_SRC_DIR)
	cp -r $(PACKAGE_DIR)/$(PKG_NAME)/files/* $(BUILD_DIR)/$(PKG_NAME)/$(PKG_SRC_DIR)
	sed -i 's/-lunix -lunixextra -lregex/-lunix -lregex/g' $(WIND_CC_SYSROOT)/cc-conf/default.conf
	@$(MAKE_STAMP)

unixextra.install : unixextra.build
	@$(call echo_action,Installing,$*)
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR) && \
	echo "MAKE_OPT: $(PKG_MAKE_OPT)" && \
	export MAKEFLAGS='$(FILTERED_MAKEFLAGS)' &&  \
	$(PKG_MAKE_INSTALL_VAR) $(MAKE) -C $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR) -f $(BUILD_DIR)/$(PKG_NAME)/$(PKG_SRC_DIR)/Makefile $(PKG_MAKE_INSTALL_OPT) $(PKG_MAKE_OPT)
	sed -i 's/-lunix -lregex/-lunix -lunixextra -lregex/g' $(WIND_CC_SYSROOT)/cc-conf/default.conf
	@$(MAKE_STAMP)

unixextra.deploy : unixextra.install
	@$(call echo_action,Deploying,$*)
	cp $(WIND_CC_SYSROOT)/usr/lib/common/libunixextra.so.* $(DEPLOY_DIR)/lib/.
	@$(MAKE_STAMP)

include $(WIND_USR_MK)/defs.make.mk
include $(WIND_USR_MK)/rules.packages.mk

