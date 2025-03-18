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
# 20feb25,akh  created
#

# SYNOPSIS        variables for UR packages

PKG_PKGS_UP_TO=ur

PKG_PATCH_DIRS=pal-robotics/backward_ros \
	       PickNikRobotics/RSL \
	       ros-controls/realtime_tools \
               UniversalRobots/Universal_Robots_Client_Library \
	       UniversalRobots/Universal_Robots_ROS2_Driver

# Ignore not used
PKG_IGNORE_DIRS=

