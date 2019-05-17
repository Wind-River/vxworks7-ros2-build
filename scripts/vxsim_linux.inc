# vxsim_linux.inc board specific include file for the shell scripts
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
# 12apr19,akh  created

BSP=vxsim_linux
CPU="SIMLINUX"
ADDRESS_MODE="-ilp32"
VIP_COMPONENTS_ADD="${VIP_COMPONENTS_ADD} INCLUDE_IPTELNETS"

VIP_RUN_CMD="vxsim default/vxWorks"
