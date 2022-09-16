# Makefile fragment for defs.packages.mk
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
# 19may16,brk HLD review changes
# 21mar14,brk created
#

ifeq ($(__packages_defs),)
__packages_defs = TRUE

VPATH             = $(STAMP_DIR)

STAMP_DIR         = $(BUILD_DIR)/.stamp
MAKE_STAMP        = $(TOUCH) $(STAMP_DIR)/$@
CLEAN_STAMP       = $(RM) -f $(STAMP_DIR)/$*.build $(STAMP_DIR)/$*.install
DISTCLEAN_STAMP   = $(RM) -f $(STAMP_DIR)/$*.*

OTHER_UNPACK ?= $(ECHO) "ERROR: Unknown source type, can't extract" ; exit 1
OTHER_CHECKOUT ?= $(ECHO) "ERROR: Unknown protocol type, can't checkout" ; exit 1

#PKG_PATCHES := $(sort $(wildcard *.patch))
BUILD_SYS_FILES = vxworks.make vxworks.mak vxworks.rtp.mak vxworks.lib.mak vxworks.krnl.mak config.vx.app

####

# PATH := $(TPP_HOST_DIR)/usr/bin:$(PATH)
# LD_LIBRARY_PATH := $(TPP_HOST_DIR)/usr/lib:$(LD_LIBRARY_PATH)
# PKG_CONFIG_PATH := $(TPP_HOST_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)
#PYTHONPATH := $(shell test -d $TPP_HOST_DIR && find $(TPP_HOST_DIR) -maxdepth 3 -type d -path '*/usr/lib/python*' -exec echo \{\}: \;)$(PYTHONPATH)
# PKG_BUILD_TARGETS ?=  $(PKG_NAME).install


PKG_CMAKE_DIR := $(PKG_SRC_DIR)

# shared libraries still have issues
EXE_FORMAT?=static

# prefer shared libraries if not selected
ifeq ($(EXE_FORMAT),)
ifeq ($(LIB_FORMAT),)
LIB_FORMAT := shared
EXE_FORMAT := dynamic
endif
ifeq ($(EXE_FORMAT),dynamic)
LIB_FORMAT := shared
endif
ifeq ($(EXE_FORMAT),static)
LIB_FORMAT := static
endif
endif


export LIB_FORMAT
export EXE_FORMAT
# export PATH

define echo_action
	@$(ECHO) "--------------------------------------------------------------------------------"; \
	$(ECHO) "$1"; \
	$(ECHO) "--------------------------------------------------------------------------------";
endef

endif
