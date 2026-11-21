#!/usr/bin/env bash
# make-toolkit.sh - assemble the ROS 2 VxWorks SDK delivery toolkit (the `toolkit`
# recipe). Invoked by `make toolkit` (mk/usr/defs.toolkit.mk) with these vars in
# the environment:
#
#   TOP_BUILDDIR EXPORT_DIR ROOT_DIR PACKAGE_DIR BUILDSPECS_DIR
#   ROS_DISTRO WIND_RELEASE_ID TGT_ARCH SDK_NAME
#   SDK_OVERLAY_STAGE TOOLKIT_SRC_DIR TOOLKIT_STAGE TOOLKIT_TARBALL
#
# It reads no SDK files: everything SDK-specific comes from the SDK overlay.
#
# It stages a self-contained toolkit:
#   sdk-overlay/      - the SDK overlay (a build output of 'make sdk-overlay':
#                       files/, sdk-patches/, sdk_overlay.json, install-sdk-overlay.sh)
#   export/root       - the prebuilt ROS 2 SDK (build apps against this)
#   ros2.img          - bootable VxWorks target image (CONTAINS the target rootfs
#                       that would otherwise be export/deploy; not shipped loose)
#   scripts/ host-shims/ .devcontainer/ .vscode/ README.md  - committed tooling
#   manifest.json     - build recipe (keys == Makefile vars) + layer pin
# then tars it to $TOOLKIT_TARBALL.
set -euo pipefail

log()  { printf '  toolkit: %s\n' "$*"; }
die()  { printf 'toolkit FAILED: %s\n' "$*" >&2; exit 1; }
need() { [ -n "${!1:-}" ] || die "env var $1 is required (run via 'make toolkit')"; }

for v in TOP_BUILDDIR EXPORT_DIR ROOT_DIR PACKAGE_DIR BUILDSPECS_DIR \
         ROS_DISTRO SDK_NAME SDK_OVERLAY_STAGE \
         TOOLKIT_SRC_DIR TOOLKIT_STAGE TOOLKIT_TARBALL; do need "$v"; done

STAGE="$TOOLKIT_STAGE"

# ---------------------------------------------------------------------------
log "staging at $STAGE"
rm -rf "$STAGE"; mkdir -p "$STAGE"

# --- 1) sdk-overlay/ (a build output: make sdk-overlay) ----------------------
log "1) sdk-overlay/ (copying the build's SDK overlay)"
[ -x "$SDK_OVERLAY_STAGE/install-sdk-overlay.sh" ] \
  || die "SDK overlay missing ($SDK_OVERLAY_STAGE) - run 'make sdk-overlay'"
cp -a "$SDK_OVERLAY_STAGE" "$STAGE/sdk-overlay"

# --- 2) the ROS 2 SDK: export/root + ros2.img ------------------------------
# NOTE: export/deploy is deliberately NOT shipped separately -- it is already
# inside ros2.img (make image packs it there). Shipping it loose would duplicate
# the whole target rootfs. extract-deploy.sh can recover it from ros2.img if a
# user ever needs the loose tree.
log "2) export/root + ros2.img (copying built artifacts)"
[ -d "$ROOT_DIR" ]              || die "export/root missing ($ROOT_DIR) - run 'make'"
[ -f "$TOP_BUILDDIR/ros2.img" ] || die "ros2.img missing - run 'make image'"
mkdir -p "$STAGE/export"
cp -a "$ROOT_DIR"   "$STAGE/export/root"
cp -a "$TOP_BUILDDIR/ros2.img" "$STAGE/ros2.img"

# --- 3) committed tooling (scripts, shims, devcontainer, vscode, README) ----
log "3) scripts/ host-shims/ .devcontainer/ .vscode/ README.md"
cp -a "$TOOLKIT_SRC_DIR/scripts"       "$STAGE/scripts"
cp -a "$TOOLKIT_SRC_DIR/host-shims"    "$STAGE/host-shims"
cp -a "$TOOLKIT_SRC_DIR/.devcontainer" "$STAGE/.devcontainer"
cp -a "$TOOLKIT_SRC_DIR/.vscode"       "$STAGE/.vscode"
install -m0644 "$TOOLKIT_SRC_DIR/README.md" "$STAGE/README.md"
find "$STAGE/host-shims" -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true

# Rust (rclrs) workspace cargo-config template: ros2sdk-prepare.sh renders it to
# toolkit paths so a downstream `colcon build` resolves rclrs/rosidl_runtime_rs from
# the toolkit's export/root/share/*/rust. Only relevant if the build included Rust.
RUST_TMPL="$PACKAGE_DIR/ros2/files/$ROS_DISTRO/rust-cargo-config.toml.template"
if [ -f "$RUST_TMPL" ]; then
  install -D -m0644 "$RUST_TMPL" "$STAGE/scripts/rust-cargo-config.toml.template"
  log "   staged rust-cargo-config.toml.template (Rust/rclrs support)"
fi

# --- 4) manifest.json (keys == Makefile vars) + layer pin + build commit ----
log "4) manifest.json"
PKGMK="$PACKAGE_DIR/ros2/files/$ROS_DISTRO/packages.mk"
GENMANIFEST="$TOOLKIT_SRC_DIR/scripts/generate-manifest.py"
# build-repo provenance: the vxworks7-ros2-build commit + describe that produced
# this toolkit (so it can be checked out and re-run). Best-effort; empty if not a git
# tree. A '-dirty' suffix flags uncommitted changes at build time.
REPO_DIR="$(cd "$PACKAGE_DIR/.." && pwd)"
BUILD_COMMIT="$(git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null || true)"
BUILD_DESCRIBE="$(git -C "$REPO_DIR" describe --tags --always --dirty 2>/dev/null || true)"
if [ -f "$PKGMK" ] && [ -f "$GENMANIFEST" ]; then
  # generate-manifest.py positional args:
  #   mk ros_distro vx_rel vx_sdk arch layer_url layer_branch layer_commit \
  #   [rust_target] [build_commit] [build_describe]
  python3 "$GENMANIFEST" \
      "$PKGMK" \
      "$ROS_DISTRO" \
      "${WIND_RELEASE_ID:-unknown}" \
      "$SDK_NAME" \
      "${TGT_ARCH:-unknown}" \
      "${PKG_LAYER_URL:-https://github.com/Wind-River/vxworks7-layer-for-ros2.git}" \
      "${PKG_LAYER_COMMIT_ID:-$ROS_DISTRO-release-${WIND_RELEASE_ID:-}}" \
      "${PKG_LAYER_COMMIT:-}" \
      "${TGT_ARCH:-unknown}-wrs-vxworks" \
      "$BUILD_COMMIT" \
      "$BUILD_DESCRIBE" \
      > "$STAGE/manifest.json" \
    || log "   WARN: manifest generation failed (continuing)"
else
  log "   WARN: no packages.mk or generate-manifest.py - skipping manifest"
fi

# --- 5) RELEASE_NOTES.md (identity from manifest + curated caveats) ---------
log "5) RELEASE_NOTES.md"
NOTES_IN="$TOOLKIT_SRC_DIR/RELEASE_NOTES.in.md"
GENNOTES="$TOOLKIT_SRC_DIR/scripts/gen-release-notes.py"
if [ -f "$STAGE/manifest.json" ] && [ -f "$GENNOTES" ]; then
  python3 "$GENNOTES" "$STAGE/manifest.json" "$(basename "$STAGE")" "$NOTES_IN" \
      > "$STAGE/RELEASE_NOTES.md" \
    || log "   WARN: release-notes generation failed (continuing)"
else
  log "   WARN: no manifest.json or gen-release-notes.py - skipping RELEASE_NOTES.md"
fi

# --- 6) tar it --------------------------------------------------------------
log "6) packaging -> $TOOLKIT_TARBALL"
STAGE_PARENT="$(dirname "$STAGE")"
STAGE_BASE="$(basename "$STAGE")"
if command -v zstd >/dev/null 2>&1 && [[ "$TOOLKIT_TARBALL" == *.zst ]]; then
  tar -C "$STAGE_PARENT" -cf - "$STAGE_BASE" | zstd -19 -T0 -q -o "$TOOLKIT_TARBALL" -f
else
  GZ="${TOOLKIT_TARBALL%.zst}.gz"; GZ="${GZ%.tar.gz}.tar.gz"
  tar -C "$STAGE_PARENT" -czf "$GZ" "$STAGE_BASE"
  log "   (zstd absent) wrote $GZ"
fi

log "done. staged: $STAGE"
