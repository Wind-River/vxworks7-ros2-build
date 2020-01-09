#!/bin/bash

# prj-download.sh shell script to download project sources
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

echo "Downloading ${PRJ} repos"

if [ "x$PRJ_GIT_REPO" != "x" ]; then
	# download project dependencies vxWorks layers
	GIT_REPO="${PRJ_GIT_REPO}"
	GIT_BRANCH="${PRJ_GIT_BRANCH}"
	GIT_DIR="${WIND_PKGS_DIR_NAME}/${PRJ_GIT_DIR}"
	clone_repo ${WIND_BASE}/${GIT_DIR}
fi

# download prj sources
cd ${PRJ_WS}

${PRJ}_download
