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

SCRIPT_DIR=$(dirname $(readlink -f $0))
INSTALLER_FILE=${INSTALLER_FILE:-${PWD}/vxworks_7_r2_linux_*.zip}
INSTALL_DIR=${INSTALL_DIR:-/opt/windriver}
WRENV=${WRENV:-vxworks-7}
HOSTS=${HOSTS:-x86-linux2,x86-linux_64}

if [ "x${BASELINE}" != "x" ]; then
	case "${BASELINE}" in
	vxworks-7-[0-9]*)
		BASELINE_CMD=" -baseline ${BASELINE}"
		;;
	*)
		echo "The specified baseline ID ${BASELINE} is not valid."
		echo "Please enter a valid baseline ID or list all available baselines with setup_linux -baseline list."
		exit 1
		;;
	esac
fi

# SETUP_OPT=${SETUP_OPT:-'-site ${SITE} -hosts all -installer ${PWD} -basedir "${INSTALLER_URL}"'}
# ./setup_linux -repousername "$USERNAME" -repopassword "$PASSWORD" -silent -installerUpdateURLS none  -hosts all -relupdates -yum install --installroot="$install_dir" -y -vmargs -Dcom.windriver.installer.desktopicon=false -Dcom.windriver.installer.startmenu=false -Xmx512M
SETUP_OPT=${SETUP_OPT:- -repousername '${USERNAME}' -repopassword '${PASSWORD}' -silent -installerUpdateURLS none -hosts ${HOSTS}${BASELINE_CMD} -relupdates -yum install --installroot='${INSTALL_DIR}' -y -vmargs -Dcom.windriver.installer.desktopicon=false -Dcom.windriver.installer.startmenu=false -Xmx512M}

if [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ]; then
	echo "Both USERNAME and PASSWORD must be set."
	exit 1
fi

set -x

mkdir -p ${INSTALL_DIR}
if [ $? -ne 0 ]; then
	echo "Could not make directory ${INSTALL_DIR}"
	exit 1
fi

if [ -f "${INSTALLER_FILE}" ]; then
	echo "Could not find INSTALLER_FILE: ${INSTALLER_FILE}."
	exit 1
fi

INSTALLER_DIR=$(mktemp -d)
if [ -z "${INSTALLER_DIR}" ]; then
	echo "Could not create a temporary directory."
	exit 1
fi

unzip "${INSTALLER_FILE}" -d "${INSTALLER_DIR}"
if [ $? -ne 0 ]; then
	echo "Could not extract installer to ${INSTALLER_DIR}."
	exit 1
fi

if [ ! -f ${INSTALLER_DIR}/setup_linux ]; then
	echo "Could not find ${INSTALLER_DIR}/setup_linux"
	exit 1
fi

set +x
echo "+ ${INSTALLER_DIR}/setup_linux ${SETUP_OPT}"
eval ${INSTALLER_DIR}/setup_linux ${SETUP_OPT}
set -x

if [ $? -ne 0 ]; then
	echo "Could not run setup_linux."
	exit 1
fi

# bash -c 'eval `./wrenv.sh -p ${WRENV} -f sh -o print_env`; cd vxworks-7; make prebuilt_proj'
