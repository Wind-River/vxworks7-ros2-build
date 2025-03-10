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
# 15may22,akh  created
#

# SYNOPSIS        variables for ROS 2 packages

ROS2_PATCH_DIRS=ament/googletest \
		eclipse-iceoryx/iceoryx \
                eclipse-cyclonedds/cyclonedds \
                eProsima/Fast-DDS \
                osrf/osrf_pycommon \
                osrf/osrf_testing_tools_cpp \
                ros/class_loader \
                ros/urdfdom \
                ros2/mimick_vendor \
                ros2/orocos_kdl_vendor \
                ros2/pybind11_vendor \
                ros2/rclcpp \
                ros2/rclpy \
                ros2/rcpputils \
                ros2/rcutils \
                ros2/rmw \
                ros2/rmw_implementation \
                ros2/ros2_tracing \
                ros2/ros2cli

ifeq ($(shell test $(call wind_release_id,$(WIND_RELEASE_ID)) -lt 2403 && echo true),true)
ROS_IGNORE_TESTING_DIRS=osrf/osrf_testing_tools_cpp \
		ament/ament_lint \
		ament/google_benchmark_vendor \
		ros2/mimick_vendor \
		ros2/performance_test_fixture
endif

# Ignore not used
ROS_IGNORE_DIRS=ros-visualization \
		ros2/rviz \
                ros-planning \
                ros2/rmw_connextdds \
                ament/uncrustify_vendor \
		eclipse-iceoryx \
		$(ROS_IGNORE_TESTING_DIRS)

# Ignore Python-specific packages
#ROS_IGNORE_PYTHON_DIRS+= \
                ament/ament_cmake/ament_cmake_pytest \
                osrf/osrf_pycommon \
                ros2/demos/demo_nodes_py \
                ros2/geometry2/tf2_py \
                ros2/kdl_parser/kdl_parser_py \
                ros2/rclpy \
                ros2/rosidl_python/rosidl_generator_py \
                ros-visualization/rqt/rqt_gui_py

ROS2_EXAMPLES=examples_rclcpp_minimal_timer \
              examples_rclcpp_minimal_client \
              examples_rclcpp_minimal_service \
              examples_rclcpp_minimal_publisher \
              examples_rclpy_* \
              demo_nodes_cpp \
              demo_nodes_py \
              dummy_robot

ROS2_PYTHON_TOOLS=ros2action ros2cli ros2component ros2doctor \
	ros2interface ros2lifecycle ros2multicast ros2node ros2param ros2pkg \
	ros2run ros2service ros2topic

PKG_PKGS_UP_TO+=$(ROS2_EXAMPLES) \
	$(ROS2_PYTHON_TOOLS) \
	sros2

#	pendulum_control

