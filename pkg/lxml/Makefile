# Makefile - for lxml
#
# Copyright (c) 2024 Wind River Systems, Inc.
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

PKG_NAME = lxml
PACKAGES += $(PKG_NAME)

PKG_VER = 5.0.1-1
PKG_FILE_NAME = $(PKG_NAME)-$(PKG_VER).tar.gz

PKG_URL = https://github.com/lxml/$(PKG_NAME)/archive/refs/tags/$(PKG_FILE_NAME)
PKG_TYPE = unpack

PKG_LICENSE = BSD

PKG_PATCH_DIR = files
PKG_BUILD_DIR = ${PKG_NAME}-${PKG_NAME}-$(PKG_VER) 
PKG_SRC_DIR = ${PKG_NAME}-${PKG_NAME}-$(PKG_VER)

lxml.uninstall_cython : lxml.patch
	rm -rf $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/python3.$(TGT_PYTHON_MINOR)/site-packages/Cython*
	pip install -r $(BUILD_DIR)/$(PKG_NAME)/$(PKG_SRC_DIR)/requirements.txt
	@$(MAKE_STAMP)

CONFIGURE_DEPENDS = lxml.uninstall_cython

include $(WIND_USR_MK)/defs.python.mk
PKG_PYTHON_BUILD_OPT += --with-xml2-config=$(ROOT_DIR)/bin/xml2-config --with-xslt-config=$(ROOT_DIR)/bin/xslt-config
include $(WIND_USR_MK)/rules.packages.mk

