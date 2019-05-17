#!/bin/bash

# prj-native-patch.sh shell script to patch project sources
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

setup_env

echo "Pathching ${PRJ}"

cd ${PRJ_NATIVE_WS}

PRJ_PKGS_DIRS=(src/ros2/rviz src/ros/pluginlib)
PRJ_PKGS=(rviz pluginlib)
# find pathches for pkgs in the list and apply them to project workspace
for ((c=0; c<${#PRJ_PKGS[@]}; c++)); do
	# patches exist?
        if ls ${WIND_PKGS}/${PRJ_NATIVE_GIT_DIR}/${PRJ_PKGS[$c]}/usr_src/0001-* 1> /dev/null 2>&1; then
		# patch project workspace
		PATCHES="${WIND_PKGS}/${PRJ_NATIVE_GIT_DIR}/${PRJ_PKGS[$c]}/usr_src"/*.patch
		for PATCH in ${PATCHES}; do
			patch -p1 -d ${PRJ_PKGS_DIRS[$c]} < ${PATCH}
		done
	fi
done
