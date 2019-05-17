#!/bin/bash

# vsb-create.sh shell script to create a VSB
#
# Copyright (c) 2018-2019 Wind River Systems, Inc.
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
# 12apr19,akh  modified
# 12jul18,rcw  created

set -x 

LOCAL_DIR=$(dirname $(readlink -f $0))
if [ ! -f "${LOCAL_DIR}/common.inc" ]; then
    echo "Cannot found ${LOCAL_DIR}/common.inc"
    exit 1
fi
cd ${LOCAL_DIR}
source common.inc

setup_env

if [ ! -d "${WORKSPACE}" ]; then
    echo "WORKSPACE does not refer to a directory (${WORKSPACE})"
    exit 1
fi

check_vars BSP VSB_NAME

echo "Creating the VSB ${VSB_NAME}"

cd_dir ${WORKSPACE}
if [ "${BUILD_TYPE}" == "Debug" ]; then
        DEBUG=-debug
fi
wrtool prj vsb create -force -S -bsp ${BSP} -cpu ${CPU} ${DEBUG} ${ADDRESS_MODE} ${VSB_NAME}
if [ $? -ne 0 ]; then
	echo "failed to create the VSB"
	exit 1
fi
