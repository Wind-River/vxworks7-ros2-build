# Makefile - for pyyaml
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
#
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PKG_NAME = pyyaml
PACKAGES += $(PKG_NAME)

PKG_VER = 6.0.1
PKG_FILE_NAME = $(PKG_VER).tar.gz

PKG_URL = https://github.com/yaml/pyyaml/archive/refs/tags/$(PKG_FILE_NAME)
PKG_TYPE = unpack

PKG_LICENSE = MIT

PKG_PATCH_DIR = files
PKG_BUILD_DIR = ${PKG_NAME}-$(PKG_VER)
PKG_SRC_DIR = ${PKG_NAME}-$(PKG_VER)

PKG_MAKE_BUILD_VAR = PYTHON=python3.$(TGT_PYTHON_MINOR) \
		     CC=wr-cc \
		     CFLAGS="-I $(WIND_CC_SYSROOT)/usr/3pp/develop/usr/include/python3.$(TGT_PYTHON_MINOR) -I $(ROOT_DIR)/include/libyaml_vendor" \
		     LDSHARED="wr-cc -shared" \
		     LDFLAGS="-L $(WIND_CC_SYSROOT)/usr/3pp/develop/usr/lib -lpython3 -L $(ROOT_DIR)/lib -lyaml" \
		     _PYTHON_HOST_PLATFORM=vxworks-x86_64 \
		     _PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata__vxworks_vxworks \
		     PYTHONPATH=$(WIND_CC_SYSROOT)/usr/3pp/develop/usr/lib/python3.9/:$(WIND_CC_SYSROOT)/usr/3pp/develop/usr/lib/python3.9/site-packages

PKG_MAKE_OPT = bdist

PKG_MAKE_INSTALL_OPT = --help 1> /dev/null \
		       && cp -r $(BUILD_DIR)/$(PKG_NAME)/${PKG_BUILD_DIR}/lib/* $(ROOT_DIR)/lib/python3.$(TGT_PYTHON_MINOR)/site-packages/. \
		       && cp -r $(BUILD_DIR)/$(PKG_NAME)/${PKG_BUILD_DIR}/lib/* $(DEPLOY_DIR)/lib/python3.$(TGT_PYTHON_MINOR)/site-packages/.

include $(WIND_USR_MK)/defs.make.mk
include $(WIND_USR_MK)/rules.packages.mk
