# Makefile fragment for defs.vxworks.mk
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
# 05aug22,akh created
#

ifeq ($(__vxworks_defs),)
__vxworks_defs = TRUE

ifeq ($(WIND_CC_SYSROOT),)
ifeq ($(WIND_SDK_CC_SYSROOT),)
$(error WIND_CC_SYSROOT is not set, please source the environment)
else
export WIND_CC_SYSROOT=$(WIND_SDK_CC_SYSROOT)
export WIND_SDK_HOST_TOOLS=$(WIND_SDK_HOME)/vxsdk/host
endif
endif

## Add missing variablse from SDK
export TOOL=llvm
export TGT_ARCH=$(shell wr-cc -print-target-triple -c README.md | cut -d '-' -f 1 | sed -e 's/arm64/aarch64/g')
export TGT_BSP=$(shell grep _WRS_CONFIG_BSP $(WIND_CC_SYSROOT)/h/config/autoconf.h | grep -Ev '_BASED|_ARM|_CORE' | head -n1 | cut -d '_' -f 5-6)

3PP_DIR?=$(WIND_CC_SYSROOT)/usr/3pp
3PP_DEVELOP_DIR=$(3PP_DIR)/develop
3PP_DEPLOY_DIR=$(3PP_DIR)/deploy

WIND_RELEASE_ID=$(shell grep _WRS_CONFIG_CORE_RELEASE $(WIND_CC_SYSROOT)/h/config/auto.conf | cut -d '=' -f 2)
ifeq ($(WIND_RELEASE_ID),)
	WIND_RELEASE_ID=SR0640
	TGT_PYTHON_MINOR=8
else
        TGT_PYTHON_MINOR=9
endif
export WIND_RELEASE_ID
export TGT_PYTHON_MINOR

wind_release_id = $(shell echo $(1) | sed 's/\.//g')

endif
