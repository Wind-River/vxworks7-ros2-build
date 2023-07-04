# Makefile fragment for defs.sdk.mk
#
# Copyright (c) 2022 Wind River Systems, Inc.
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
# 12sep22,akh created
#

ifeq ($(__sdk_defs),)
__sdk_defs = TRUE

include $(WIND_USR_MK)/defs.packages.mk

define sdk_fix
	if [ -f files/$(WIND_RELEASE_ID)/vxWorks ]; then \
		if [ -f $(WIND_CC_SYSROOT)/../bsps/itl_generic_3_0_0_3/vxWorks ]; then \
			cp files/$(WIND_RELEASE_ID)/vxWorks $(WIND_CC_SYSROOT)/../bsps/itl_generic_3_0_0_3/vxWorks; \
		fi ; \
	fi ; \
	if [ ! -f $(WIND_CC_SYSROOT)/mk/defs.autotools.mk ]; then \
		cp files/defs.autotools.mk $(WIND_CC_SYSROOT)/mk/.; \
	fi ; \
	cp files/$(WIND_RELEASE_ID)/lib* $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/. ; \
	ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/libffi.so.7.1.0 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/libffi.so.7 ; \
	ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/libffi.so.7.1.0 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/libffi.so ; \
	ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/libssl.so.1.1 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/libssl.so ; \
	ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/libcrypto.so.1.1 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/libcrypto.so ;
endef

define vxworks_fix
endef

define python_fix
	if [ ! -f $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3 ]; then \
		ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.$(TGT_PYTHON_MINOR) $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3 ; \
		ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.$(TGT_PYTHON_MINOR) $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python ; \
	fi ; \
	cd $(DOWNLOADS_DIR) && $(call fetch_web,$(PKG_NAME),https://bootstrap.pypa.io/get-pip.py,get-pip.py) ; \
	python3 $(DOWNLOADS_DIR)/get-pip.py ; \
	if [ -d $(3PP_DEPLOY_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/site-packages ]; then \
		cp -r $(3PP_DEPLOY_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/site-packages $(3PP_DEVELOP_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/. ; \
	fi
endef

define sdk_patch
	$(call sdk_fix,$*)
	$(call echo_action,Applying VxWorks patches,$*)
	$(call vxworks_fix,$*)
	$(call echo_action,Applying Host Python patches,$*)
	$(call python_fix,$*)
endef

define sdk_deploy
	cp $(WIND_CC_SYSROOT)/usr/lib/common/lib*.so.1 $(DEPLOY_DIR)/lib/. ; \
	if [ -d $(3PP_DEPLOY_DIR)/usr ]; then \
		cp $(3PP_DEVELOP_DIR)/usr/bin/* $(DEPLOY_DIR)/bin/. ; \
		cp $(3PP_DEVELOP_DIR)/usr/lib/lib*.so* $(DEPLOY_DIR)/lib/. ; \
		cp -r $(3PP_DEVELOP_DIR)/usr/lib/python3.* $(DEPLOY_DIR)/lib/. ; \
	fi
endef

endif
