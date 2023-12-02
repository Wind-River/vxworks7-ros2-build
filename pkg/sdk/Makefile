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
include $(WIND_USR_MK)/defs.vxworks.mk
include $(WIND_USR_MK)/defs.packages.mk
include files/$(WIND_RELEASE_ID)/defs.sdk.mk

PACKAGES += sdk

PKG_NAME = sdk
PKG_VER = 1.0
PKG_TYPE = src

PKG_LICENSE = BSD

sdk.download :
	@$(MAKE_STAMP)

sdk.check : sdk.download 
	@$(MAKE_STAMP)

sdk.unpack : sdk.check
	@$(MAKE_STAMP)

sdk.patch : sdk.unpack
	@$(call echo_action,Applying SDK patches,$*)
	$(call sdk_patch,$*)
	@$(MAKE_STAMP)

sdk.configure : sdk.patch
	@$(MAKE_STAMP)

sdk.build : sdk.configure
	@$(MAKE_STAMP)

sdk.install : sdk.build
	@$(call echo_action,Deploying SDK artifacts,$*)
	$(call sdk_deploy,$*)
	@$(MAKE_STAMP)

sdk.clean:
	@$(call echo_action,Cleaning,$*)
	@$(CLEAN_STAMP)

include $(WIND_USR_MK)/rules.packages.mk

