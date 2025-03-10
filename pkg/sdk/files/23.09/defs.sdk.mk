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
include $(WIND_USR_MK)/defs.python.mk

define sdk_fix
	if [ ! -f $(WIND_CC_SYSROOT)/mk/defs.autotools.mk ]; then \
		echo "copying 'defs.autotools.mk'."; \
		cp files/defs.autotools.mk $(WIND_CC_SYSROOT)/mk/.; \
	else \
		echo "'defs.autotools.mk' already exists, do not copy."; \
	fi
endef

define vxworks_fix
        if grep -q 'STATUS' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`; then \
                echo "'STATUS' found, replacing it with 'int'"; \
                sed -i 's/STATUS/int/g' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`; \
        else \
                echo "'STATUS' not found, no changes needed."; \
        fi

        if grep -q 'u_int' $(WIND_CC_SYSROOT)/usr/h/public/net/ifaddrs.h; then \
                echo "'u_int' found, replacing it with unsigned 'int'";  \
                sed -i 's/u_int/unsigned int/g' $(WIND_CC_SYSROOT)/usr/h/public/net/ifaddrs.h; \
        else \
                echo "'u_int' not found, no changes needed."; \
        fi
endef

define python_fix
	if [ ! -L $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3 ]; then \
		ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.$(TGT_PYTHON_MINOR) $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3; \
		echo "'python3' symbolic link created."; \
	else \
		echo "'python3' symbolic link already exists."; \
	fi

	if [ ! -L $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python ]; then \
		ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.$(TGT_PYTHON_MINOR) $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python; \
		echo "'python' symbolic link created."; \
	else \
		echo "'python' symbolic link already exists."; \
	fi

	if [ ! -f $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip3 ]; then \
		cd $(DOWNLOADS_DIR) && $(call fetch_web,$(PKG_NAME),https://bootstrap.pypa.io/get-pip.py,get-pip.py) ; \
		python3 $(DOWNLOADS_DIR)/get-pip.py ; \
		echo "'pip3' was not found and has been installed." ; \
	else \
		echo "'pip3' already exists, no installation needed." ; \
	fi
endef

define sdk_patch
	$(call echo_action,Fixing SDK,$*)
	$(call sdk_fix,$*)
	$(call echo_action,Applying Host Python patches,$*)
	$(call python_fix,$*)
endef

define sdk_install
	pip3 install -r files/$(WIND_RELEASE_ID)/requirements.txt ;
	export SSL_CERT_FILE=$(shell python3 -m certifi) ;

	if [ ! -f "$(VIRTUAL_ENV)/bin/activate" ]; then \
		echo "setup 'crossenv'."; \
		python3.$(TGT_PYTHON_MINOR) -m crossenv $(WIND_CC_SYSROOT)/usr/3pp/develop/usr/bin/python3 $(VIRTUAL_ENV); \
	else \
		echo "'crossenv' already exists."; \
	fi
endef

define sdk_deploy
	cp $(WIND_CC_SYSROOT)/usr/lib/common/lib*.so.[0-9] $(DEPLOY_DIR)/lib/. ; \
	cp $(3PP_DEVELOP_DIR)/usr/bin/* $(DEPLOY_DIR)/bin/. ; \
	cp $(3PP_DEVELOP_DIR)/usr/lib/lib*.so* $(DEPLOY_DIR)/lib/. ; \
	cp -r $(3PP_DEVELOP_DIR)/usr/lib/python3.* $(DEPLOY_DIR)/lib/. ; \
	if [ -d $(3PP_DEPLOY_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/site-packages ]; then \
		cp -r $(3PP_DEPLOY_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/site-packages $(3PP_DEVELOP_DIR)/usr/lib/python3.$(TGT_PYTHON_MINOR)/. ; \
	fi
endef

endif
