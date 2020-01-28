#!/bin/bash

# vip-patch.sh shell script to patch VIP sources
#
# Copyright (c) 2020 Wind River Systems, Inc.
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
# 28jan20,akh  created

set -x 

LOCAL_DIR=$(dirname $(readlink -f $0))
if [ ! -f "${LOCAL_DIR}/common.inc" ]; then
	echo "Cannot find ${LOCAL_DIR}/common.inc"
	exit 1
fi
cd ${LOCAL_DIR}
source common.inc

setup_env

check_vars WORKSPACE VIP_NAME
cd_dir ${WORKSPACE}/${VIP_NAME}

echo "Patching the VIP ${VIP_NAME}"

if [ -n "$(LC_ALL=C type -t ${BOARD}_patch)" ] && [ "$(LC_ALL=C type -t ${BOARD}_patch)" = function ]; then ${BOARD}_patch; else echo ${BOARD}_patch is NOT a function; fi

