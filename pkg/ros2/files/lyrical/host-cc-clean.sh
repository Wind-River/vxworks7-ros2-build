#!/bin/bash
# Host build-script linker for cargo cross-builds (rclrs / ament_cargo packages).
#
# colcon-ros-cargo runs cargo with the ROS 2 install lib dir on LD_LIBRARY_PATH
# (so the target libs are found). But cargo also compiles each crate's *build
# script* for the HOST and links it with the host /usr/bin/ld. If the ROS 2
# install lib dir (full of VxWorks .so files) is on LD_LIBRARY_PATH, the host
# linker's own loader pulls a VxWorks soname (e.g. libc.so.1) and fails to start:
#   /usr/bin/ld: error while loading shared libraries: libc.so.1
#
# This wrapper strips the ROS 2 install lib dir from LD_LIBRARY_PATH, then calls
# the host cc. Point cargo's host linker at it:
#   CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=<this script>
#
# ROS2_INSTALL_LIB is exported by ros2.build (= $(ROOT_DIR)/lib). If unset, the
# wrapper is a transparent pass-through to cc.
clean=$(echo "${LD_LIBRARY_PATH}" | tr ':' '\n' | grep -v -F "${ROS2_INSTALL_LIB:-__none__}" | paste -sd:)
export LD_LIBRARY_PATH="$clean"
exec /usr/bin/cc "$@"
