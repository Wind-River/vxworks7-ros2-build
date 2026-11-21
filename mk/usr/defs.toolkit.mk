# defs.toolkit.mk - variables + the `toolkit` target.
#
# Yocto-style: just as `make image` packs ros2.img and `make fs` lays out the
# deploy tree, `make toolkit` assembles the self-contained ROS 2 VxWorks SDK
# *delivery kit* - an overlay for a vanilla Wind River SDK + the prebuilt ROS 2
# SDK (export/root) + export/deploy + ros2.img + scripts + manifest - and tars
# it. A downstream developer brings their own vanilla SDK, applies the overlay,
# and builds/runs ROS 2 apps for VxWorks.
#
# Included from the top-level Makefile (alongside defs.common/packages/vxworks/
# python). Depends on vars from those: TOP_BUILDDIR, EXPORT_DIR, ROOT_DIR,
# DEPLOY_DIR, PACKAGE_DIR, BUILDSPECS_DIR, ROS_DISTRO, WIND_RELEASE_ID,
# TGT_ARCH, SDK_NAME (defs.vxworks.mk: from the SDK, or from the SDK overlay).

# --- toolkit layout / naming ------------------------------------------------
# TOOLKIT_SRC_DIR = the committed kit tooling in the repo (scripts, host-shims,
#                   devcontainer, vscode, README, make-toolkit.sh).
# TOOLKIT_BUILD   = where the kit is staged + tarred (under output/).
TOOLKIT_SRC_DIR ?= $(CURDIR)/toolkit
TOOLKIT_BUILD   ?= $(TOP_BUILDDIR)/toolkit-build
TOOLKIT_NAME    ?= toolkit-$(WIND_RELEASE_ID)-$(ROS_DISTRO)-$(TGT_ARCH)
TOOLKIT_STAGE   ?= $(TOOLKIT_BUILD)/$(TOOLKIT_NAME)
TOOLKIT_TARBALL ?= $(TOP_BUILDDIR)/$(TOOLKIT_NAME).tar.zst
TOOLKIT_ASSEMBLE?= $(TOOLKIT_SRC_DIR)/make-toolkit.sh

# Compression: zstd if present, else gzip (.tar.gz).
TOOLKIT_ZSTD    := $(shell command -v zstd 2>/dev/null)

# Layer pin for the manifest. Mirrors pkg/ros2/Makefile defaults so the kit
# records the same url/branch the build used. Override to match a custom build.
TOOLKIT_LAYER_URL       ?= https://github.com/Wind-River/vxworks7-layer-for-ros2.git
TOOLKIT_LAYER_COMMIT_ID ?= $(ROS_DISTRO)-release-$(WIND_RELEASE_ID)
TOOLKIT_LAYER_COMMIT    ?=

# --- the target -------------------------------------------------------------
# toolkit CONSUMES the already-built artifacts (export/root, the SDK overlay and
# ros2.img); building them is NOT its job. It is intentionally decoupled from
# the `image`/`fs` targets so the caller (CI, or a local `make image && make
# toolkit`) owns producing ros2.img. toolkit/make-toolkit.sh verifies ros2.img
# exists at $(TOP_BUILDDIR)/ros2.img and fails with a clear message otherwise,
# so this stays declarative and does not rebuild the image.
#
# The `toolkit` phony target lives in the top-level Makefile and calls the
# build_toolkit macro below; toolkit-clean / toolkit-info stay here with the vars.
.PHONY: toolkit-clean toolkit-info

# build_toolkit - run the kit assembler (make-toolkit.sh) with the build vars in
# its environment. No args. Consumes export/root, export/deploy, ros2.img.
define build_toolkit
	@$(ECHO) "📦 Assembling ROS 2 VxWorks SDK toolkit: $(TOOLKIT_NAME)"
	TOP_BUILDDIR="$(TOP_BUILDDIR)" \
	EXPORT_DIR="$(EXPORT_DIR)" ROOT_DIR="$(ROOT_DIR)" DEPLOY_DIR="$(DEPLOY_DIR)" \
	PACKAGE_DIR="$(PACKAGE_DIR)" BUILDSPECS_DIR="$(BUILDSPECS_DIR)" \
	ROS_DISTRO="$(ROS_DISTRO)" WIND_RELEASE_ID="$(WIND_RELEASE_ID)" \
	TGT_ARCH="$(TGT_ARCH)" SDK_NAME="$(SDK_NAME)" \
	SDK_OVERLAY_STAGE="$(SDK_OVERLAY_STAGE)" \
	PKG_LAYER_URL="$(TOOLKIT_LAYER_URL)" \
	PKG_LAYER_COMMIT_ID="$(TOOLKIT_LAYER_COMMIT_ID)" \
	PKG_LAYER_COMMIT="$(TOOLKIT_LAYER_COMMIT)" \
	TOOLKIT_SRC_DIR="$(TOOLKIT_SRC_DIR)" TOOLKIT_STAGE="$(TOOLKIT_STAGE)" \
	TOOLKIT_TARBALL="$(TOOLKIT_TARBALL)" \
	    bash "$(TOOLKIT_ASSEMBLE)"
	@$(ECHO) "✅ toolkit: $(TOOLKIT_TARBALL)"
endef

toolkit-clean:
	@rm -rf $(TOOLKIT_BUILD) $(TOOLKIT_TARBALL) $(TOP_BUILDDIR)/$(TOOLKIT_NAME).tar.gz

toolkit-info:
	@$(ECHO) "TOOLKIT_SRC_DIR:    $(TOOLKIT_SRC_DIR)"
	@$(ECHO) "TOOLKIT_NAME:       $(TOOLKIT_NAME)"
	@$(ECHO) "TOOLKIT_STAGE:      $(TOOLKIT_STAGE)"
	@$(ECHO) "TOOLKIT_TARBALL:    $(TOOLKIT_TARBALL)"
	@$(ECHO) "assembler:          $(TOOLKIT_ASSEMBLE)"
	@$(ECHO) "zstd:               $(if $(TOOLKIT_ZSTD),$(TOOLKIT_ZSTD),<none, will use gzip>)"
