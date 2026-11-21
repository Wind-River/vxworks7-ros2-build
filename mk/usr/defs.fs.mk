# defs.fs.mk - the `fs` phase: lay out export/deploy from the built packages.
#
# `fs` runs each DEFAULT_BUILD package's `<pkg>.deploy` sub-make, which stages
# that package's runtime files into $(DEPLOY_DIR) and touches a per-package
# $(STAMP_DIR)/<pkg>.deploy stamp. Those stamps are what `image` (defs.image.mk)
# keys off to decide whether ros2.img needs repacking.
#
# Included from the top-level Makefile. Depends on: DEFAULT_BUILD, DEPLOY_DIR,
# STAMP_DIR (from defs.common/packages.mk), the `all` target and the
# python_prepare_deploy macro (defs.python.mk). The `fs` phony target lives in the
# top-level Makefile and calls fs_deploy, then fs_prepare_deploy, below.

# fs_deploy - stage each DEFAULT_BUILD package's runtime files into $(DEPLOY_DIR)
# (each sub-make touches its $(STAMP_DIR)/<pkg>.deploy stamp). No args.
define fs_deploy
	for p in $(DEFAULT_BUILD); do $(MAKE) -C pkg/$$p $$p.deploy || exit 1; done;
endef

# fs_prepare_deploy - prepare $(TOP_BUILDDIR)/export/deploy for the target: Python
# fast start and pruning of build/dev-only files. No args. After this, export/deploy
# is exactly what `image` packs.
define fs_prepare_deploy
	# Prepare the deployed python for the target (mk/usr/defs.python.mk ->
	# optimize-python-startup (pkg/sdk)): strip __pycache__ (build-time
	# caches may be host-arch, e.g. cpython-312), pre-compile unchecked-hash .pyc
	# so the target never recompiles on its slow FS, and rewrite the setuptools
	# EASY-INSTALL launchers in bin/ and lib/<pkg>/ to importlib.metadata (the
	# pkg_resources shims scan all *.dist-info at startup -- minutes on target).
	$(call python_prepare_deploy,$(TOP_BUILDDIR)/export/deploy)
	# Prune build/dev-only artifacts the TARGET never needs at runtime, to cut the
	# fusefat copy's per-file cost (file count dominates the FUSE write time).
	# KEEP *.dist-info / *.egg-info (ros2 run entry-point discovery reads them) and
	# the CPython stdlib test dir ($(TOP_BUILDDIR)/export/deploy/lib/python3.9/test).
	find $(TOP_BUILDDIR)/export/deploy \( -path '*/cmake/*' -o -name '*.cmake' \) -type f -delete
	# remove the now-empty cmake/ dir trees left behind (bottom-up, nested empties)
	find $(TOP_BUILDDIR)/export/deploy -depth -type d -path '*/cmake*' -empty -delete
	find $(TOP_BUILDDIR)/export/deploy/lib -type d \( -name test -o -name tests \) \
	    -not -path '*/python3.*/test' -not -path '*/python3.*/test/*' -exec rm -rf {} +
	find $(TOP_BUILDDIR)/export/deploy/lib -type d -name include -not -path '*/python3.*/*' -exec rm -rf {} +
	find $(TOP_BUILDDIR)/export/deploy \( -name '*.a' -o -name '*.pc' \) -type f -delete
endef
