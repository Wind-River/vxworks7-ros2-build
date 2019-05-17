#!/bin/bash

# prj-build.sh shell script to build a project
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

echo "Building the ${PRJ} project dependencies: VxWorks layers"
check_vars WORKSPACE VSB_NAME
cd_dir ${WORKSPACE}/${VSB_NAME}

# a separate build done to workaround problems with layer build order
vxprj vsb add OSS_BUILD UNIX_EXTRA
make all JOBS=${JOBS}
build_layers ${PRJ_VSB_LAYERS}

# build libnet.so
LIB_FORMAT=shared vxprj vsb build IPNET_USRSPACE

echo "Building the ${PRJ} project"
cd ${PRJ_WS}

${PRJ}_build

