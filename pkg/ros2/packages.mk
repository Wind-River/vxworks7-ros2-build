# rospackages.mk - for ros2
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
# 15nov19,rcw  created
#

# SYNOPSIS        variables for ROS2 packages

ROS2_PATCH_DIRS=eProsima/Fast-CDR \
                eProsima/Fast-RTPS \
                ros/class_loader \
                ros2/console_bridge_vendor \
                ros2/demos \
                ros2/examples \
                ros2/libyaml_vendor \
                ros2/rcl \
                ros2/rclcpp \
                ros2/rcutils \
                ros2/realtime_support \
                ros2/rmw_implementation \
                ros2/robot_state_publisher \
                ros2/rosidl \
                ros2/rosidl_defaults \
                ros2/rosidl_typesupport \
                ros2/tinydir_vendor \
                ros2/rmw_fastrtps/rmw_fastrtps_shared_cpp \
                realtime_support/tlsf_cpp

# Ignore not used
ROS_IGNORE_DIRS=ros-visualization \
		ros2/rviz \
                ros2/poco_vendor \
                osrf/osrf_testing_tools_cpp \
                ros-planning \
                ros2/rmw_connext \
                ros2/rosidl_typesupport_connext \
                ros2/rmw_opensplice \
                ros2/rosidl_typesupport_opensplice \
                ament/ament_lint \
                ament/uncrustify_vendor \
		ros2/rcl_logging/rcl_logging_log4cxx \
		eclipse-cyclonedds


# Ignore Python-specific packages
ROS_IGNORE_DIRS+= \
                ament/ament_cmake/ament_cmake_pytest \
                osrf/osrf_pycommon \
                ros2/demos/demo_nodes_py \
                ros2/geometry2/tf2_py \
                ros2/kdl_parser/kdl_parser_py \
                ros2/rclpy \
                ros2/rosidl_python/rosidl_generator_py \
                ros-visualization/rqt/rqt_gui_py

ROS2_EXAMPLES=examples_rclcpp_minimal_action_client \
	examples_rclcpp_minimal_client \
	examples_rclcpp_minimal_publisher \
	examples_rclcpp_minimal_subscriber \
	examples_rclcpp_minimal_action_server \
	examples_rclcpp_minimal_composition \
	examples_rclcpp_minimal_service \
	examples_rclcpp_minimal_timer

PKG_PKGS_UP_TO=$(ROS2_EXAMPLES) \
	pendulum_control

#	dummy_map_server \
#	dummy_sensors \
#	robot_state_publisher

