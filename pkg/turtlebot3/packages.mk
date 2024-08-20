# rospackages.mk - for turtlebot3
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
# modification history
# --------------------
# 01dec19,akh  created
#

# SYNOPSIS        variables for turtlebot3 packages

PKG_PKGS_UP_TO=hls_lfcd_lds_driver \
              dynamixel_sdk \
	      turtlebot3_node \
	      turtlebot3_example

PKG_PATCH_DIRS=utils/DynamixelSDK \
               utils/hls_lfcd_lds_driver \
	       turtlebot3/turtlebot3

# Ignore not used
PKG_IGNORE_DIRS=

