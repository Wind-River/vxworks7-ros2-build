#!/bin/bash

# prj-native-download.sh shell script to download project sources
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

set -x 

LOCAL_DIR=$(dirname $(readlink -f $0))
if [ ! -f "${LOCAL_DIR}/common.inc" ]; then
	echo "Cannot find ${LOCAL_DIR}/common.inc"
	exit 1
fi
cd ${LOCAL_DIR}
source common.inc

echo "Downloading ${PRJ} repos"

cd ${PRJ_NATIVE_WS}

# retrieve ROS2 repos
wget https://raw.githubusercontent.com/ros2/ros2/${PRJ_COMMIT_ID}/ros2.repos

# create a src directory
mkdir src
vcs import src < ros2.repos

#cd src
#mkdir ros-simulation
#cd ros-simulation
#git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b ros2
#cd ${PRJ_NATIVE_WS}/src/ros-perception
#git clone https://github.com/ros-perception/image_common.git -b ros2
#git clone https://github.com/ros-perception/vision_opencv -b ros2

