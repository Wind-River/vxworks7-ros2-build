# common-turtlebot3.inc project specific include file for the shell scripts
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

source common-ros2small.inc

# add turtlebot3 repos
turtlebot3_download()
{
        # retrieve ROS2 repos
	ros2small_download

        wget --no-check-certificate https://raw.githubusercontent.com/ROBOTIS-GIT/turtlebot3/ros2-devel/turtlebot3.repos
        vcs import src < turtlebot3.repos
}

turtlebot3_patch()
{
        ros2small_patch
}

turtlebot3_configure()
{
        ros2small_configure
}

turtlebot3_build()
{

        . ./vxworks_env.sh && colcon build --symlink-install --cmake-force-configure --packages-up-to hls_lfcd_lds_driver --cmake-args -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_TOOLCHAIN_FILE=$VSB_DIR/buildspecs/cmake/rtp.cmake -DCMAKE_PREFIX_PATH=$PRJ_WS/install\;$VSB_DIR/usr/root -DBUILD_TESTING=OFF
}
