# defs.image.mk - the `image` phase: pack the bootable FAT32 ros2.img.
#
# Stamp-aware: the real target is the $(TOP_BUILDDIR)/ros2.img FILE, with the
# per-package *.deploy stamps as prerequisites. The `image` phony alias (in the
# top-level Makefile) first runs `fs` (to refresh those stamps) and then rebuilds
# ros2.img ONLY when a *.deploy stamp is newer than the image -- same "up to date"
# discipline as the package steps, so repeated `make image` / `make toolkit` no
# longer re-dd the image when nothing changed.
#
# Included from the top-level Makefile. Depends on: TOP_BUILDDIR, DEPLOY_DIR,
# STAMP_DIR, DEFAULT_BUILD. It only packs export/deploy as `make fs` left it.
# The `image` phony target itself is declared in the top-level Makefile, which
# calls the build_fs macro defined below via the $(ROS2_IMG) file rule.

IMAGE_DEPLOY_STAMPS = $(addprefix $(STAMP_DIR)/,$(addsuffix .deploy,$(DEFAULT_BUILD)))
ROS2_IMG           ?= $(TOP_BUILDDIR)/ros2.img

# build_fs - pack a bootable FAT32 image from $(TOP_BUILDDIR)/export/deploy.
#   $(1) = output image path
# Same body as before, just factored into a reusable macro so the `image` target
# (in the top-level Makefile) is a thin `$(call build_fs,...)`. Defined here,
# next to the image vars, matching the other mk/usr macros (python_prepare_deploy,
# pkg_* in defs.autotools.mk).
define build_fs
	mkdir -p $(dir $(1))
	dd if=/dev/zero of=$(1) count=2048 bs=1M
	mkfs.vfat -F 32 $(1)
	mkdir -p $(TOP_BUILDDIR)/mount
	fusefat -o rw+ $(1) $(TOP_BUILDDIR)/mount
	cp --no-preserve=ownership -r -L $(TOP_BUILDDIR)/export/deploy/* $(TOP_BUILDDIR)/mount/. 2>/dev/null
	fusermount -u $(TOP_BUILDDIR)/mount
endef

# Stamp-aware file rule: rebuild ros2.img only when a *.deploy stamp is newer.
# The `image` phony alias lives in the top-level Makefile and depends on
# `fs $(ROS2_IMG)`, so `make image` refreshes stamps then (re)packs via build_fs.
$(ROS2_IMG): $(IMAGE_DEPLOY_STAMPS)
	$(call build_fs,$(ROS2_IMG))
