export TOP_BUILDDIR=$(CURDIR)
export WIND_USR_MK=$(TOP_BUILDDIR)/mk/usr

include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.vxworks.mk


ifeq ($(WIND_RELEASE_ID),SR0640)
DEFAULT_BUILD ?= sdk python unixextra asio tinyxml2 colcon ros2 turtlebot3
else
ifeq ($(ROS_DISTRO),dashing)
DEFAULT_BUILD ?= sdk unixextra asio tinyxml2 colcon ros2 turtlebot3
else
DEFAULT_BUILD ?= sdk unixextra asio tinyxml2 colcon ros2 pyyaml
endif
endif

.PHONY: clean_buildstamps

all: $(DOWNLOADS_DIR) $(STAMP_DIR) $(EXPORT_DIR)
	for p in $(DEFAULT_BUILD); do $(MAKE) -C pkg/$$p $$p.install || exit 1; done;

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

info:
	@$(ECHO) "DEFAULT_BUILD:      $(DEFAULT_BUILD)"
	@$(ECHO) "WIND RELEASE:       $(WIND_RELEASE_ID)"
	@$(ECHO) "ROS DISTRO:         $(ROS_DISTRO)"
	@$(ECHO) "TARGET ARCH:        $(TGT_ARCH)"
	@$(ECHO) "TARGET PYTHON:      Python3.$(TGT_PYTHON_MINOR)"
	@$(ECHO) "CURDIR:             $(CURDIR)"
	@$(ECHO) "DOWNLOADS_DIR:      $(DOWNLOADS_DIR)"
	@$(ECHO) "PACKAGE_DIR:        $(PACKAGE_DIR)"
	@$(ECHO) "BUILD_DIR:          $(BUILD_DIR)"
	@$(ECHO) "EXPORT_DIR:         $(EXPORT_DIR)"
	@$(ECHO) "ROOT_DIR:           $(ROOT_DIR)"
	@$(ECHO) "DEPLOY_DIR:         $(DEPLOY_DIR)"
	@$(ECHO) "WIND_CC_SYSROOT:    $(WIND_CC_SYSROOT)"
	@$(ECHO) "WIND_SDK_HOST_TOOLS:$(WIND_SDK_HOST_TOOLS)"
	@$(ECHO) "3PP_DEPLOY_DIR:     $(3PP_DEPLOY_DIR)"
	@$(ECHO) "3PP_DEVELOP_DIR:    $(3PP_DEVELOP_DIR)"


