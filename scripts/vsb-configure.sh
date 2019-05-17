#!/bin/bash

# vsb-configure.sh shell script to configure a VSB
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

echo "Checking variables:"
for VARS in WORKSPACE VSB_NAME; do
    if [ -z "${!VARS}" ]; then
        echo "$VARS is not set."	
	exit 1
    fi
    echo "$VARS=${!VARS}"
done
echo

echo "Configuring the VSB ${VSB_NAME}"

cd ${WORKSPACE}/${VSB_NAME}
if [ $? -ne 0 ]; then
	echo "Could not change directory ${WORKSPACE}/${VSB_NAME}"
	exit 1
fi

# include standard layers
if [ ! -z "${VSB_LAYERS}" ]; then
	vxprj vsb add ${VSB_LAYERS}
	if [ $? -ne 0 ]; then
		echo "Could not add layer ${VSB_LAYERS}"
		exit 1
	fi
fi

if [ ! -z "${VSB_COMPONENTS_ADD}" ]; then
	for COMP in ${VSB_COMPONENTS_ADD}; do
		vxprj vsb config -s -add "${COMP}=y"
		if [ $? -ne 0 ]; then
			echo "Could not add component ${COMP}"
			exit 1
		fi
	done
fi

