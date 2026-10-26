#!/bin/bash

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

INSTALL_DIR=${INSTALL_DIR:-/opt/windriver}
WRENV=${WRENV:-vxworks-7}

eval $(${INSTALL_DIR}/wrenv.sh -p ${WRENV} -o print_env -f sh)

WORKSPACE=${WORKSPACE:-${WIND_HOME}/workspace}

echo "VxBuild Example"
echo
cat <<EOF
This example demonstrates how to write a script that uses the ${WRENV} build environment
to automate a build inside a container.

WIND_HOME:   ${WIND_HOME}
WIND_BASE:   ${WIND_BASE}
LICENSE_DIR: ${WRSD_LICENSE_FILE}
WRENV:       ${WRENV}
WORKSPACE    ${WORKSPACE}
EOF

# Abort the script on failure
set -e

mkdir -p ${WORKSPACE}
cd ${WORKSPACE}
export WIND_WRTOOL_WORKSPACE=${WORKSPACE}

# Show each command as it is executed
set -x

# Create a VSB
wrtool prj vsb create -bsp vxsim_linux -S VxSimVSBwrtool

# Build a VSB
wrtool prj build VxSimVSBwrtool

# Create the VIP
wrtool prj vip create -vsb VxSimVSBwrtool vxsim_linux llvm VxSimVIPwrtool -profile PROFILE_DEVELOPMENT

# Add components to the VIP
wrtool prj vip component add VxSimVIPwrtool INCLUDE_STANDALONE_SYM_TBL
wrtool prj vip component add VxSimVIPwrtool INCLUDE_POSIX_PTHREAD_SCHEDULER
wrtool prj vip component add VxSimVIPwrtool INCLUDE_CORE_DUMP_RTP
wrtool prj vip component add VxSimVIPwrtool INCLUDE_CORE_DUMP_RTP_FS

# Build the VIP
wrtool prj build VxSimVIPwrtool

# Create an RTP
wrtool prj rtp create -vsb VxSimVSBwrtool myRTPwrtool

# Build the RTP
wrtool prj build myRTPwrtool
