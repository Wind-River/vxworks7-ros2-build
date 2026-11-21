export TOP_BUILDDIR?=$(CURDIR)/output
export WIND_USR_MK=$(CURDIR)/mk/usr
export PACKAGE_DIR=$(CURDIR)/pkg
export BUILDSPECS_DIR=$(CURDIR)/buildspecs

include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.vxworks.mk
include $(WIND_USR_MK)/defs.python.mk
include $(WIND_USR_MK)/defs.fs.mk
include $(WIND_USR_MK)/defs.image.mk
include $(WIND_USR_MK)/defs.sdk_overlay.mk
include $(WIND_USR_MK)/defs.toolkit.mk
include $(WIND_USR_MK)/defs.info.mk
include $(WIND_USR_MK)/defs.examples.mk

# The included modules define file rules (e.g. $(ROS2_IMG) in defs.image.mk)
# that make reads BEFORE `all` below; the first explicit rule would otherwise
# become the default goal. Pin it so a bare `make` always builds everything.
.DEFAULT_GOAL := all

ifeq ($(ROS_DISTRO),)
$(error Please export ROS_DISTRO)
endif

ifeq ($(WIND_RELEASE_ID),SR0640)
DEFAULT_BUILD ?= sdk python unixextra asio tinyxml2 colcon ros2 turtlebot3
else
ifeq ($(ROS_DISTRO),dashing)
DEFAULT_BUILD ?= sdk unixextra asio tinyxml2 colcon ros2 turtlebot3
else
DEFAULT_BUILD ?= sdk unixextra ros2
endif
endif

.PHONY: examples image fs sdk-overlay toolkit info

all: $(DOWNLOADS_DIR) $(STAMP_DIR) $(EXPORT_DIR)
	for p in $(DEFAULT_BUILD); do $(MAKE) -C pkg/$$p $$p.install || exit 1; done;

# fs - lay out export/deploy from the built packages and prepare it for the target
# (defs.fs.mk::fs_deploy, fs_prepare_deploy).
fs: all
	$(call fs_deploy)
	$(call fs_prepare_deploy)

# sdk-overlay - make the SDK overlay: output/sdk-overlay-build/<name>/ + the
# output/<name>.tar.zst archive (defs.sdk_overlay.mk::build_sdk_overlay).
sdk-overlay: all
	$(call build_sdk_overlay)

# The SDK overlay as a file prerequisite (its installer in the staging dir): made
# by `make sdk-overlay` when missing, used as is when present (e.g. the CI toolkit
# job, which downloads it instead of building).
$(SDK_OVERLAY_STAGE)/install-sdk-overlay.sh:
	$(MAKE) sdk-overlay

# image - pack the bootable FAT32 ros2.img (defs.image.mk::build_fs).
image: fs $(ROS2_IMG)

# toolkit - assemble the ROS 2 VxWorks SDK delivery kit (defs.toolkit.mk::build_toolkit).
toolkit: $(SDK_OVERLAY_STAGE)/install-sdk-overlay.sh
	$(call build_toolkit)

# examples - build the example container images (defs.examples.mk::build_examples).
examples: fs
	$(call build_examples)

# info - print the resolved build configuration (defs.info.mk::print_info).
info:
	$(call print_info)

$(EXPORT_DIR):
	@mkdir -p $(ROOT_DIR)
	@mkdir -p $(DEPLOY_DIR)/bin
	@mkdir -p $(DEPLOY_DIR)/lib

$(DOWNLOADS_DIR):
	@mkdir -p $(DOWNLOADS_DIR)

$(STAMP_DIR):
	@mkdir -p $(STAMP_DIR)

clean_buildstamps:
	for p in $(DEFAULT_BUILD); do rm -rf $(STAMP_DIR)/$$p.*; done;

distclean: clean
	@rm -rf $(DOWNLOADS_DIR)
	@rm -rf $(BUILD_DIR)
	@rm -rf $(EXPORT_DIR)

clean: clean_buildstamps
	for p in $(DEFAULT_BUILD); do rm -rf $(BUILD_DIR)/$$p; done;


