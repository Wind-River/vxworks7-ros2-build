# Makefile - for ros2
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
# modification history
# --------------------
# 15nov19,rcw  created
# 12mar18,akh  created
#

# SYNOPSIS        automate the build of ROS 2
include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk
include $(WIND_USR_MK)/defs.ros2.mk

PACKAGES += ros2

PKG_NAME = ros2
PKG_VER = $(ROS_DISTRO)

PKG_LAYER_URL ?= https://github.com/Wind-River/vxworks7-layer-for-ros2.git
PKG_URL = $(PKG_LAYER_URL)

# layer branch is calculated as $(ROS_DISTRO)-release-$(WIND_RELEASE_ID)
ifeq ($(ROS_DISTRO),rolling)
PKG_LAYER_COMMIT_ID ?= $(ROS_DISTRO)-$(WIND_RELEASE_ID)
PKG_REPO_COMMIT_ID = $(ROS_DISTRO)
else
PKG_LAYER_COMMIT_ID ?= $(ROS_DISTRO)-release-$(WIND_RELEASE_ID)
PKG_REPO_COMMIT_ID = $(ROS_DISTRO)-release
endif

PKG_COMMIT_ID = $(PKG_LAYER_COMMIT_ID)

PKG_TYPE = git

PKG_REPO_URL = https://raw.githubusercontent.com/ros2/ros2/${PKG_REPO_COMMIT_ID}/${PKG_NAME}.repos
# The ros2-vendors manifest is fetched from the ros2-vendors org (per-distro branch),
# NOT kept as a local copy — mirrors how ros2.repos is pulled from ros2/ros2.
PKG_VENDORS_REPO_URL = https://raw.githubusercontent.com/ros2-vendors/ros2_vendors/$(ROS_DISTRO)/ros2_vendors.repos

PKG_LICENSE = BSD

PKG_BUILD_DIR = ros2_ws
PKG_SRC_DIR = patches

PKG_BUILD_TYPE := Debug

include $(PACKAGE_DIR)/ros2/files/$(ROS_DISTRO)/packages.mk

# ccache (opt-in): if CCACHE_DIR is set in the environment, wrap the compiler with
# ccache for faster rebuilds via CMAKE_<LANG>_COMPILER_LAUNCHER. Empty unless
# CCACHE_DIR is set, so default builds are unchanged. Set CCACHE_DIR (e.g.
# $HOME/.ccache-vxros2) to enable.
ifneq ($(CCACHE_DIR),)
ROS2_CCACHE_ENV = export CMAKE_C_COMPILER_LAUNCHER=ccache; \
	export CMAKE_CXX_COMPILER_LAUNCHER=ccache;
else
ROS2_CCACHE_ENV =
endif

# Drop empty elements from LD_LIBRARY_PATH (leading/trailing/duplicate ':') so the
# dynamic loader never falls back to the current working directory.
#
# Why this is needed: sdkenv.sh builds LD_LIBRARY_PATH as "<dir>:${LD_LIBRARY_PATH}"
# starting from an unset LD_LIBRARY_PATH, leaving a trailing ':' -- an empty path
# element, which the loader treats as the current directory. During the build make
# runs the compiler with CWD inside each package's build dir; for zstd_vendor that
# dir holds the freshly-built *VxWorks* libzstd.so.1. The host ccache links
# libzstd.so.1, so its loader would resolve that dependency from '.' = the VxWorks
# libzstd, which NEEDs libc.so.1 -> ccache dies with
# "libc.so.1: cannot open shared object file". (Only zstd_vendor builds a libzstd,
# which is why it was the only package to fail.) Applied in the build subshells
# below so colcon and every compiler it spawns get a clean path.
LD_PATH_SANITIZE = export LD_LIBRARY_PATH="$$(printf '%s' "$$LD_LIBRARY_PATH" | sed -E 's/::+/:/g; s/^://; s/:$$//')";

ros2.unpack: ros2.download
	@$(call echo_action,Unpacking,$*)
	$(call pkg_unpack,$(PKG_NAME))
	mkdir -p $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	mkdir -p src; \
	echo "Fetching + importing ros2.repos ($(PKG_REPO_COMMIT_ID))..."; \
	bash $(PACKAGE_DIR)/ros2/files/vcs_import_checked.sh --url "$(PKG_REPO_URL)" src $(PKG_NAME).repos; \
	echo "Fetching + importing ros2-vendors manifest..."; \
	bash $(PACKAGE_DIR)/ros2/files/vcs_import_checked.sh --url "$(PKG_VENDORS_REPO_URL)" src ros2-vendors.repos; \
	if ls $(PACKAGE_DIR)/ros2/files/$(ROS_DISTRO)/*.repos >/dev/null 2>&1; then \
		echo "Importing additional local repos..."; \
		for repo in $(PACKAGE_DIR)/ros2/files/$(ROS_DISTRO)/*.repos; do \
			echo "Importing $$(basename $$repo)"; \
			bash $(PACKAGE_DIR)/ros2/files/vcs_import_checked.sh --file "$$repo" src; \
		done; \
	fi
	# sqlite_vendor needs the VxWorks SQLite patches from the layer
	# (sqlite_vendor/usr_src). Layer branches without them keep the SDK sqlite.
	if ! ls $(BUILD_DIR)/$(PKG_NAME)/$(PKG_SRC_DIR)/sqlite_vendor/usr_src/0001-* >/dev/null 2>&1; then \
		touch $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/src/ros2-vendors/sqlite_vendor/COLCON_IGNORE 2>/dev/null || true; \
	fi
	@$(MAKE_STAMP)

ros2.patch: ros2.unpack
	@$(call echo_action,Patching,$*)
	$(call ros2_patch,$(ROS2_PATCH_DIRS))
	@$(MAKE_STAMP)

ros2.configure: ros2.patch
	@$(call echo_action,Configuring,$*)
	$(call ros2_ignore,$(ROS_IGNORE_DIRS))
	mkdir -p $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon/mixin/default;
	cp files/$(ROS_DISTRO)/*.mixin $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon/mixin/default/.;
	envsubst < files/$(ROS_DISTRO)/vxworks.mixin.template > $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon/mixin/default/vxworks.mixin
	# Rust (rclrs) cross-build support (ROS 2 specific). The VxWorks Rust toolchain
	# fixes (patched libloading under $(WIND_CC_SYSROOT)/usr/rust/vxworks-crates, and
	# the patched cargo-ament-build) are delivered by pkg/sdk. Here we only generate
	# the workspace cargo config (points [patch.crates-io] at the SDK's patched
	# libloading + sets the VxWorks link flags). The ROS 2 install libs no longer
	# land on the host LD_LIBRARY_PATH during the build (the ament library_path env
	# hook is suppressed for cross-builds -- see the ament_cmake CMAKE_CROSSCOMPILING
	# patch), so no host-linker strip wrapper is needed for cargo's build scripts.
	mkdir -p $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/src/.cargo
	ROOT_DIR=$(ROOT_DIR) ROS2_RUST_CRATES_DIR=$(WIND_CC_SYSROOT)/usr/rust/vxworks-crates \
	  envsubst < files/$(ROS_DISTRO)/rust-cargo-config.toml.template \
	  > $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/src/.cargo/config.toml
	@$(MAKE_STAMP)

ros2.build: ros2.configure
	@$(call echo_action,Building,$*)
	@echo "=== Phase 1: building ROS2_VENDORS before the workspace ==="
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	[ -f /etc/ssl/certs/ca-certificates.crt ] && export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt; \
	[ -d /etc/ssl/certs ] && export SSL_CERT_DIR=/etc/ssl/certs; \
	export COLCON_HOME=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon; \
	export COLCON_EXTENSION_BLOCKLIST=colcon_core.environment.library_path; \
	$(LD_PATH_SANITIZE) \
	$(ROS2_CCACHE_ENV) \
	colcon build --install-base $(ROOT_DIR) --merge-install \
	  --mixin $(ROS2_MIXINS) --packages-skip-build-finished --packages-up-to-regex $(ROS2_VENDORS)
	@echo "=== Phase 2: building the ROS2 workspace (only reached if Phase 1 succeeded) ==="
	cd $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR); \
	[ -f /etc/ssl/certs/ca-certificates.crt ] && export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt; \
	[ -d /etc/ssl/certs ] && export SSL_CERT_DIR=/etc/ssl/certs; \
	export COLCON_HOME=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon; \
	export COLCON_EXTENSION_BLOCKLIST=colcon_core.environment.library_path; \
	export CARGO_BUILD_TARGET=$(ROS2_RUST_TARGET); \
	$(LD_PATH_SANITIZE) \
	$(ROS2_CCACHE_ENV) \
	colcon build --install-base $(ROOT_DIR) --merge-install \
	  --mixin $(ROS2_MIXINS) --packages-skip-build-finished --packages-up-to-regex $(PKG_PKGS_UP_TO)
	@$(MAKE_STAMP)

ros2.install : ros2.build
	@$(call echo_action,Installing mixin,$*)
	cp -r $(BUILD_DIR)/$(PKG_NAME)/$(PKG_BUILD_DIR)/.colcon $(ROOT_DIR)
	@$(MAKE_STAMP)

ros2.deploy : ros2.install
	@$(call echo_action,Installing runtime dependencies,$*)
	# setuptools>=81 REMOVED the bundled pkg_resources; ROS2 Python entry points
	# import pkg_resources at runtime. Pin to 58.1.0 (matches the SDK cross-venv,
	# still ships pkg_resources) so it deploys to the target site-packages.
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) "setuptools==58.1.0"
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) catkin_pkg
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) empy==3.3.4
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) pyelftools
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) packaging
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) lark-parser
	# rclpy.qos imports typing_extensions (TypeAlias); pure-python, must ship to target.
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) "typing_extensions==4.12.2"
	# launch_ros imports osrf_pycommon (process utils); pure-python, not in the ws source.
	pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) "osrf-pycommon==2.0.2"
	@$(call echo_action,Installing build artifacts,$*)
	# Dereference symlinks here (-L) so the deploy tree is symlink-free; FAT/mcopy
	# cannot store symlinks, and doing it once at deploy lets the image step use a
	# fast one-pass tree->FAT copy (no FUSE). --no-preserve=ownership: no host uid/gid.
	# Remove any stale symlinks first so a re-run's cp -rL writes real files (cp does
	# not replace an existing symlink's target).
	find $(DEPLOY_DIR)/bin $(DEPLOY_DIR)/lib -type l -delete 2>/dev/null || true
	cp -rL --no-preserve=ownership $(ROOT_DIR)/bin/* $(DEPLOY_DIR)/bin/.
	cp -rL --no-preserve=ownership $(ROOT_DIR)/lib/* $(DEPLOY_DIR)/lib/.
	cp -rL --no-preserve=ownership $(ROOT_DIR)/share $(DEPLOY_DIR)/.
	cp files/$(ROS_DISTRO)/vxscript.$(TGT_BSP) $(DEPLOY_DIR)/vxscript
	cp files/$(ROS_DISTRO)/cyclonedds.xml $(DEPLOY_DIR)/.
	@$(MAKE_STAMP)
	
include $(WIND_USR_MK)/rules.packages.mk

