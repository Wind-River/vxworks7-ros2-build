# defs.sdk_overlay.mk - variables + the build_sdk_overlay macro for the
# `sdk-overlay` target (top-level Makefile).
#
# The SDK overlay is the set of changes that turns a vanilla VxWorks SDK into the
# SDK this build used: what pkg/sdk and pkg/unixextra change in the SDK (files,
# SDK files moved aside, host pip packages) plus the cmake toolchain. It is a
# build output like export/root and ros2.img, delivered like the toolkit: a
# staging directory and an archive.
#
#   $(SDK_OVERLAY_STAGE)/            files/                 (laid out like the SDK root)
#                                    sdk_overlay.json       (inventory, per build step)
#                                    install-sdk-overlay.sh (installs it into an SDK)
#   $(SDK_OVERLAY_TARBALL)           the same, archived
#
# mk/usr/make-sdk-overlay.sh makes it (<step>_overlay); mk/usr/install-sdk-overlay.sh
# installs it into an SDK (<step>_install), same steps, same order. `make toolkit`
# packs the staging directory.
#
# Included from the top-level Makefile. Depends on vars from defs.common/vxworks:
# TOP_BUILDDIR, PACKAGE_DIR, BUILDSPECS_DIR, WIND_CC_SYSROOT, WIND_SDK_HOME,
# WIND_RELEASE_ID, TGT_ARCH.

SDK_OVERLAY_NAME      ?= sdk-overlay-$(WIND_RELEASE_ID)-$(TGT_ARCH)
SDK_OVERLAY_BUILD     ?= $(TOP_BUILDDIR)/sdk-overlay-build
SDK_OVERLAY_STAGE     ?= $(SDK_OVERLAY_BUILD)/$(SDK_OVERLAY_NAME)
SDK_OVERLAY_TARBALL   ?= $(TOP_BUILDDIR)/$(SDK_OVERLAY_NAME).tar.zst
SDK_OVERLAY_GEN       ?= $(WIND_USR_MK)/make-sdk-overlay.sh
SDK_OVERLAY_INSTALLER ?= $(WIND_USR_MK)/install-sdk-overlay.sh

# build_sdk_overlay - make $(SDK_OVERLAY_STAGE) + $(SDK_OVERLAY_TARBALL) from the
# build inputs and the patched SDK. No args. Called by `make sdk-overlay`.
define build_sdk_overlay
	TOP_BUILDDIR="$(TOP_BUILDDIR)" PACKAGE_DIR="$(PACKAGE_DIR)" \
	BUILDSPECS_DIR="$(BUILDSPECS_DIR)" WIND_CC_SYSROOT="$(WIND_CC_SYSROOT)" \
	WIND_SDK_HOME="$(WIND_SDK_HOME)" WIND_RELEASE_ID="$(WIND_RELEASE_ID)" TGT_ARCH="$(TGT_ARCH)" \
	SDK_NAME="$(SDK_NAME)" \
	SDK_OVERLAY_STAGE="$(SDK_OVERLAY_STAGE)" SDK_OVERLAY_TARBALL="$(SDK_OVERLAY_TARBALL)" \
	SDK_OVERLAY_INSTALLER="$(SDK_OVERLAY_INSTALLER)" \
	    bash "$(SDK_OVERLAY_GEN)"
endef
