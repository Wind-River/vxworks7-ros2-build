# Makefile - for SDK patches
#
# Copyright (c) 2020 Wind River Systems, Inc.
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
# 25apr20,akh  created
#

# SYNOPSIS        extra UNIX functions not included into -lunix
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

PACKAGES += sdk

PKG_NAME = sdk
PKG_VER = 1.0
PKG_TYPE = src

PKG_LICENSE = BSD

define compiler_fix
	sed -i 's/-lregex -T/-lregex $$(LibToolCplus) -T/g' $(WIND_CC_SYSROOT)/cc-conf/default.conf
endef

define sdk_fix
	if [ -f $(WIND_SDK_HOME)/bsps/itl_generic_2_0_2_1/boot/vxWorks ]; then \
		cp files/vxWorks $(WIND_SDK_HOME)/bsps/itl_generic_2_0_2_1/boot/vxWorks; \
	fi ;
endef

define vxworks_fix
	sed -i 's/_WRS_INLINE/inline/g'  $(WIND_CC_SYSROOT)/usr/h/public/endian.h
	sed -i 's/STATUS/int/g' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`
endef

define python_fix
	install -m 755 files/python3.8 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/ ;
	ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.8 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3 ;
	install -m 755 files/libpython3.8.so.1.0 $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/ ;
	install -m 755 files/_ssl.cpython-38-x86_64-linux-gnu.so $(WIND_SDK_HOST_TOOLS)/x86_64-linux/lib/python3.8/lib-dynload/ ; \
	if [ ! -f $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip3 ]; then \
		$(CURL) "https://bootstrap.pypa.io/get-pip.py" -o "$(DOWNLOADS_DIR)/get-pip.py" ; \
		python3 $(DOWNLOADS_DIR)/get-pip.py ; \
	fi ;
endef

define cmake_fix
	sed -i 's/_PYTHON3_VERSIONS 3.7/_PYTHON3_VERSIONS 3.8 3.7/g' $(WIND_SDK_HOST_TOOLS)/x86_64-linux/share/cmake-3.8/Modules/FindPythonLibs.cmake ;
	sed -i 's/_PYTHON3_VERSIONS 3.7/_PYTHON3_VERSIONS 3.8 3.7/g' $(WIND_SDK_HOST_TOOLS)/x86_64-linux/share/cmake-3.8/Modules/FindPythonInterp.cmake ;
endef

sdk.download :
	@$(MAKE_STAMP)

sdk.check : sdk.download 
	@$(MAKE_STAMP)

sdk.unpack : sdk.check
	@$(MAKE_STAMP)

sdk.buildsys : sdk.unpack
	@$(MAKE_STAMP)

sdk.patch : sdk.buildsys
	@$(MAKE_STAMP)

sdk.configure : sdk.patch
	@$(MAKE_STAMP)

sdk.build : sdk.configure
	@$(MAKE_STAMP)

sdk.install : sdk.build
	@$(call echo_action,Applying SDK patches,$*)
	$(call sdk_fix,$*)
	@$(call echo_action,Applying VxWorks patches,$*)
	$(call vxworks_fix,$*)
	@$(call echo_action,Applying Compiler patches,$*)
	$(call compiler_fix,$*)
	@$(call echo_action,Applying Host Python patches,$*)
	$(call python_fix,$*)
	@$(call echo_action,Applying CMake patches,$*)
	$(call cmake_fix,$*)
	@$(call echo_action,Deploying SDK artifacts,$*)
	cp $(3PP_DEPLOY_DIR)/lib/* $(DEPLOY_DIR)/lib/.
	cp $(3PP_DEPLOY_DIR)/usr/bin/* $(DEPLOY_DIR)/bin/.
	cp $(3PP_DEPLOY_DIR)/usr/lib/lib*.so* $(DEPLOY_DIR)/lib/.
	cp -r $(3PP_DEPLOY_DIR)/usr/lib/python3.8 $(DEPLOY_DIR)/lib/.
	@$(MAKE_STAMP)

include $(WIND_USR_MK)/rules.packages.mk

