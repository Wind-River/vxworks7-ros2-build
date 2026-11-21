# defs.info.mk - the `info` target: print the resolved build configuration.
#
# Included from the top-level Makefile. The `info` phony target lives there and
# calls the print_info macro below. Depends on the many vars set by
# defs.common/packages/vxworks/python.mk (DEFAULT_BUILD, WIND_*, *_DIR, ...).

# print_info - echo the resolved build configuration. No args.
define print_info
	@$(ECHO) "DEFAULT_BUILD:      $(DEFAULT_BUILD)"
	@$(ECHO) "WIND RELEASE:       $(WIND_RELEASE_ID)"
	@$(ECHO) "ROS DISTRO:         $(ROS_DISTRO)"
	@$(ECHO) "TARGET BSP:         $(TGT_BSP)"
	@$(ECHO) "TARGET ARCH:        $(TGT_ARCH)"
	@$(ECHO) "TARGET PYTHON:      Python3.$(TGT_PYTHON_MINOR)"
	@$(ECHO) "TARGET SOABI:       $(Python_SOABI)"
	@$(ECHO) "HOST PYTHON:        `which python3`"
	@$(ECHO) "CMAKE:              `which cmake`"
	@$(ECHO) "CARGO_HOME:         $(if $(CARGO_HOME),$(CARGO_HOME),<unset> (source sdkenv.sh -> rustenv.linux))"
	@$(ECHO) "RUST TARGET:        $(TGT_ARCH)-wrs-vxworks"
	@$(ECHO) "CCACHE:             $(if $(CCACHE_DIR),on (CCACHE_DIR=$(CCACHE_DIR)),off (set CCACHE_DIR to enable))"
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
endef
