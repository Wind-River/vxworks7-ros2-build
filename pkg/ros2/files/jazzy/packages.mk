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

ROS2_BASE=actionlib_msgs action_msgs ament_cmake ament_cmake_auto ament_cmake_copyright \
	ament_cmake_core ament_cmake_cppcheck ament_cmake_cpplint ament_cmake_export_definitions \
	ament_cmake_export_dependencies ament_cmake_export_include_directories ament_cmake_export_interfaces \
	ament_cmake_export_libraries ament_cmake_export_link_flags ament_cmake_export_targets \
	ament_cmake_flake8 ament_cmake_gen_version_h ament_cmake_gmock ament_cmake_gtest \
	ament_cmake_include_directories ament_cmake_libraries ament_cmake_lint_cmake ament_cmake_pep257 \
	ament_cmake_pytest ament_cmake_python ament_cmake_ros ament_cmake_target_dependencies \
	ament_cmake_test ament_cmake_uncrustify ament_cmake_version ament_cmake_xmllint \
	ament_copyright ament_cppcheck ament_cpplint ament_flake8 ament_index_cpp ament_index_python \
	ament_lint ament_lint_auto ament_lint_cmake ament_lint_common ament_package ament_pep257 \
	ament_uncrustify ament_xmllint builtin_interfaces class_loader common_interfaces \
	composition_interfaces console_bridge_vendor cyclonedds diagnostic_msgs domain_coordinator \
	eigen3_cmake_module fastcdr fastrtps fastrtps_cmake_module foonathan_memory_vendor \
	geometry2 geometry_msgs gmock_vendor gtest_vendor iceoryx_binding_c iceoryx_hoofs \
	iceoryx_posh kdl_parser keyboard_handler launch launch_ros launch_testing \
	launch_testing_ament_cmake launch_testing_ros launch_xml launch_yaml liblz4_vendor \
	libstatistics_collector libyaml_vendor lifecycle_msgs mcap_vendor message_filters \
	nav_msgs orocos_kdl_vendor osrf_pycommon pluginlib pybind11_vendor python_cmake_module \
	python_orocos_kdl_vendor rcl rcl_action rclcpp rclcpp_action rclcpp_components \
	rclcpp_lifecycle rcl_interfaces rcl_lifecycle rcl_logging_interface rcl_logging_spdlog \
	rclpy rcl_yaml_param_parser rcpputils rcutils rmw rmw_connextdds rmw_connextdds_common \
	rmw_cyclonedds_cpp rmw_dds_common rmw_fastrtps_cpp rmw_fastrtps_shared_cpp \
	rmw_implementation rmw_implementation_cmake robot_state_publisher ros2action ros2bag \
	ros2cli ros2cli_common_extensions ros2component ros2doctor ros2interface ros2launch \
	ros2lifecycle ros2multicast ros2node ros2param ros2pkg ros2plugin ros2run ros2service \
	ros2topic rosbag2 rosbag2_compression rosbag2_compression_zstd rosbag2_cpp \
	rosbag2_interfaces rosbag2_py rosbag2_storage rosbag2_storage_default_plugins \
	rosbag2_storage_mcap rosbag2_storage_sqlite3 rosbag2_transport ros_environment \
	rosgraph_msgs rosidl_adapter rosidl_cli rosidl_cmake rosidl_core_generators \
	rosidl_core_runtime rosidl_default_generators rosidl_default_runtime \
	rosidl_dynamic_typesupport rosidl_dynamic_typesupport_fastrtps rosidl_generator_c \
	rosidl_generator_cpp rosidl_generator_py rosidl_generator_type_description rosidl_parser \
	rosidl_pycommon rosidl_runtime_c rosidl_runtime_cpp rosidl_runtime_py rosidl_typesupport_c \
	rosidl_typesupport_cpp rosidl_typesupport_fastrtps_c rosidl_typesupport_fastrtps_cpp \
	rosidl_typesupport_interface rosidl_typesupport_introspection_c rosidl_typesupport_introspection_cpp \
	ros_workspace rpyutils rti_connext_dds_cmake_module sensor_msgs sensor_msgs_py service_msgs \
	shape_msgs spdlog_vendor sqlite3_vendor sros2 sros2_cmake statistics_msgs std_msgs \
	std_srvs stereo_msgs tf2 tf2_bullet tf2_eigen tf2_eigen_kdl tf2_geometry_msgs tf2_kdl \
	tf2_msgs tf2_py tf2_ros tf2_ros_py tf2_sensor_msgs tf2_tools tinyxml2_vendor \
	trajectory_msgs type_description_interfaces uncrustify_vendor unique_identifier_msgs urdf \
	urdfdom urdfdom_headers urdf_parser_plugin visualization_msgs yaml_cpp_vendor zstd_vendor

ROS2_PATCH_DIRS=ament/ament_cmake \
		ament/googletest \
		ament/uncrustify_vendor \
		eclipse-iceoryx/iceoryx \
                eclipse-cyclonedds/cyclonedds \
                eProsima/Fast-DDS \
                osrf/osrf_pycommon \
                osrf/osrf_testing_tools_cpp \
                ros/class_loader \
                ros/urdfdom \
		ros2/geometry2 \
                ros2/mimick_vendor \
                ros2/orocos_kdl_vendor \
                ros2/pybind11_vendor \
                ros2/rclcpp \
                ros2/rclpy \
                ros2/rcpputils \
                ros2/rcutils \
                ros2/rmw \
                ros2/rmw_implementation \
                ros2/rosbag2 \
                ros2/ros2_tracing \
                ros2/ros2cli \
                ros2/yaml_cpp_vendor

ROS2_MIXINS=vxworks warnings-low build-testing-off

# Check if ROS2_MIXINS contains "build-testing-off"
ifeq ($(findstring build-testing-off,$(ROS2_MIXINS)),build-testing-off)
ROS_IGNORE_TESTING_DIRS = osrf/osrf_testing_tools_cpp \
                          ament/google_benchmark_vendor \
                          ros2/mimick_vendor \
                          ros2/performance_test_fixture
endif

# Ignore not used
ROS_IGNORE_DIRS=ros-visualization \
		ros2/rviz \
                ros-planning \
		$(ROS_IGNORE_TESTING_DIRS)

# Ignore Python-specific packages
ROS_IGNORE_PYTHON_DIRS+= \
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
              examples_rclcpp_minimal_subscriber \
              examples_rclpy_* \
              demo_nodes_cpp \
              demo_nodes_py \
              dummy_robot

ROS2_PYTHON_TOOLS=ros2action ros2cli ros2component ros2doctor \
	ros2interface ros2lifecycle ros2multicast ros2node ros2param ros2pkg \
	ros2run ros2service ros2topic

ROS2_UR_DEPS=tf2_geometry_msgs trajectory_msgs yaml_cpp_vendor

PKG_PKGS_UP_TO+= $(ROS2_BASE) $(ROS2_EXAMPLES)

#	pendulum_control

