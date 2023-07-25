#!/bin/sh

set -e

# Copyright (c) 2023 Wind River Systems, Inc.
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

# Validate number of arguments
if [ $# -lt 4 ] || [ $# -gt 5 ]; then
    echo "Usage: $0 <SDK_DIR> <OCI_IMG_DIR> <VXC_ARCH> <TOOL> [PACKAGE_PATH]"
    echo "   eg. $0 /opt/wrsdk/wrsdk-vxworks7-raspberrypi4b-1.2 helloworld.build arm64 llvm"
    exit 1
fi

SDK_DIR=$1
OCI_IMG_DIR=$2
VXC_ARCH=$3
TOOL=$4
PACKAGE_PATH=${5:-"build/ros2/ros2_ws/build/my_package/my_package"}

# Validate SDK_DIR
if [ ! -d "$SDK_DIR" ]; then
    echo "SDK_DIR doesn't exist: $SDK_DIR"
    exit 1
fi

# Determine file extension based on OS
EXTENSION=""
if [ "$(uname)" != "Linux" ]; then
    EXTENSION=".exe"
fi

DEPLOY="$SDK_DIR/vxsdk/sysroot/usr/3pp/deploy"

echo "building $OCI_IMG_DIR for $VXC_ARCH in $SDK_DIR"

# Make sure the target directory exists
mkdir -p "$OCI_IMG_DIR/rootfs"

# Copy the deploy directory
if [ ! -d "$DEPLOY" ]; then
    echo "Directory not found: $DEPLOY"
    exit 1
fi

cp -av "$DEPLOY/"* "$OCI_IMG_DIR/rootfs/"

# Copy the package
if [ ! -f "$PACKAGE_PATH" ]; then
    echo "File not found: $PACKAGE_PATH"
    exit 1
fi

cp "$PACKAGE_PATH" "$OCI_IMG_DIR/rootfs/usr/bin"
