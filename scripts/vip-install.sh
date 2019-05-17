#!/bin/bash

# vip-install.sh shell script to install a VIP
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
    echo "Cannot found ${LOCAL_DIR}/common.inc"
    exit 1
fi
cd ${LOCAL_DIR}
source common.inc

setup_env

check_vars WORKSPACE ROOTFS_NAME VIP_NAME
cd_dir ${WORKSPACE}/${ROOTFS_NAME}

echo "Installing the VIP"
cp ${WORKSPACE}/${VIP_NAME}/default/vxWorks EFI/BOOT/bootapp.sys
