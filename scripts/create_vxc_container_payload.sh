#!/bin/sh

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

set -e

# Validate number of arguments
if [ $# -gt 3 ]; then
    echo "Usage: $0 <SDK_DIR> <OCI_IMG_DIR> [PACKAGE_BIN]"
    echo "   eg. $0 /opt/wrsdk/wrsdk-vxworks7-raspberrypi4b-1.2 helloworld.build"
    exit 1
fi

SDK_DIR=${1:-"/home/$USER/Downloads/wrsdk"}
OCI_IMG_DIR=${2:-"./my_package.build"}
PACKAGE_BIN=${3:-"build/ros2/ros2_ws/build/my_package/my_package"}

# Make sure the package directory exists
if [ ! -f "$PACKAGE_BIN" ]; then
    echo "File not found: $PACKAGE_BIN"
    exit 1
fi

DEPLOY_DIR="$SDK_DIR/vxsdk/sysroot/usr/3pp/deploy"

# Make sure the deploy directory exists
if [ ! -d "$DEPLOY_DIR" ]; then
    echo "Directory not found: $DEPLOY_DIR"
    exit 1
fi

echo "building $OCI_IMG_DIR in $SDK_DIR"

# Create and check if the target directory exists
mkdir -p "$OCI_IMG_DIR/rootfs"
if [ ! -d "$OCI_IMG_DIR/rootfs" ]; then
    echo "Failed to create directory: $OCI_IMG_DIR/rootfs"
    exit 1
fi

# Copy the deploy directory
cp -av "$DEPLOY_DIR/"* "$OCI_IMG_DIR/rootfs/"

# Copy the package binary
cp "$PACKAGE_BIN" "$OCI_IMG_DIR/rootfs/usr/bin"