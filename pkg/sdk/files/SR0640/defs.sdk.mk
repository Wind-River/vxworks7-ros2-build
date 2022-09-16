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
	if [ -f $(WIND_SDK_HOME)/bsps/itl_generic_2_0_2_1/boot/vxWorks ]; then \
		cp files/$(WIND_RELEASE_ID)/vxWorks $(WIND_SDK_HOME)/bsps/itl_generic_2_0_2_1/boot/vxWorks; \
	fi ; \
	if [ ! -f $(WIND_CC_SYSROOT)/mk/defs.autotools.mk ]; then \
		cp files/defs.autotools.mk $(WIND_CC_SYSROOT)/mk/.; \
	fi ;
endef

define vxworks_fix
	sed -i 's/_WRS_INLINE/inline/g'  $(WIND_CC_SYSROOT)/usr/h/public/endian.h
	sed -i 's/STATUS/int/g' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`
	sed -i 's/u_int/unsigned int/g'  $(WIND_CC_SYSROOT)/usr/h/public/net/ifaddrs.h
endef

define python_fix
	install -m 755 files/$(WIND_RELEASE_ID)/python3.8 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/ ; \
	install -m 755 files/$(WIND_RELEASE_ID)/libpython3.8.so.1.0 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/ ; \
	install -m 755 files/$(WIND_RELEASE_ID)/_ssl.cpython-38-x86_64-linux-gnu.so $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/python3.8/lib-dynload/ ; \
	ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.$(TGT_PYTHON_MINOR) $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3 ; \
	ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.$(TGT_PYTHON_MINOR) $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python ; \
	if [ ! -f $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip3 ]; then \
		cd $(DOWNLOADS_DIR) && $(call fetch_web,$(PKG_NAME),https://bootstrap.pypa.io/get-pip.py,get-pip.py) ; \
		python3 $(DOWNLOADS_DIR)/get-pip.py ; \
	fi ; \
	if [ -d $(3PP_DEPLOY_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/site-packages ]; then \
		cp -r $(3PP_DEPLOY_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/site-packages $(3PP_DEVELOP_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/. ; \
	fi
endef

define cmake_fix
	if [ -d $(WIND_SDK_HOST_TOOLS)/x86_64-linux/share/cmake-3.8 ]; then \
		sed -i 's/_PYTHON3_VERSIONS 3.7/_PYTHON3_VERSIONS 3.8 3.7/g' $(WIND_SDK_HOST_TOOLS)/x86_64-linux/share/cmake-3.8/Modules/FindPythonLibs.cmake ; \
		sed -i 's/_PYTHON3_VERSIONS 3.7/_PYTHON3_VERSIONS 3.8 3.7/g' $(WIND_SDK_HOST_TOOLS)/x86_64-linux/share/cmake-3.8/Modules/FindPythonInterp.cmake ; \
	fi ;
endef

define sdk_patch
	$(call sdk_fix,$*)
	$(call echo_action,Applying VxWorks patches,$*)
	$(call vxworks_fix,$*)
	$(call echo_action,Applying Host Python patches,$*)
	$(call python_fix,$*)
	$(call echo_action,Applying CMake patches,$*)
	$(call cmake_fix,$*)
endef

define sdk_deploy
	cp $(WIND_CC_SYSROOT)/usr/lib/common/lib*.so.1 $(DEPLOY_DIR)/lib/. ; \
	cp $(3PP_DEVELOP_DIR)/usr/bin/* $(DEPLOY_DIR)/bin/. ; \
	cp $(3PP_DEVELOP_DIR)/usr/lib/lib*.so* $(DEPLOY_DIR)/lib/. ; \
	cp -r $(3PP_DEVELOP_DIR)/usr/lib/python3.* $(DEPLOY_DIR)/lib/.
endef

endif
