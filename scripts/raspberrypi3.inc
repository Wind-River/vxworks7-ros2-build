# raspberrypi3.inc board specific include file for the shell scripts
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
# 12apr19,rcw  created

CPU=ARMARCH8A
ADDRESS_MODE="-lp64"

# VIP_PROFILE="PROFILE_DEVELOPMENT"

VIP_COMPONENTS_ADD="${VIP_COMPONENTS_ADD} INCLUDE_STANDALONE_SYM_TBL INCLUDE_STANDALONE_DTB"
# VIP_COMPONENTS_REMOVE="${VIP_COMPONENTS_REMOVE} INCLUDE_PC_CONSOLE"

VIP_PARAMETERS_SET+=(["DEFAULT_BOOT_LINE"]="\"\\\"rtg(0,0)host:vxWorks h=192.168.200.254 e=192.168.200.2 u=target\\\"\"" ["CONSOLE_BAUD_RATE"]="\"(115200)\"")
VIP_COMPONENTS_ADD="${VIP_COMPONENTS_ADD} DRV_RTC_FDT_ZYNQMP"
