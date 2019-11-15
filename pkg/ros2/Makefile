# Makefile - for ros2
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
# 12mar18,akh  created
#

# SYNOPSIS        automate the build of ROS2
PACKAGES += ros2

ros2_NAME = ros2
ros2_VER =  dashing

ros2_URL = https://github.com/Wind-River/vxworks7-layer-for-ros2.git
ros2_TYPE = git
ros2_COMMIT_ID = dashing-release-SR0620

ros2_REPO_COMMIT_ID = dashing-release
ros2_REPO_URL = https://raw.githubusercontent.com/ros2/ros2/${ros2_REPO_COMMIT_ID}/ros2.repos

ros2_LICENSE = BSD

ros2_BUILD_DIR = ros2_ws
ros2_SRC_DIR = src
ros2_PATCH_DIR = patches

ros2_BUILD_TYPE = Debug

include $(PACKAGE_DIR)/ros2/rospackages.mk

ros2_EXAMPLES=examples_rclcpp_minimal_action_client \
              examples_rclcpp_minimal_client \
              examples_rclcpp_minimal_publisher \
              examples_rclcpp_minimal_subscriber \
              examples_rclcpp_minimal_action_server \
              examples_rclcpp_minimal_composition \
              examples_rclcpp_minimal_service \
              examples_rclcpp_minimal_timer

define ros2_patch
        if ls $(BUILD_DIR)/ros2/$(ros2_SRC_DIR)/$($(1)_PATCH_DIR)/usr_src/0001-* 1> /dev/null 2>&1; then \
                PATCHES="$(BUILD_DIR)/ros2/$(ros2_SRC_DIR)/$($(1)_PATCH_DIR)/usr_src/*.patch"; \
                for PATCH in $$PATCHES; do \
                        $(PATCH) -p1 -N -d $(BUILD_DIR)/ros2/$(ros2_BUILD_DIR)/$($(1)_SRC_DIR) -p1 < $$PATCH ; \
                done; \
        fi
endef

define ros2_ignorepkg
	touch $(BUILD_DIR)/ros2/$(ros2_BUILD_DIR)/$($(1)_SRC_DIR)/COLCON_IGNORE
endef

ros2.unpack: ros2.download
	@$(call echo_action,Unpacking,$*)
	$(call pkg_unpack,ros2)
	mkdir -p $(BUILD_DIR)/ros2/$(ros2_BUILD_DIR); \
	cd $(BUILD_DIR)/ros2/$(ros2_BUILD_DIR); \
	curl -o ros2.repos $(ros2_REPO_URL); \
	mkdir src; \
	vcs import src < ros2.repos
	@$(MAKE_STAMP)

ros2.patch: ros2.unpack
	@$(call echo_action,Patching,$*)
	$(call ros2_patch,fastcdr)
	$(call ros2_patch,fastrtps)
	$(call ros2_patch,class_loader)
	$(call ros2_patch,ros2_demos)
	$(call ros2_patch,ros2_examples)
	$(call ros2_patch,rcl)
	$(call ros2_patch,rclcpp)
	$(call ros2_patch,rcutils)
	$(call ros2_patch,realtime_support)
	$(call ros2_patch,rmw_implementation)
	$(call ros2_patch,rosidl)
	$(call ros2_patch,rosidl_defaults)
	$(call ros2_patch,rosidl_typesupport)
	$(call ros2_patch,tinydir_vendor)
	$(call ros2_patch,console_bridge_vendor)
	$(call ros2_patch,rmw_fastrtps_shared_cpp)
	$(call ros2_patch,tlsf_cpp)
	@$(MAKE_STAMP)

ros2.configure: ros2.patch
	@$(call echo_action,Configuring,$*)

	@# Ignore copyleft packages
	@$(call ros2_ignorepkg,ros_visualization)
	@$(call ros2_ignorepkg,rviz)
	@$(call ros2_ignorepkg,poco_vendor)
	@$(call ros2_ignorepkg,osrf_testing_tools_cpp)
	@$(call ros2_ignorepkg,orocos_kinematics_dynamics)
	@$(call ros2_ignorepkg,ros_planning)
	@$(call ros2_ignorepkg,rmw_connext)
	@$(call ros2_ignorepkg,rosidl_typesupport_connext)
	@$(call ros2_ignorepkg,rmw_opensplice)
	@$(call ros2_ignorepkg,rosidl_typesupport_opensplice)
	@$(call ros2_ignorepkg,ament_lint)
	@$(call ros2_ignorepkg,uncrustify_vendor)
	@$(call ros2_ignorepkg,rcl_logging_log4cxx)

	@# Ignore Python-specific packages
	@$(call ros2_ignorepkg,ament_cmake_pytest)
	@$(call ros2_ignorepkg,osrf_pycommon)
	@$(call ros2_ignorepkg,demo_nodes_py)
	@$(call ros2_ignorepkg,tf2_py)
	@$(call ros2_ignorepkg,kdl_parser_py)
	@$(call ros2_ignorepkg,rclpy)
	@$(call ros2_ignorepkg,rosidl_generator_py)
	@$(call ros2_ignorepkg,rqt_gui_py)
	@$(MAKE_STAMP)

ros2.build: ros2.configure
	@$(call echo_action,Building,$*)
	cd $(BUILD_DIR)/ros2/$(ros2_BUILD_DIR); \
	export WIND_ROOT_DIR=$(ROOT_DIR); \
        colcon build --symlink-install --cmake-force-configure --packages-up-to $(ros2_EXAMPLES) \
		pendulum_control \
		--cmake-args \
                -DCMAKE_BUILD_TYPE:STRING=$(ros2_BUILD_TYPE) \
                -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
                -DCMAKE_MODULE_PATH:PATH=$(CMAKE_MODULE_DIR) \
                -DCMAKE_TOOLCHAIN_FILE:FILEPATH=$(CMAKE_MODULE_DIR)/rtp.cmake \
                -DBUILD_TESTING:BOOL=OFF
	@$(MAKE_STAMP)


ros2.install : ros2.build
	@$(call echo_action,Installing,$*)
	cd $(BUILD_DIR)/ros2/$(unixextra_BUILD_DIR) && \
	echo "MAKE_OPT: $(ros2_MAKE_OPT)" && \
	export MAKEFLAGS='$(FILTERED_MAKEFLAGS)' &&  \
	$(ros2_MAKE_INSTALL_VAR) $(MAKE) -C $(BUILD_DIR)/unixextra/$(unixextra_BUILD_DIR) -f $(BUILD_DIR)/unixextra/$(unixextra_SRC_DIR)/Makefile $(unixextra_MAKE_INSTALL_OPT) $(unixextra_MAKE_OPT)
	@$(MAKE_STAMP)
