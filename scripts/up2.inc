# up2.inc Intel UP squared board specific include file for the shell scripts
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

# Modification history
# --------------------
# 15apr19,akh  created

BSP=itl_generic
CPU=CORE
# serial console does not work on the UP2 board, use HDMI insteadi and USB keyboard
VIP_COMPONENTS_ADD="${VIP_COMPONENTS_ADD} DRV_CONSOLE_EFI DRV_KBD_USB"
VIP_PARAMETERS_SET+=(["DEFAULT_BOOT_LINE"]="\"\\\"rtg(0,0)host:vxWorks h=192.168.200.254 e=192.168.200.2 u=target\\\"\"" ["CONSOLE_BAUD_RATE"]="\"(115200)\"")

ADDRESS_MODE="-lp64"
VIP_PROFILE="PROFILE_INTEL_GENERIC"
VIP_COMPONENTS_ADD="${VIP_COMPONENTS_ADD} INCLUDE_STANDALONE_SYM_TBL"
