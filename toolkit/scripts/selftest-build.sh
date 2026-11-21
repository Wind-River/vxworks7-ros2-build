#!/usr/bin/env bash
# selftest-build.sh - HOST-side half of the toolkit self-test (Shape A).
#
# Proves the shipped toolkit can build ROS 2 nodes for VxWorks, then STAGES them
# on a USB dir (attached to QEMU as /bd0a) so the on-target half can run them --
# WITHOUT modifying ros2.img (the image stays pristine).
#
# Steps:
#   1) deploy the toolkit: unpack the tarball, run ros2sdk-prepare.sh vs the SDK
#   2) source ros2sdkenv.sh
#   3) for each selected --lang, scaffold a minimal node that prints a unique
#      marker and exits, via `ros2 pkg create --build-type`:
#        cpp    = ament_cmake   "Hello from C++, world!"
#        rust   = ament_cargo   "Hello from Rust, world!"   (rclrs)
#        python = ament_python  "Hello from Python, world!" (rclpy)
#   4) ONE `colcon build --merge-install --mixin vxworks` of the whole workspace
#   5) assert each compiled artifact (cpp/rust) is a VxWorks RTP (x86-64 ld64.so.1 or aarch64 ld.so.1)
#   6) Python: optimize-python-startup on install/ (unchecked-hash .pyc + launchers)
#   7) stage the merged install/ tree onto the USB dir (-> /bd0a); the matching
#      on-target proc (tests/toolkit/test01..03) runs it from /bd0a. ros2.img untouched.
#
# Usage:
#   selftest-build.sh [--toolkit <tarball-or-dir>] [--sdk <wrsdk-dir>] [--img <ros2.img>]
#                     [--lang all|cpp|rust|python] [--workdir <dir>] [--clean]
#
# All inputs auto-default, so from the build tree with the SDK env sourced you can
# just run `selftest-build.sh` with no args:
#   --toolkit  : newest output/toolkit-*.tar.* (else output/<kit-dir>)
#   --sdk  : $WIND_SDK_HOME / $WIND_HOME / $WRSDK (whichever has sdkenv.sh)
#   --img  : the toolkit's OWN shipped image ($TOOLKIT_ROOT/ros2.img)
#   --lang : all (default) builds C++ + Rust + Python; or pick one
#   --clean: delete the work dir on exit (default: keep it, since you boot the
#            image next with main_script.exp)
#
# After this succeeds, boot the image and run the on-target assertion (the script
# prints the exact command, with the absolute path to tests/main_script.exp):
#   expect <build-tree>/tests/main_script.exp <ros2.img> toolkit/test01-cpp-hello
#
# Exit 0 = toolkit built a VxWorks RTP and it is now in the image.
set -euo pipefail

# Resolve the build tree root (…/vxworks7-ros2-build) from this script's location
# (scripts live at toolkit/scripts/ in-tree, or scripts/ inside an unpacked toolkit).
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_TREE="$(cd "$SELF_DIR/../.." && pwd)"   # toolkit/scripts -> repo root
OUT_DIR="$BUILD_TREE/output"

TOOLKIT_SRC=""; SDK=""; IMG=""; WORKDIR=""; CLEAN=0; LANG_SEL="all"

while [ $# -gt 0 ]; do
  case "$1" in
    --toolkit) TOOLKIT_SRC="$2"; shift 2 ;;
    --sdk) SDK="$2"; shift 2 ;;
    --img) IMG="$2"; shift 2 ;;
    --lang) LANG_SEL="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; shift 2 ;;
    --clean) CLEAN=1; shift ;;
    -h|--help) sed -n '2,/^[^#]/{/^#/s/^# \{0,1\}//p}' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Which languages to exercise. "all" (default) = cpp + rust + python.
case "$LANG_SEL" in
  all)    LANGS="cpp rust python" ;;
  cpp|rust|python) LANGS="$LANG_SEL" ;;
  *) echo "unknown --lang: $LANG_SEL (want: all|cpp|rust|python)" >&2; exit 2 ;;
esac

say()  { printf '\n== selftest-build: %s\n' "$*"; }
pass() { printf 'SELFTEST-BUILD PASS: %s\n' "$*"; }
die()  { printf 'SELFTEST-BUILD FAIL: %s\n' "$*" >&2; exit 1; }

# --- defaults ---------------------------------------------------------------
# --toolkit: newest toolkit tarball under output/, else a single unpacked toolkit dir there.
if [ -z "$TOOLKIT_SRC" ]; then
  TOOLKIT_SRC="$(ls -t "$OUT_DIR"/toolkit-*.tar.zst \
                    "$OUT_DIR"/toolkit-*.tar.gz \
                    "$OUT_DIR"/toolkit-*.tgz 2>/dev/null | head -1 || true)"
  [ -n "$TOOLKIT_SRC" ] || TOOLKIT_SRC="$(find "$OUT_DIR" -maxdepth 1 -type d -name 'toolkit-*' ! -name toolkit-build 2>/dev/null | head -1 || true)"
  [ -n "$TOOLKIT_SRC" ] || die "no toolkit under $OUT_DIR (run 'make toolkit' first, or pass --toolkit)"
  say "auto --toolkit $TOOLKIT_SRC"
fi
# --sdk: trust the already-sourced SDK env, else common vars.
if [ -z "$SDK" ]; then
  for c in "${WIND_SDK_HOME:-}" "${WIND_HOME:-}" "${WRSDK:-}"; do
    if [ -n "$c" ] && [ -f "$c/sdkenv.sh" ]; then SDK="$c"; break; fi
  done
  [ -n "$SDK" ] || die "no SDK: source <sdk>/sdkenv.sh first, set WIND_SDK_HOME/WRSDK, or pass --sdk"
  say "auto --sdk $SDK"
fi
# --img: defaults to the toolkit's OWN shipped image ($TOOLKIT_ROOT/ros2.img) — resolved after
# the toolkit is unpacked below, so the self-test deploys into exactly what shipped.

[ -f "$SDK/sdkenv.sh" ] || die "no sdkenv.sh under SDK: $SDK"
SDK="$(cd "$SDK" && pwd)"

WORKDIR="${WORKDIR:-$(mktemp -d "${TMPDIR:-/tmp}/toolkit-selftest.XXXXXX")}"
mkdir -p "$WORKDIR"
# USB staging dir: built binaries go here; the harness attaches it as a FAT USB
# disk (-> /bd0a on target) via VX_USB, so ros2.img is NEVER modified.
USB_DIR="$WORKDIR/usb"; mkdir -p "$USB_DIR"
# Keep the workdir (USB stage) by default -- the on-target half is a separate
# command you run next. Pass --clean to delete it instead.
cleanup() { if [ "$CLEAN" = 1 ]; then rm -rf "$WORKDIR"; fi; }
trap cleanup EXIT
say "toolkit=$TOOLKIT_SRC  sdk=$SDK  work=$WORKDIR"

# --- 1) deploy the toolkit --------------------------------------------------
say "1) deploy toolkit (unpack + ros2sdk-prepare.sh)"
if [ -d "$TOOLKIT_SRC" ]; then
  TOOLKIT_ROOT="$(cd "$TOOLKIT_SRC" && pwd)"
else
  [ -f "$TOOLKIT_SRC" ] || die "toolkit not found: $TOOLKIT_SRC"
  UNPK="$WORKDIR/toolkit"; mkdir -p "$UNPK"
  case "$TOOLKIT_SRC" in
    *.tar.zst) command -v zstd >/dev/null || die "zstd needed to unpack $TOOLKIT_SRC"
               zstd -dc "$TOOLKIT_SRC" | tar -C "$UNPK" -xf - ;;
    *.tar.gz|*.tgz) tar -C "$UNPK" -xzf "$TOOLKIT_SRC" ;;
    *) die "unknown toolkit archive type: $TOOLKIT_SRC" ;;
  esac
  # the tarball contains a single top dir (TOOLKIT_NAME)
  TOOLKIT_ROOT="$(find "$UNPK" -maxdepth 1 -mindepth 1 -type d | head -1)"
  [ -n "$TOOLKIT_ROOT" ] || die "no top-level dir inside $TOOLKIT_SRC"
fi
[ -x "$TOOLKIT_ROOT/scripts/ros2sdk-prepare.sh" ] || die "toolkit has no scripts/ros2sdk-prepare.sh ($TOOLKIT_ROOT)"
"$TOOLKIT_ROOT/scripts/ros2sdk-prepare.sh" "$SDK" || die "ros2sdk-prepare.sh failed"

# --img default: the toolkit's OWN shipped image. We deploy the freshly built node
# into it, so the on-target test runs exactly what the toolkit delivers. (If the kit
# was given as a tarball, this is the unpacked copy in $WORKDIR — deploying into
# it is fine; the test boots this same path.)
if [ -z "$IMG" ]; then
  IMG="$TOOLKIT_ROOT/ros2.img"
  say "auto --img $IMG (toolkit's shipped image)"
fi
[ -f "$IMG" ] || die "image not found: $IMG (toolkit has no ros2.img; pass --img)"
IMG="$(cd "$(dirname "$IMG")" && pwd)/$(basename "$IMG")"

# --- 2) source env ----------------------------------------------------------
say "2) source ros2sdkenv.sh"
export TOOLKIT="$TOOLKIT_ROOT" WRSDK="$SDK"
set +u
# shellcheck disable=SC1091
source "$TOOLKIT_ROOT/scripts/ros2sdkenv.sh"
set -u
command -v colcon >/dev/null || die "colcon not on PATH after ros2sdkenv.sh"
command -v ros2   >/dev/null || die "ros2 not on PATH after ros2sdkenv.sh"

# Real-life ROS 2 layout: a named workspace with packages under src/, built from
# the workspace root.
WS="$WORKDIR/ros2_ws"; mkdir -p "$WS/src"

# assert_vxrtp <file> -- the built artifact must be a VxWorks RTP, NOT a host
# (ld-linux) build: an ELF with the VxWorks interpreter of its target, x86-64
# (ld64.so.1) or aarch64 (ld.so.1). Proves the cross toolchain + mixin applied.
assert_vxrtp() {
  local f="$1" fi
  fi="$(file -L "$f")"; echo "  $f"; echo "  $fi"
  echo "$fi" | grep -q 'ELF 64-bit' || die "not an ELF: $fi"
  if echo "$fi" | grep -q 'x86-64'; then
    echo "$fi" | grep -q 'interpreter /lib/ld64.so.1' || die "interpreter not VxWorks ld64.so.1 (HOST build? mixin not applied): $fi"
  elif echo "$fi" | grep -q 'ARM aarch64'; then
    echo "$fi" | grep -q 'interpreter /lib/ld.so.1'   || die "interpreter not VxWorks ld.so.1 (HOST build? mixin not applied): $fi"
  else
    die "neither x86-64 nor aarch64: $fi"
  fi
}

# stage <src> [destname] -- copy a built artifact into the USB staging dir. The
# harness attaches that dir as a FAT USB disk (-> /bd0a on target), so the binary
# runs from /bd0a WITHOUT modifying ros2.img (the image stays pristine).
stage() {
  local dest="$USB_DIR/${2:-$(basename "$1")}"
  cp "$1" "$dest" || die "stage $1 -> $dest failed"
}

# --- per-language scaffolding (write only; the build happens once, merged) --
# write_* create a package under ros2_ws/src/ with a minimal node that prints a
# unique marker and exits. No build here -- all selected packages are built in a
# single `colcon build --merge-install` pass below, exactly like the main build.

# C++ (ament_cmake) -> binary hello_cpp
write_cpp() {
  local pkg="hello_cpp" marker="Hello from C++, world!"
  say "[cpp] ros2 pkg create --build-type ament_cmake $pkg"
  ( cd "$WS/src" && ros2 pkg create --build-type ament_cmake "$pkg" >/dev/null ) || die "[cpp] pkg create failed"
  cat > "$WS/src/$pkg/src/hello.cpp" <<CPP
#include <cstdio>
int main() { std::printf("$marker\n"); std::fflush(stdout); return 0; }
CPP
  cat > "$WS/src/$pkg/CMakeLists.txt" <<CMK
cmake_minimum_required(VERSION 3.8)
project($pkg)
find_package(ament_cmake REQUIRED)
add_executable(hello_cpp src/hello.cpp)
install(TARGETS hello_cpp DESTINATION lib/\${PROJECT_NAME})
ament_package()
CMK
}

# Rust (ament_cargo, rclrs) -> binary hello_rust
write_rust() {
  local pkg="hello_rust" marker="Hello from Rust, world!"
  [ -d "$TOOLKIT_ROOT/export/root/share/rclrs/rust" ] || die "[rust] toolkit has no rclrs crate sources (build without ROS2_RUST?)"
  [ -f "$TOOLKIT_ROOT/.cargo/config.toml" ] || die "[rust] no toolkit cargo config (ros2sdk-prepare.sh did not render it)"
  # The ROS 2-specific cargo config goes on cargo's workspace-walk at
  # src/.cargo/config.toml (where the main build puts it). Generic VxWorks flags
  # come from the SDK via CARGO_HOME (set by sdkenv/rustenv.linux).
  mkdir -p "$WS/src/.cargo"
  cp "$TOOLKIT_ROOT/.cargo/config.toml" "$WS/src/.cargo/config.toml"
  say "[rust] ros2 pkg create --build-type ament_cargo $pkg"
  ( cd "$WS/src" && ros2 pkg create --build-type ament_cargo "$pkg" >/dev/null ) || die "[rust] pkg create failed"
  cat > "$WS/src/$pkg/package.xml" <<PX
<?xml version="1.0"?>
<package format="3">
  <name>$pkg</name>
  <version>0.0.0</version>
  <description>toolkit self-test rclrs hello</description>
  <maintainer email="selftest@example.com">selftest</maintainer>
  <license>Apache-2.0</license>
  <depend>rclrs</depend>
  <export><build_type>ament_cargo</build_type></export>
</package>
PX
  cat > "$WS/src/$pkg/Cargo.toml" <<CT
[package]
name = "$pkg"
version = "0.0.0"
edition = "2021"

[[bin]]
name = "hello_rust"
path = "src/main.rs"

[dependencies]
rclrs = "0.8"
CT
  cat > "$WS/src/$pkg/src/main.rs" <<RS
use rclrs::*;
fn main() -> Result<(), RclrsError> {
    let context = Context::default_from_env()?;
    let executor = context.create_basic_executor();
    let _node = executor.create_node("hello_rust")?;
    println!("$marker");
    Ok(())
}
RS
}

# Python (ament_python, rclpy) -> module + console-script entry hello_python
write_python() {
  local pkg="hello_python" node="hello_python" marker="Hello from Python, world!"
  say "[python] ros2 pkg create --build-type ament_python $pkg"
  ( cd "$WS/src" && ros2 pkg create --build-type ament_python \
      --node-name "$node" "$pkg" >/dev/null ) || die "[python] pkg create failed"
  cat > "$WS/src/$pkg/$pkg/${node}.py" <<PY
import rclpy
def main(args=None):
    rclpy.init(args=args)
    node = rclpy.create_node("$node")
    print("$marker", flush=True)
    node.destroy_node()
    rclpy.shutdown()
if __name__ == "__main__":
    main()
PY
}

# --- 3) write all selected packages -----------------------------------------
say "3) scaffolding packages under $WS/src ($LANGS)"
NEED_CARGO_TARGET=0
for lang in $LANGS; do
  case "$lang" in
    cpp)    write_cpp ;;
    rust)   write_rust; NEED_CARGO_TARGET=1 ;;
    python) write_python ;;
  esac
done

# --- 4) one merged build of the whole workspace -----------------------------
# --merge-install mirrors the main build: a single install/ tree (lib/<pkg>/,
# lib/python3.9/site-packages/, share/...) instead of per-package dirs. We stage
# that one tree to USB, so nothing pollutes ros2.img.
CARGO_TARGET=""
if [ "$NEED_CARGO_TARGET" = 1 ]; then
  CARGO_TARGET="$("$WIND_SDK_HOME/vxsdk/host/x86_64-linux/bin/python3" - "$TOOLKIT_ROOT/manifest.json" <<'PY' 2>/dev/null || true
import json,sys
try: print(json.load(open(sys.argv[1])).get("ROS2_RUST_TARGET",""))
except Exception: pass
PY
)"
fi
say "4) colcon build --merge-install --mixin vxworks"
( cd "$WS" && CARGO_BUILD_TARGET="${CARGO_TARGET:-${CARGO_BUILD_TARGET:-}}" \
     colcon build --merge-install --mixin vxworks ) || die "colcon build (merge-install) failed"

INSTALL="$WS/install"   # merged tree

# --- 5) assert the compiled artifacts are VxWorks RTPs ----------------------
say "5) verify compiled artifacts"
for lang in $LANGS; do
  case "$lang" in
    cpp)  assert_vxrtp "$INSTALL/lib/hello_cpp/hello_cpp" ;;
    rust) assert_vxrtp "$INSTALL/lib/hello_rust/hello_rust" ;;
  esac
done

# --- 6) Python: prepare install/ for a fast start on the target -----------
# Same step the image build runs (python_prepare_deploy): unchecked-hash .pyc
# (target loads bytecode as-is, never recompiles on its slow FS) and rewrite of
# the ament_python EASY-INSTALL launcher, which imports pkg_resources + scans the
# whole working set at startup -- slow on the target FS and fragile for a package
# relocated to /bd0a (DistributionNotFound) -- into an importlib.metadata wrapper.
case " $LANGS " in
  *" python "*)
    OPS="$WIND_SDK_HOME/vxsdk/host/x86_64-linux/bin/optimize-python-startup"
    [ -x "$OPS" ] || die "[python] optimize-python-startup not in the SDK host bin (toolkit SDK overlay not applied?)"
    say "6) optimize-python-startup $INSTALL"
    "$WIND_SDK_HOME/vxsdk/host/x86_64-linux/bin/python3" "$OPS" "$INSTALL" \
      || die "[python] optimize-python-startup failed"
    ;;
esac

# --- 7) stage the merged install tree onto the USB dir (image untouched) ----
say "7) stage merged install/ -> USB dir $USB_DIR (-> /bd0a; ros2.img untouched)"
cp -a "$INSTALL/." "$USB_DIR/" || die "staging merged install/ to USB failed"

# Map lang -> on-target test by naming (tests/toolkit/test*-<lang>-*.exp), as the
# selector main_script.exp takes: toolkit/<test>.
test_for() {
  local t; t="$(ls "$BUILD_TREE"/tests/toolkit/test*-"$1"-*.exp 2>/dev/null | head -1)"
  [ -n "$t" ] || die "no on-target test tests/toolkit/test*-$1-*.exp for --lang $1"
  echo "toolkit/$(basename "$t" .exp)"
}

# Print the copy-pasteable on-target command. The harness attaches the USB dir via
# VX_USB (-> /bd0a); ros2.img is booted read-only/unmodified.
MAIN_SCRIPT="$BUILD_TREE/tests/main_script.exp"
TESTS=""; for lang in $LANGS; do TESTS="$TESTS $(test_for "$lang")"; done
TESTS="${TESTS# }"   # trim leading space
pass "selected languages ($LANGS) built (merge-install) + staged to USB $USB_DIR"
printf '\nRun the on-target half (USB dir -> /bd0a; image untouched):\n  VX_USB=%s expect %s \\\n    %s %s\n' \
  "$USB_DIR" "$MAIN_SCRIPT" "$IMG" "$TESTS"

# Machine-readable handoff for CI (source it, or read individual keys). Paths are
# absolute so the on-target job can consume them without re-deriving defaults.
cat > "$WORKDIR/selftest.env" <<EOF
VX_USB="$USB_DIR"
VX_IMG="$IMG"
VX_TESTS="$TESTS"
VX_MAIN_SCRIPT="$MAIN_SCRIPT"
EOF
say "wrote $WORKDIR/selftest.env (VX_USB / VX_IMG / VX_TESTS / VX_MAIN_SCRIPT)"

if [ "$CLEAN" = 1 ]; then
  printf '\nNOTE: --clean was given, so the work dir (USB stage) is removed on exit.\n'
fi
