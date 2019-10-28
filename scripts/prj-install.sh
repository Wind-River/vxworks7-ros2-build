#!/bin/bash

# prj-install.sh shell script to install a project
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

check_vars WORKSPACE ROOTFS_NAME VSB_NAME TOOL PRJ_WS

echo "Installing the ${PRJ} project"
cd ${WORKSPACE}/${ROOTFS_NAME}

# copy PRJ depenedencies built by the VSB

# some of the VSB libs are modified by the prj build
cp    ${WORKSPACE}/${VSB_NAME}/usr/root/${TOOL}/bin/*.so* romfs/lib/

# some of the VSB layers are installed under usr/root/lib
if [ -d ${WORKSPACE}/${VSB_NAME}/usr/root/lib/ ]; then
        cp    ${WORKSPACE}/${VSB_NAME}/usr/root/lib/*.so* romfs/lib/
fi

# copy PRJ libs and binaries to VSB
if [ -d ${PRJ_WS}/install ]; then
        find ${PRJ_WS}/install -name *.so* -exec cp {} romfs/lib/. \;
        find ${PRJ_WS}/install -name *.vxe -exec cp {} romfs/bin/. \;
        find ${PRJ_WS}/install -name *.urdf -exec cp {} romfs/bin/. \;
fi

