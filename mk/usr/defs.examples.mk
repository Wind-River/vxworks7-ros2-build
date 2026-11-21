# defs.examples.mk - the `examples` target: build the example container images.
#
# Included from the top-level Makefile. The `examples` phony target lives there
# and calls the build_examples macro below (after `fs`). Depends on: DEPLOY_DIR,
# STAMP_DIR, TOUCH (defs.common.mk) and buildah on the host.

# build_examples - buildah bud every examples/Dockerfile.<tag> against the
# deploy tree, tagging each image <tag>. No args.
define build_examples
	@set -e; \
	for f in examples/Dockerfile.*; do \
		tag=$$(basename $$f | cut -d. -f2); \
		echo "🚧 Building image for '$$tag'..."; \
		buildah bud \
			--arch amd64 \
			--os vxworks \
			-f $$f \
			-t $$tag $(DEPLOY_DIR); \
	done;
	@echo "✅ All example images built successfully!"
	$(TOUCH) $(STAMP_DIR)/examples.build
endef
