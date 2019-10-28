# common-ros2small.inc ROS 2 project specific include file for the shell scripts
# contains a minimal set of ROS 2 libraries to build rclcpp examples
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
# 19apr19,akh  created


# define VSB layers and put them in a dependency order
VSB_LAYERS="BZIP2 USER_MANAGEMENT EXPAT"

# Remove ASIO and TINYXML2 because they are not shipped in VxWorks 7
# PRJ_VSB_LAYERS="ASIO TINYXML2"

# define VIP components
VIP_PROFILE="PROFILE_DEVELOPMENT"

# POCO is not properly ported to vxWorks-7, do not include POCO and poco_vendor layers
PRJ_VIP_COMPONENTS="INCLUDE_POSIX_PIPES INCLUDE_POSIX_PTHREAD_SCHEDULER INCLUDE_POSIX_SEM INCLUDE_RTP INCLUDE_SHL INCLUDE_GETNAMEINFO_SYSCTL"
VIP_ATA_COMPONENTS="DRV_STORAGE_ATA_HOST PCI_DRV_STORAGE_AHCI"
VIP_COMPONENTS_ADD="${VIP_COMPONENTS_ADD} ${PRJ_VIP_COMPONENTS}"

plain_download()
{
	echo "No work required for $0"
}

plain_patch()
{
	echo "No work required for $0"
}

plain_configure()
{
	echo "No work required for $0"
}

plain_build()
{
	echo "No work required for $0"
}
