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
PACKAGES += unixextra

unixextra_NAME = unixextra
unixextra_VER = 1.0
unixextra_TYPE = src

unixextra_LICENSE = BSD

unixextra_BUILD_DIR = build
unixextra_SRC_DIR = src
unixextra_PATCH_DIR = files

# unixextra_LIBS := -lunix -lnet

unixextra_CONFIGURE_OPT = $(TGT_CONFIGURE_OPT) LIBS="$(unixextra_LIBS)"
unixextra_MAKE_INSTALL_OPT = $(TGT_MAKE_INSTALL_OPT)
unixextra_MAKE_OPT = srcdir=../$(unixextra_SRC_DIR)

unixextra.unpack : 
	@$(call echo_action,Unpacking,unixextra)
	mkdir -p $(BUILD_DIR)/unixextra/$(unixextra_SRC_DIR)
	cp $(PACKAGE_DIR)/unixextra/files/* $(BUILD_DIR)/unixextra/$(unixextra_SRC_DIR)
	@$(MAKE_STAMP)

unixextra.build : unixextra.configure
	@$(call echo_action,Building,$*)
	cd $(BUILD_DIR)/unixextra/$(unixextra_BUILD_DIR) && \
	export MAKEFLAGS='$(FILTERED_MAKEFLAGS)' &&  \
	echo "MAKE_OPT: $(unixextra_MAKE_OPT)" && \
	$(MAKE) -C $(BUILD_DIR)/unixextra/$(unixextra_BUILD_DIR) -f $(BUILD_DIR)/unixextra/$(unixextra_SRC_DIR)/Makefile $(unixextra_MAKE_OPT)
	@$(MAKE_STAMP)

unixextra.install : unixextra.build
	@$(call echo_action,Installing,$*)
	cd $(BUILD_DIR)/unixextra/$(unixextra_BUILD_DIR) && \
	echo "MAKE_OPT: $(unixextra_MAKE_OPT)" && \
	export MAKEFLAGS='$(FILTERED_MAKEFLAGS)' &&  \
	$(unixextra_MAKE_INSTALL_VAR) $(MAKE) -C $(BUILD_DIR)/unixextra/$(unixextra_BUILD_DIR) -f $(BUILD_DIR)/unixextra/$(unixextra_SRC_DIR)/Makefile $(unixextra_MAKE_INSTALL_OPT) $(unixextra_MAKE_OPT)
	@$(MAKE_STAMP)
