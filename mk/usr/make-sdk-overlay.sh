#!/usr/bin/env bash
# make-sdk-overlay.sh - generate the SDK overlay: the changes that turn a vanilla
# VxWorks SDK into the SDK this build used. Invoked by `make sdk-overlay`
# (mk/usr/defs.sdk_overlay.mk::build_sdk_overlay) with these vars in the environment:
#
#   TOP_BUILDDIR PACKAGE_DIR BUILDSPECS_DIR WIND_CC_SYSROOT WIND_SDK_HOME
#   WIND_RELEASE_ID TGT_ARCH SDK_NAME SDK_OVERLAY_STAGE SDK_OVERLAY_TARBALL SDK_OVERLAY_INSTALLER
#
# Output (a build output, like export/root and ros2.img):
#   $SDK_OVERLAY_STAGE/files/                  files to copy into the SDK, laid out
#                                              like the SDK root
#   $SDK_OVERLAY_STAGE/sdk-patches/            patches to apply to SDK files (pkg/sdk
#                                              sdk-patches) + apply-sdk-patches.sh
#   $SDK_OVERLAY_STAGE/sdk_overlay.json        inventory per step: those files, the
#                                              SDK files to move aside, pip packages
#   $SDK_OVERLAY_STAGE/install-sdk-overlay.sh  installs it into an SDK (<step>_install)
#   $SDK_OVERLAY_TARBALL                       the staging directory, archived
#
# One function per step that changes the SDK, named after that step, in the
# order the build runs them (pkg/sdk/files/<rel>/defs.sdk.mk, pkg/sdk/Makefile,
# pkg/unixextra/Makefile):
#
#   pkg/sdk  sdk.patch    -> sdk_patch   -> sdk_fix          sdk_fix_overlay
#                                         -> python_fix       python_fix_overlay
#            (defined, not called)           vxworks_fix      vxworks_fix_overlay
#            sdk.install  -> sdk_install                      sdk_install_overlay
#                                         -> rust_fix         rust_fix_overlay
#            sdk.deploy   -> sdk_deploy  (target image only)  -
#   pkg/unixextra  unixextra.install (+ default.conf edit)    unixextra_install_overlay
#   not a build step: buildspecs/cmake toolchain              toolchain_overlay
set -euo pipefail

log()  { printf '  sdk-overlay: %s\n' "$*"; }
die()  { printf 'sdk-overlay FAILED: %s\n' "$*" >&2; exit 1; }
need() { [ -n "${!1:-}" ] || die "env var $1 is required (run via 'make sdk-overlay')"; }

for v in TOP_BUILDDIR PACKAGE_DIR BUILDSPECS_DIR WIND_CC_SYSROOT WIND_SDK_HOME \
         WIND_RELEASE_ID TGT_ARCH SDK_NAME SDK_OVERLAY_STAGE SDK_OVERLAY_TARBALL SDK_OVERLAY_INSTALLER; do need "$v"; done

STAGE="$SDK_OVERLAY_STAGE"
OV="$STAGE/files"
SDK_OVERLAY_JSON="$STAGE/sdk_overlay.json"
HOSTBIN_REL="vxsdk/host/x86_64-linux/bin"
SYSROOT_REL="vxsdk/sysroot"
SDK_HOSTBIN="$WIND_SDK_HOME/$HOSTBIN_REL"
OV_HOSTBIN="$OV/$HOSTBIN_REL"
OV_SYSROOT="$OV/$SYSROOT_REL"
SDK_FILES="$PACKAGE_DIR/sdk/files"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
REMOVED_LIST="$WORK/removed"; : > "$REMOVED_LIST"
PATCH_LIST="$WORK/patches"; : > "$PATCH_LIST"
REQUIREMENTS="$WORK/requirements"; : > "$REQUIREMENTS"
GET_PIP="$WORK/get-pip-url"; : > "$GET_PIP"

# Each step function records the files it added (in $STEPS/<nn>-<step>), so the
# inventory lists them per step and ros2sdk-prepare.sh applies them per step.
STEPS="$WORK/steps"; mkdir -p "$STEPS"; STEP_NO=0
snapshot() { ( cd "$OV" && find . \( -type f -o -type l \) | sort ) > "$WORK/before"; }
record()   { # record <step>: save the files added since snapshot to $STEPS
  STEP_NO=$((STEP_NO + 1))
  ( cd "$OV" && find . \( -type f -o -type l \) | sort ) | comm -13 "$WORK/before" - \
    | sed 's#^\./##' > "$STEPS/$(printf '%02d' "$STEP_NO")-$1"
}
listed()   { tr '\n' ' ' < "$(ls "$STEPS"/*-"$1")"; }   # files recorded for <step>

# --- pkg/sdk sdk_fix ---------------------------------------------------------------
sdk_fix_overlay() {
  snapshot
  # defs.autotools.mk copied into the SDK's mk/
  install -D -m0644 "$SDK_FILES/defs.autotools.mk" "$OV_SYSROOT/mk/defs.autotools.mk"
  # SDK file edits: the patches themselves + the script sdk_fix applied them with
  # (pkg/sdk/files/apply-sdk-patches.sh), shipped in sdk-patches/ (not files/: they
  # are applied, not copied). Each must be applied in the build's SDK.
  local pd="$SDK_FILES/$WIND_RELEASE_ID/sdk-patches" pp
  mkdir -p "$STAGE/sdk-patches"
  install -m0755 "$SDK_FILES/apply-sdk-patches.sh" "$STAGE/sdk-patches/apply-sdk-patches.sh"
  for pp in "$pd"/*.patch; do
    [ -f "$pp" ] || continue
    patch -d "$WIND_SDK_HOME" -p1 -R --dry-run -s -f < "$pp" >/dev/null 2>&1 \
      || die "sdk_fix: $(basename "$pp") is not applied in $WIND_SDK_HOME (sdk_fix did not run?)"
    install -m0644 "$pp" "$STAGE/sdk-patches/"
    basename "$pp" >> "$PATCH_LIST"
  done
  # SDK sqlite/libyaml/libcyaml moved to 3pp/.removed/<tree>/: taken from what the
  # build actually moved
  local rm_root="$WIND_CC_SYSROOT/usr/3pp/.removed"
  if [ -d "$rm_root" ]; then
    ( cd "$rm_root" && find . -mindepth 2 \( -type f -o -type l \) ) | sed 's#^\./##' \
      | sed "s#^#$SYSROOT_REL/usr/3pp/#" | LC_ALL=C sort > "$REMOVED_LIST"
  fi
  record sdk_fix
  log "sdk_fix: $(listed sdk_fix)+ $(wc -l < "$REMOVED_LIST") SDK file(s) to move aside, patches: $(tr '\n' ' ' < "$PATCH_LIST")"
}

# --- pkg/sdk vxworks_fix ------------------------------------------------------------
# Defined in defs.sdk.mk but not called by sdk_patch: it changes nothing in the SDK.
vxworks_fix_overlay() {
  snapshot
  record vxworks_fix
  log "vxworks_fix: not called by sdk_patch, nothing"
}

# --- pkg/sdk python_fix -------------------------------------------------------------
python_fix_overlay() {
  snapshot
  # python3/python links to python3.9
  mkdir -p "$OV_HOSTBIN"
  ln -sf python3.9 "$OV_HOSTBIN/python3"
  ln -sf python3.9 "$OV_HOSTBIN/python"
  # pip: bootstrapped with get-pip.py, not a file here (the URL goes into the
  # inventory; install-sdk-overlay.sh runs it the same way)
  make -s --no-print-directory -C "$PACKAGE_DIR/sdk" sdk.get-pip-url > "$GET_PIP" \
    || die "python_fix: cannot read GET_PIP_URL from pkg/sdk"
  grep -qx 'https://[^ ]*' "$GET_PIP" || die "python_fix: GET_PIP_URL is not a URL: $(cat "$GET_PIP")"
  record python_fix
  log "python_fix: $(listed python_fix)+ pip via $(cat "$GET_PIP")"
}

# --- pkg/sdk sdk_install --------------------------------------------------------------
# pip install -r requirements.txt, shebang rewrite and crossenv are not files: the
# requirements go into the inventory, ros2sdk-prepare.sh runs pip and crossenv.
sdk_install_overlay() {
  snapshot
  local req="$SDK_FILES/$WIND_RELEASE_ID/requirements.txt"
  [ -f "$req" ] && cp "$req" "$REQUIREMENTS"
  # Python fast-start tool installed into the host bin
  install -D -m0755 "$SDK_HOSTBIN/optimize-python-startup" "$OV_HOSTBIN/optimize-python-startup"
  record sdk_install
  log "sdk_install: $(listed sdk_install)+ $(grep -cv '^\s*\(#\|$\)' "$REQUIREMENTS" || true) pip package(s) to install"
}

# --- pkg/sdk rust_fix (called by sdk_install) ---------------------------------------
rust_fix_overlay() {
  snapshot
  local rust="$WIND_CC_SYSROOT/usr/rust" ll="$WIND_CC_SYSROOT/usr/rust/vxworks-crates/libloading"
  if [ ! -f "$rust/.cargo/config.toml" ]; then
    record rust_fix
    log "rust_fix: no rust_fix files in the SDK (build without Rust)"
    return
  fi
  # patched libloading in usr/rust/vxworks-crates/
  if [ -d "$ll" ]; then
    mkdir -p "$OV_SYSROOT/usr/rust/vxworks-crates/libloading/src"
    cp -a "$ll/src/." "$OV_SYSROOT/usr/rust/vxworks-crates/libloading/src/"
    for f in Cargo.toml Cargo.lock LICENSE; do
      [ -f "$ll/$f" ] && cp -a "$ll/$f" "$OV_SYSROOT/usr/rust/vxworks-crates/libloading/$f"
    done
  fi
  # SDK cargo config from sdk-cargo-config-vxworks.toml.template
  install -D -m0644 "$rust/.cargo/config.toml" "$OV_SYSROOT/usr/rust/.cargo/config.toml"
  # patched cargo-ament-build in the host bin
  install -D -m0755 "$SDK_HOSTBIN/cargo-ament-build" "$OV_HOSTBIN/cargo-ament-build"
  record rust_fix
  log "rust_fix: $(listed rust_fix)"
}

# --- pkg/unixextra unixextra.install ------------------------------------------------
unixextra_install_overlay() {
  snapshot
  local stage="$WORK/unixextra"
  # install: unixextra's own install (pkg/unixextra unixextra.stage: same
  # options and SOURCES as unixextra.install) into a scratch DESTDIR
  mkdir -p "$stage"
  make -s --no-print-directory -C "$PACKAGE_DIR/unixextra" unixextra.stage UNIXEXTRA_DESTDIR="$stage" >/dev/null \
    || die "unixextra.stage failed (run 'make' first)"
  mkdir -p "$OV_SYSROOT"
  cp -a "$stage/usr" "$OV_SYSROOT/"
  # install copies the libunixextra.so symlink as a second file; keep it a symlink.
  ln -sf libunixextra.so.1 "$OV_SYSROOT/usr/lib/common/libunixextra.so"
  # sed: -lunixextra in the compiler driver's default link line
  grep -q 'lunixextra' "$WIND_CC_SYSROOT/cc-conf/default.conf" \
    || die "SDK default.conf has no -lunixextra (run 'make' first)"
  install -D -m0644 "$WIND_CC_SYSROOT/cc-conf/default.conf" "$OV_SYSROOT/cc-conf/default.conf"
  record unixextra.install
  log "unixextra.install: $(listed unixextra.install)"
}

# --- buildspecs/cmake (not a build step) --------------------------------------------
# The build passes buildspecs/cmake/toolchain.cmake directly (vxworks mixin); it
# never installs it into the SDK. A toolkit user gets it in the SDK's mk/, where
# ros2sdk-prepare.sh points the relocated mixin.
toolchain_overlay() {
  snapshot
  install -D -m0644 "$BUILDSPECS_DIR/cmake/toolchain.cmake"        "$OV_SYSROOT/mk/toolchain.cmake"
  install -D -m0644 "$BUILDSPECS_DIR/cmake/Platform/VxWorks.cmake" "$OV_SYSROOT/mk/Platform/VxWorks.cmake"
  record toolchain
  log "toolchain: $(listed toolchain)"
}

# --- inventory ---------------------------------------------------------------------
# "steps": one entry per step function above, in the same order and with the same
# name, holding exactly that step's changes. install-sdk-overlay.sh installs them
# in this order (<step>_install).
write_inventory() {
  python3 - "$STEPS" "$REMOVED_LIST" "$PATCH_LIST" "$REQUIREMENTS" "$GET_PIP" "$SDK_OVERLAY_JSON" \
            "$WIND_RELEASE_ID" "$TGT_ARCH" "$SDK_NAME" "$WIND_SDK_HOME/sdk.json" <<'PY'
import json, os, sys
steps_dir, removed, patches, reqs, get_pip, out, release, arch, name, sdk_json = sys.argv[1:11]
bsp = json.load(open(sdk_json)).get("bsp", "") if os.path.exists(sdk_json) else ""
lines = lambda p: [l.strip() for l in open(p) if l.strip()]
steps = {}
for f in sorted(os.listdir(steps_dir)):
    steps[f.split("-", 1)[1]] = {"files": lines(os.path.join(steps_dir, f))}
steps["sdk_fix"]["removed"] = lines(removed)
steps["sdk_fix"]["patches"] = lines(patches)
steps["python_fix"]["get_pip"] = open(get_pip).read().strip()
steps["sdk_install"]["pip_requirements"] = [l for l in lines(reqs) if not l.startswith("#")]
steps["sdk_install"]["crossenv"] = "vxsdk/host/x86_64-linux/cross_venv/cross"
doc = {
  "description": "SDK overlay, per build step (mk/usr/make-sdk-overlay.sh). "
                 "install-sdk-overlay.sh installs the steps in order: copies each "
                 "step's 'files' from files/ into the SDK, moves 'removed' aside "
                 "(<3pp>/<tree>/X -> <3pp>/.removed/<tree>/X), applies 'patches' "
                 "(sdk-patches/, with sdk-patches/apply-sdk-patches.sh), bootstraps pip with 'get_pip', pip installs "
                 "'pip_requirements' with the SDK python and creates 'crossenv'. "
                 "Paths relative to the SDK root.",
  # the SDK this overlay is for: install-sdk-overlay.sh refuses another one, and
  # make toolkit takes these from here (no SDK needed). name = the SDK's sdk.version,
  # bsp = the exact BSP from its sdk.json
  "sdk": {"release": release, "arch": arch, "bsp": bsp, "name": name},
  "steps": steps,
}
json.dump(doc, open(out, "w"), indent=2)
open(out, "a").write("\n")
print(" ".join("%s:%d" % (k, len(v["files"])) for k, v in steps.items()))
PY
}

# --- archive -----------------------------------------------------------------------
write_archive() {
  local parent base; parent="$(dirname "$STAGE")"; base="$(basename "$STAGE")"
  if command -v zstd >/dev/null 2>&1 && [[ "$SDK_OVERLAY_TARBALL" == *.zst ]]; then
    tar -C "$parent" -cf - "$base" | zstd -19 -T0 -q -o "$SDK_OVERLAY_TARBALL" -f
  else
    SDK_OVERLAY_TARBALL="${SDK_OVERLAY_TARBALL%.zst}"; SDK_OVERLAY_TARBALL="${SDK_OVERLAY_TARBALL%.tar}.tar.gz"
    tar -C "$parent" -czf "$SDK_OVERLAY_TARBALL" "$base"
  fi
  log "archive: $SDK_OVERLAY_TARBALL"
}

rm -rf "$STAGE" "$SDK_OVERLAY_TARBALL"; mkdir -p "$OV"
sdk_fix_overlay
python_fix_overlay
vxworks_fix_overlay
sdk_install_overlay
rust_fix_overlay
unixextra_install_overlay
toolchain_overlay
log "inventory: $(write_inventory) -> $SDK_OVERLAY_JSON"
install -m0755 "$SDK_OVERLAY_INSTALLER" "$STAGE/install-sdk-overlay.sh"
write_archive
log "done: $STAGE"
