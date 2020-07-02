export TOP_BUILDDIR=$(CURDIR)
export WIND_USR_MK=$(TOP_BUILDDIR)/mk/usr

include $(WIND_USR_MK)/defs.common.mk
include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.crossbuild.mk

DEFAULT_BUILD ?= sdk python unixextra asio tinyxml2 colcon ros2 turtlebot3

## Add missing variablse from SDK
export TOOL=llvm
export TGT_ARCH=$(shell $$CC -print-target-triple -c dummy.c | sed -e 's/arm64/aarch64/g')

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
	@rm -f $(TOP_BUILDDIR)/build/.stamp/*

distclean: clean
	@rm -rf $(DOWNLOADS_DIR)
	@rm -rf $(TOP_BUILDDIR)/build
	@rm -rf $(EXPORT_DIR)

clean: clean_buildstamps

info:
	@$(ECHO) "DEFAULT_BUILD: $(DEFAULT_BUILD)"
	@$(ECHO) "CURDIR: $(CURDIR)"
	@$(ECHO) "DOWNLOADS_DIR: $(DOWNLOADS_DIR)"
	@$(ECHO) "PACKAGE_DIR: $(PACKAGE_DIR)"
	@$(ECHO) "BUILD_DIR: $(BUILD_DIR)"
	@$(ECHO) "EXPORT_DIR: $(EXPORT_DIR)"
	@$(ECHO) "ROOT_DIR: $(ROOT_DIR)"
	@$(ECHO) "DEPLOY_DIR: $(DEPLOY_DIR)"


