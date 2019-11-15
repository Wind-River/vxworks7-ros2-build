# Makefile - for tinyxml2
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
# 26jun18,rcw  Updated
# 08nov17,cai  add git clone option for getting the code.
# 02oct17,cai  created
#

PACKAGES += tinyxml2

tinyxml2_NAME = tinyxml2
tinyxml2_VER = 6.2.0

tinyxml2_URL = https://github.com/leethomason/tinyxml2.git
tinyxml2_TYPE = git
tinyxml2_COMMIT_ID = 8c8293ba8969a46947606a93ff0cb5a083aab47a

tinyxml2_LICENSE = ZLib

tinyxml2_BUILD_DIR = build
tinyxml2_SRC_DIR = src

tinyxml2_MAKE_INSTALL_OPT=install DESTDIR=$(ROOT_DIR)

tinyxml2.install : tinyxml2.build
	@$(call echo_action,Installing,tinyxml2)
	$(call pkg_install,tinyxml2)
	install -d $(ROOT_DIR)/$(TOOL)/bin
	install -m 755 $(BUILD_DIR)/tinyxml2/$(tinyxml2_BUILD_DIR)/xmltest* $(ROOT_DIR)/$(TOOL)/bin
	@$(MAKE_STAMP)

# PKG_BUILD_TARGETS = tinyxml2_default
# LIB_BASE_NAME = tinyxml2
# PKG_BUILD_TARGETS = tinyxml2
# cd $(PKG_BUILD_DIR) && git checkout -b vxworks $(COMMIT_ID)
# PRE_NOBUILD_RTPH_FILES :=
# USER_PUBLIC_H_FILES = tinyxml2.h
