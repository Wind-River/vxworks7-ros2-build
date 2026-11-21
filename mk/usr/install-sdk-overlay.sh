#!/usr/bin/env bash
# install-sdk-overlay.sh - install the SDK overlay into a VxWorks SDK: the changes
# that turn a vanilla SDK into the SDK the ROS 2 build used.
#
#   ./install-sdk-overlay.sh /path/to/vanilla/wrsdk-vxworks7-qemu
#
# Lives in the SDK overlay next to files/ and sdk_overlay.json (made by
# mk/usr/make-sdk-overlay.sh). One function per build step, with the same names and
# order as make-sdk-overlay.sh (<step>_overlay -> <step>_install):
#
#   sdk_fix_install  python_fix_install  vxworks_fix_install  sdk_install_install
#   rust_fix_install  unixextra_install_install  toolchain_install
#
# It first checks that the SDK is the one the overlay was made for (sdk_overlay.json
# "sdk"). Each step installs only its own files and checks its result. Idempotent.
set -euo pipefail

OV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
OV="$OV_DIR/files"
OV_JSON="$OV_DIR/sdk_overlay.json"
WRSDK="${1:-${WRSDK:-}}"
HOSTBIN_REL="vxsdk/host/x86_64-linux/bin"

log() { printf '== %s\n' "$*"; }
die() { printf 'install-sdk-overlay FAILED: %s\n' "$*" >&2; exit 1; }

[ -n "$WRSDK" ] || die "usage: install-sdk-overlay.sh <VxWorks-SDK-dir>"
[ -f "$WRSDK/sdkenv.sh" ] || die "no sdkenv.sh in '$WRSDK' - not a VxWorks SDK"
[ -d "$OV" ]      || die "no files/ next to $0"
[ -f "$OV_JSON" ] || die "no sdk_overlay.json next to $0"
WRSDK="$(cd "$WRSDK" && pwd)"
log "SDK overlay: $OV_DIR"
log "SDK:         $WRSDK"

# SDK env: host python + WIND_*. sdkenv.sh is not nounset-clean (references
# WIND_SDK_HOME before setting it), so relax -u around it.
# shellcheck disable=SC1091
set +u
source "$WRSDK/sdkenv.sh"
set -u
export WIND_CC_SYSROOT="${WIND_CC_SYSROOT:-$WIND_SDK_CC_SYSROOT}"
PY39="$WRSDK/$HOSTBIN_REL/python3.9"   # in the vanilla SDK; python3 comes with python_fix
PY="$WRSDK/$HOSTBIN_REL/python3"

# inventory access: step <name> <key> prints that step's list (one item per line)
step() { "$PY39" -c 'import json,sys
v=json.load(open(sys.argv[1]))["steps"][sys.argv[2]].get(sys.argv[3], [])
print("\n".join(v) if isinstance(v, list) else v)' "$OV_JSON" "$1" "$2"; }
# copy a step's files from files/ into the SDK (keeps symlinks + perms)
copy_files() {
  local list; list="$(step "$1" files)"
  [ -n "$list" ] || return 0
  printf '%s\n' "$list" | ( cd "$OV" && tar -cf - --no-recursion -T - ) | tar -C "$WRSDK" -xf - \
    || die "$1: copying files failed"
  log "$1: copied $(printf '%s\n' "$list" | wc -l) file(s)"
}

# --- the SDK must be the one the overlay was made for ------------------------------
# (sdk_overlay.json "sdk": its sdk.version name, the release, the exact BSP)
sdk_match_check() {
  # the overlay's value for each key against this SDK's own
  local want have k
  for k in name release bsp; do
    want="$("$PY39" -c 'import json,sys; print(json.load(open(sys.argv[1]))["sdk"].get(sys.argv[2], ""))' "$OV_JSON" "$k")"
    case "$k" in
      name)    have="$(cat "$WRSDK/sdk.version" 2>/dev/null || basename "$WRSDK")" ;;
      release) have="$(sed -n 's/^_WRS_CONFIG_CORE_RELEASE=//p' "$WIND_CC_SYSROOT/h/config/auto.conf" 2>/dev/null)" ;;
      bsp)     have="$("$PY39" -c 'import json,sys; print(json.load(open(sys.argv[1])).get("bsp", ""))' "$WRSDK/sdk.json" 2>/dev/null)" ;;
    esac
    [ "$have" = "$want" ] || die "SDK mismatch ($k): overlay is for '$want', this SDK is '${have:-unknown}'"
  done
  log "SDK match: $(cat "$WRSDK/sdk.version" 2>/dev/null) (release, bsp checked)"
}

# --- pkg/sdk sdk_fix ------------------------------------------------------------
sdk_fix_install() {
  copy_files sdk_fix
  # move the SDK files the ROS 2 SDK replaces aside, as the build did
  # (<3pp>/<tree>/X -> <3pp>/.removed/<tree>/X); reversible, idempotent
  step sdk_fix removed | "$PY39" -c 'import os, shutil, sys
sdk = sys.argv[1]; n = 0
for rel in (l.strip() for l in sys.stdin):
    src = os.path.join(sdk, rel)
    if not rel or not os.path.lexists(src):
        continue
    head, tree_rest = rel.split("/usr/3pp/", 1)
    dst = os.path.join(sdk, head, "usr/3pp/.removed", tree_rest)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    if os.path.lexists(dst):
        os.remove(dst) if not os.path.isdir(dst) or os.path.islink(dst) else shutil.rmtree(dst)
    shutil.move(src, dst); n += 1
print("== sdk_fix: moved aside %d SDK file(s)" % n)' "$WRSDK" || die "sdk_fix: moving aside SDK files failed"
  [ -f "$WRSDK/vxsdk/sysroot/mk/defs.autotools.mk" ] || die "sdk_fix: defs.autotools.mk missing"
  # SDK file edits: apply the shipped patches with the script sdk_fix used
  # (idempotent; fails if a patch neither applies nor is applied)
  local n; n="$(step sdk_fix patches | grep -c . || true)"
  if [ "$n" -gt 0 ]; then
    "$OV_DIR/sdk-patches/apply-sdk-patches.sh" "$OV_DIR/sdk-patches" "$WRSDK" \
      || die "sdk_fix: applying the SDK patches failed"
  fi
  log "sdk_fix: $n SDK patch(es)"
}

# --- pkg/sdk python_fix -----------------------------------------------------------
python_fix_install() {
  copy_files python_fix
  # pip: as python_fix in the build, bootstrap it with get-pip.py and use
  # '#!/usr/bin/env python3' in its launchers
  local bin="$WRSDK/$HOSTBIN_REL" url gp
  if [ ! -f "$bin/pip3" ]; then
    url="$(step python_fix get_pip)"; gp="$(mktemp)"
    log "python_fix: bootstrapping pip ($url)"
    if command -v curl >/dev/null 2>&1; then curl -fsSL -o "$gp" "$url"
    else wget -q -O "$gp" "$url"; fi || die "python_fix: downloading get-pip.py failed"
    "$PY" "$gp" || die "python_fix: get-pip.py failed"
    rm -f "$gp"
    sed -i '1s|^#!.*|#!/usr/bin/env python3|' "$bin/pip" "$bin/pip3" "$bin/pip3.9"
  fi
  [ -x "$PY" ] && [ -x "$bin/pip3" ] || die "python_fix: python3/pip3 missing"
}

# --- pkg/sdk vxworks_fix ----------------------------------------------------------
# Not called by sdk_patch in the build: nothing to install.
vxworks_fix_install() {
  copy_files vxworks_fix
}

# --- pkg/sdk sdk_install ------------------------------------------------------------
sdk_install_install() {
  copy_files sdk_install
  local req; req="$(mktemp)"
  step sdk_install pip_requirements > "$req"
  if [ -s "$req" ]; then
    log "sdk_install: pip install $(wc -l < "$req") host package(s)"
    "$PY" -m pip install -r "$req" || die "sdk_install: pip install failed"
  fi
  rm -f "$req"
  # as sdk_install in the build: host Python scripts use '#!/usr/bin/env python3',
  # not the absolute interpreter path pip wrote
  find "$WRSDK/$HOSTBIN_REL/" -type f -exec grep -Iq . {} \; -exec sed -i \
       '1s|^#!.*python[^ ]*|#!/usr/bin/env python3|' {} \;
  log "sdk_install: Python shebangs converted to /usr/bin/env python3"
  local venv sysroot_py="$WIND_CC_SYSROOT/usr/3pp/develop/usr/bin/python3"
  venv="$WRSDK/$(step sdk_install crossenv)"
  if [ ! -f "$venv/bin/activate" ] && [ -x "$sysroot_py" ]; then
    log "sdk_install: creating crossenv -> $venv"
    "$PY" -m crossenv "$sysroot_py" "$venv" || log "WARN: crossenv setup failed (only needed for some Python extension builds)"
  else
    log "sdk_install: crossenv present or sysroot python absent - skipping"
  fi
  [ -x "$WRSDK/$HOSTBIN_REL/optimize-python-startup" ] || die "sdk_install: optimize-python-startup missing"
}

# --- pkg/sdk rust_fix ---------------------------------------------------------------
rust_fix_install() {
  copy_files rust_fix
  # the SDK cargo config carries the build's absolute sysroot: point it at this SDK
  local cfg="$WRSDK/vxsdk/sysroot/usr/rust/.cargo/config.toml"
  if [ -f "$cfg" ]; then
    sed -i "s#/[^\"= ]*/vxsdk/sysroot#$WIND_CC_SYSROOT#g" "$cfg" || die "rust_fix: cargo config relocation failed"
    log "rust_fix: cargo config sysroot -> $WIND_CC_SYSROOT"
  fi
}

# --- pkg/unixextra unixextra.install ------------------------------------------------
unixextra_install_install() {
  copy_files unixextra.install
  [ -f "$WRSDK/vxsdk/sysroot/usr/lib/common/libunixextra.so" ] || die "unixextra.install: libunixextra.so missing"
  grep -q 'lunixextra' "$WRSDK/vxsdk/sysroot/cc-conf/default.conf" || die "unixextra.install: default.conf has no -lunixextra"
}

# --- buildspecs/cmake toolchain -----------------------------------------------------
toolchain_install() {
  copy_files toolchain
  [ -f "$WRSDK/vxsdk/sysroot/mk/toolchain.cmake" ] || die "toolchain: toolchain.cmake missing"
}

sdk_match_check
sdk_fix_install
python_fix_install
vxworks_fix_install
sdk_install_install
rust_fix_install
unixextra_install_install
toolchain_install
log "PASS: SDK overlay installed into $WRSDK"
