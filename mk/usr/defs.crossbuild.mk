# Makefile fragment for defs.crossbuild.mk
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

# --host and --build intentionally left to autodetect
ifeq ($(__crossbuild_defs),)
__crossbuild_defs = TRUE

include $(WIND_CC_SYSROOT)/mk/defs.autotools.mk

TGT_CONFIGURE_OPT = \
	--build=$(AUTOTOOLS_BUILD) \
        --host=$(AUTOTOOLS_HOST) \
	--prefix= \
	--includedir=/include \
	$(AUTOTOOLS_ENV)

#	--bindir=/$(TOOL_SPECIFIC_DIR)/bin \
#	--libdir=/$(TOOL_COMMON_DIR) \

TGT_MAKE_INSTALL_OPT = install DESTDIR=$(ROOT_DIR)
TGT_CMAKE_TOOLCHAIN_FILE ?= $(BUILDSPECS_DIR)/cmake/toolchain.cmake
endif
