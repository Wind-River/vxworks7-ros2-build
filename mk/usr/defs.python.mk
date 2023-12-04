# Makefile fragment for defs.python.mk
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

ifeq ($(__python_defs),)
__python_defs = TRUE

include $(WIND_USR_MK)/defs.vxworks.mk

export VIRTUAL_ENV := $(WIND_SDK_HOME)/vxsdk/host/x86_64-linux/cross_venv/cross
export PATH := ${VIRTUAL_ENV}/bin:$(PATH)
# export PS1 = "(cross) $(PS1)"

PKG_PYTHON_BUILD_OPT ?= sdist bdist_wheel
PKG_PYTHON_BUILD_VAR ?= CFLAGS="-I $(WIND_CC_SYSROOT)/usr/3pp/develop/usr/include/python3.$(TGT_PYTHON_MINOR)" _PYTHON_HOST_PLATFORM=vxworks-x86_64 _PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata__vxworks_vxworks PYTHONPATH=$(WIND_CC_SYSROOT)/usr/3pp/develop/usr/lib/python3.$(TGT_PYTHON_MINOR)/:$(WIND_CC_SYSROOT)/usr/3pp/develop/usr/lib/python3.$(TGT_PYTHON_MINOR)/site-packages


define pkg_configure
	mkdir -p $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ;
endef

define pkg_build
	cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ; \
	$(PKG_PYTHON_BUILD_VAR) python3.$(TGT_PYTHON_MINOR) setup.py $(PKG_PYTHON_BUILD_OPT)
endef

define pkg_install
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR) ; \
	$(VIRTUAL_ENV)/bin/cross-pip3 install --ignore-installed --prefix=$(ROOT_DIR) dist/*.whl ; \
	$(VIRTUAL_ENV)/bin/cross-pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) dist/*.whl
endef

define pkg_clean
	if [ -n "$(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR)" ] && \
	   [ -d $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ]; then \
		cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) && python setup.py clean --all; \
	fi
endef

endif

