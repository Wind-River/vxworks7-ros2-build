# common.inc include file for the shell scripts
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

# default platform and tool
INSTALL_DIR=${INSTALL_DIR:-/opt/windriver}
PLATFORM=${PLATFORM:-vxworks-7}
WORKSPACE=${WORKSPACE:-${INSTALL_DIR}/workspace}
export WIND_WRTOOL_WORKSPACE="${WORKSPACE}"

# default project specific settings, can be overwritten in the corresponding cfg files
PRJ=${PRJ:-ros2small}
BOARD=${BOARD:-up}
TOOL=${TOOL:-llvm}
BUILD_TYPE=${BUILD_TYPE:-Release} # set to 'Debug' to build with -g

# default VIP settings
declare -A VIP_PARAMETERS_SET=()
VIP_BUNDLES_ADD="BUNDLE_STANDALONE_SHELL BUNDLE_RTP_DEPLOY"
if [ "${BUILD_TYPE}" == "Debug" ]; then
	VIP_BUNDLES_ADD="${VIP_BUNDLES_ADD} BUNDLE_EDR"
        VIP_COMPONENTS_ADD="INCLUDE_STAT_SYM_TBL INCLUDE_CORE_DUMP_RTP INCLUDE_RAM_DISK INCLUDE_XBD_RAMDRV INCLUDE_RAM_DISK_FORMAT_DOSFS INCLUDE_IPTELNETS INCLUDE_DEBUG_AGENT INCLUDE_DEBUG_AGENT_START INCLUDE_IPTFTPC INCLUDE_IPTFTP_CLIENT_CMD INCLUDE_NETSTAT"
        VIP_PARAMETERS_SET+=(["CORE_DUMP_RTP_FS_PATH"]="\"\\\"/ram0\\\"\"" ["RAM_DISK_SIZE"]=0x2000000)
fi

# calculate JOBS
num_cpus=$(grep -c "^processor" /proc/cpuinfo)
JOBS=$(echo ${num_cpus} '*' 2 + 1 | bc)

# include user specific settings if present
if [ -f `whoami`.inc ]; then
	source `whoami`.inc
fi

# include PRJ specific settings if present
if [ -f common-${PRJ}.inc ]; then
        source common-${PRJ}.inc
fi

# include PRJ native specific settings if present
if [ -f common-${PRJ}-native.inc ]; then
        source common-${PRJ}-native.inc
fi

# include BOARD specific settings if present
if [ -f ${BOARD}.inc ]; then
        source ${BOARD}.inc
fi

if [ -z ${PREFIX} ]; then
	PREFIX="${BOARD}_${PRJ}"
fi

# construct directory names
if [ -z ${VSB_NAME} ]; then
	VSB_NAME="${PREFIX}_vsb"
fi
export VSB_DIR=${WORKSPACE}/${VSB_NAME}

if [ -z ${VIP_NAME} ]; then
	VIP_NAME="${PREFIX}_vip"
fi

if [ -z ${ROOTFS_NAME} ]; then
	ROOTFS_NAME="${PREFIX}_rootfs"
fi

if [ -z ${VXSDK_NAME} ]; then
	VXSDK_NAME="${PREFIX}_vxsdk"
fi

if [ -z "${VXSDK_DEPLOY_DIR}" ]; then
        VXSDK_DEPLOY_DIR=${WORKSPACE}/${VXSDK_NAME}_deployed
fi

# project settings 
if [ -z "${PRJ_WS_NAME}" ]; then
        PRJ_WS_NAME="${PREFIX}_ws"
fi
PRJ_WS="${WORKSPACE}/${PRJ_WS_NAME}"

if [ -z "${PRJ_NATIVE_WS_NAME}" ]; then
        PRJ_NATIVE_WS_NAME="${BOARD}_${PRJ}_native_ws"
fi
PRJ_NATIVE_WS="${WORKSPACE}/${PRJ_NATIVE_WS_NAME}"

# setup VxWorks environment, no input params
setup_env()
{
	eval $(${INSTALL_DIR}/wrenv.sh -p ${PLATFORM} -o print_env -f sh)
}

# clone repo defined in GIT_REPO var before with GIT_BRANCH to the directory passed as a param
# if directory already exists tries to checkout GIT_BRANCH
clone_repo()
{
	if [ ! -d $@ ]; then
		mkdir -p -m 755 $@
		if [ $? -ne 0 ]; then
			echo "Could not make directory $@"
			exit 1
		fi
		git clone ${GIT_REPO} -b ${GIT_BRANCH} $@
		if [ $? -ne 0 ]; then
			echo "Could not clone git repository ${GIT_REPO}"
			exit 1
		fi
	else
		echo "directory ${GIT_REPO} already exist, try to checkout a branch ${GIT_BRANCH}"
		cd $@ && git checkout ${GIT_BRANCH}
		if [ $? -ne 0 ]; then
			echo "Could not checkout a branch ${GIT_BRANCH} of git repository ${GIT_REPO}"
			exit 1
		fi
	fi
}

build_layers()
{
	# build included layers separately, mind dependencies
	LAYERS=$@
	echo "Building LAYERS: ${LAYERS}"
	for LAYER in ${LAYERS}; do
		# get full name and check whether layer already added
		full_name=`vxprj vsb info ${LAYER} | grep "Full Name" | grep -Eo "${LAYER}.*"`
		if [ -z `vxprj vsb list | grep ${full_name}` ]; then
			vxprj vsb add ${LAYER}
			if [ -z `vxprj vsb list | grep ${full_name}` ]; then
				echo "Could not add layer ${LAYER}"
				exit 1
			fi
		fi

		# convert layer name to lower case
		layer=`echo "$LAYER" | tr '[:upper:]' '[:lower:]'`

		# check whether layer is already built
		if [ ! -f 3pp/.stamp/${layer}.install ]; then
			vxprj vsb build ${LAYER}
			if [ ! -f 3pp/.stamp/${layer}.install ]; then
				echo "Could not build layer ${LAYER}"
				exit 1
			fi
		fi
	done
}

check_vars()
{
	echo "Checking variables:"
	VARS=$@
	for VAR in ${VARS}; do
	    if [ -z "${!VAR}" ]; then
        	echo "$VAR is not set."
	        exit 1
	    fi
	    echo "$VAR=${!VAR}"
	done
	echo
}

cd_dir()
{
	DIR=$1
	cd ${DIR}
	if [ $? -ne 0 ]; then
        	echo "Could not change directory ${DIR}"
	        exit 1
	fi
}

bundle()
{
	cmd=$1
	shift;
	BUNDLES=$@
	for BUNDLE in ${BUNDLES}; do
		vxprj bundle ${cmd} ${BUNDLE}
		if [ $? -ne 0 ]; then
			echo "Could not ${cmd} bundle ${BUNDLE}"
			exit 1
		fi
	done
}

component()
{
	cmd=$1
	shift;
	COMPONENTS=$@
	for COMP in ${COMPONENTS}; do
		vxprj component ${cmd} ${COMP}
		if [ $? -ne 0 ]; then
			echo "Could not ${cmd} component ${COMP}"
			exit 1
		fi
	done
}

parameter()
{
	cmd=$1
	shift;
	eval "declare -A PARAMETERS="${1#*=}
	for param in "${!PARAMETERS[@]}"; do
		vxprj parameter set ${param} ${PARAMETERS[${param}]}
	done
}
