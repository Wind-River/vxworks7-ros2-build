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
fastcdr_PATCH_DIR  = fastcdr
fastcdr_SRC_DIR    = src/eProsima/Fast-CDR

fastrtps_PATCH_DIR = fastrtps
fastrtps_SRC_DIR   = src/eProsima/Fast-RTPS

class_loader_PATCH_DIR = class_loader
class_loader_SRC_DIR   = src/ros/class_loader

ros2_demos_PATCH_DIR = demos
ros2_demos_SRC_DIR = src/ros2/demos

ros2_examples_PATCH_DIR = examples
ros2_examples_SRC_DIR = src/ros2/examples

rcl_PATCH_DIR = rcl
rcl_SRC_DIR = src/ros2/rcl

rclcpp_PATCH_DIR = rclcpp
rclcpp_SRC_DIR = src/ros2/rclcpp

rcutils_PATCH_DIR = rcutils
rcutils_SRC_DIR = src/ros2/rcutils

realtime_support_PATCH_DIR = realtime_support
realtime_support_SRC_DIR = src/ros2/realtime_support

rmw_implementation_PATCH_DIR = rmw_implementation
rmw_implementation_SRC_DIR = src/ros2/rmw_implementation

rosidl_PATCH_DIR = rosidl
rosidl_SRC_DIR = src/ros2/rosidl

rosidl_defaults_PATCH_DIR = rosidl_defaults
rosidl_defaults_SRC_DIR = src/ros2/rosidl_defaults

rosidl_typesupport_PATCH_DIR = rosidl_typesupport
rosidl_typesupport_SRC_DIR = src/ros2/rosidl_typesupport

tinydir_vendor_PATCH_DIR = tinydir_vendor
tinydir_vendor_SRC_DIR = src/ros2/tinydir_vendor

console_bridge_vendor_PATCH_DIR = console_bridge_vendor
console_bridge_vendor_SRC_DIR = src/ros2/console_bridge_vendor

rmw_fastrtps_shared_cpp_PATCH_DIR = rmw_fastrtps_shared_cpp
rmw_fastrtps_shared_cpp_SRC_DIR = src/ros2/rmw_fastrtps/rmw_fastrtps_shared_cpp

tlsf_cpp_PATCH_DIR = tlsf_cpp
tlsf_cpp_SRC_DIR = src/ros2/realtime_support/tlsf_cpp

# Ignore copyleft packages
ros_visualization_PATCH_DIR = ros-visualization
ros_visualization_SRC_DIR = src/ros-visualization

rviz_PATCH_DIR = rviz
rviz_SRC_DIR = src/ros2/rviz

poco_vendor_PATCH_DIR = poco_vendor
poco_vendor_SRC_DIR = src/ros2/poco_vendor

osrf_testing_tools_cpp_PATCH_DIR = osrf_testing_tools_cpp
osrf_testing_tools_cpp_SRC_DIR = src/osrf/osrf_testing_tools_cpp

orocos_kinematics_dynamics_PATCH_DIR = orocos_kinematics_dynamics
orocos_kinematics_dynamics_SRC_DIR = src/ros2/orocos_kinematics_dynamics

ros_planning_PATCH_DIR =  ros-planning
ros_planning_SRC_DIR = src/ros-planning

rmw_connext_PATCH_DIR = rmw_connext
rmw_connext_SRC_DIR = src/ros2/rmw_connext

rosidl_typesupport_connext_PATCH_DIR = rosidl_typesupport_connext
rosidl_typesupport_connext_SRC_DIR = src/ros2/rosidl_typesupport_connext

rmw_opensplice_PATCH_DIR = rmw_opensplice
rmw_opensplice_SRC_DIR = src/ros2/rmw_opensplice

rosidl_typesupport_opensplice_PATCH_DIR = rosidl_typesupport_opensplice
rosidl_typesupport_opensplice_SRC_DIR = src/ros2/rosidl_typesupport_opensplice

ament_lint_PATCH_DIR = ament_lint
ament_lint_SRC_DIR = src/ament/ament_lint

uncrustify_vendor_PATCH_DIR = uncrustify_vendor
uncrustify_vendor_SRC_DIR = src/ament/uncrustify_vendor

rcl_logging_log4cxx_PATCH_DIR = rcl_logging_log4cxx
rcl_logging_log4cxx_SRC_DIR = src/ros2/rcl_logging/rcl_logging_log4cxx

# Ignore Python-specific packages
ament_cmake_pytest_PATCH_DIR = ament_cmake_pytest
ament_cmake_pytest_SRC_DIR = src/ament/ament_cmake/ament_cmake_pytest

osrf_pycommon_PATCH_DIR = osrf_pycommon
osrf_pycommon_SRC_DIR = src/osrf/osrf_pycommon

demo_nodes_py_PATCH_DIR = demo_nodes_py
demo_nodes_py_SRC_DIR = src/ros2/demos/demo_nodes_py

tf2_py_PATCH_DIR = tf2_py
tf2_py_SRC_DIR = src/ros2/geometry2/tf2_py

kdl_parser_py_PATCH_DIR = kdl_parser_py
kdl_parser_py_SRC_DIR = src/ros2/kdl_parser/kdl_parser_py

rclpy_PATCH_DIR = rclpy
rclpy_SRC_DIR = src/ros2/rclpy

rosidl_generator_py_PATCH_DIR = rosidl_generator_py
rosidl_generator_py_SRC_DIR = src/ros2/rosidl_python/rosidl_generator_py

rqt_gui_py_PATCH_DIR = rqt_gui_py
rqt_gui_py_SRC_DIR = src/ros-visualization/rqt/rqt_gui_py
