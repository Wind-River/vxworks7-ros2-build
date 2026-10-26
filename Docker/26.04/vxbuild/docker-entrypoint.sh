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

export GID
export GROUP
export HOME
export INSTALL_DIR
export SITE
export HOSTREF
export UID
export USER
export WRENV
export WORKSPACE_DIR

# set -e

INIT_STAMP=/.initialized

if [ ! -f ${INIT_STAMP} ]; then
    # Remove the existing ubuntu user and group if they exist
    if id -u ubuntu >/dev/null 2>&1; then
	userdel -r ubuntu 2>/dev/null || true
    fi
    if getent group ubuntu >/dev/null 2>&1; then
	groupdel ubuntu 2>/dev/null || true
    fi

    # Recreate your group
    groupadd --gid "${GID}" "${GROUP}" 2>/dev/null

    # Ensure /home exists
    mkdir -p /home
    export HOME="/home/${USER}"
 
    # Recreate user
    useradd --create-home --shell /bin/bash --uid "${UID}" --gid "${GID}" --home-dir "${HOME}" "${USER}"

    mkdir -p ${INSTALL_DIR}
    chown ${UID}:${GID} ${INSTALL_DIR}
    chmod 755 ${INSTALL_DIR}

    mkdir -p ${WORKSPACE_DIR}
    chown ${UID}:${GID} ${WORKSPACE_DIR}
    chmod 755 ${WORKSPACE_DIR}

    touch ${INIT_STAMP}

    # Check if the container is interactive
    tty > /dev/null
    if [ $? -eq 0 ]; then
        # echo "(interactive shell with pty)"
        su -p -s /bin/bash ${USER}
    else
        # echo "(not interactive with pty)"
        su -c "$*" -p ${USER}
    fi
fi
