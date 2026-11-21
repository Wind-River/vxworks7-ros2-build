#!/usr/bin/env bash
# ros2sdkenv.sh - source this to set up the environment for building ROS 2
# packages against this toolkit's SDK.
#
#   source ros2sdkenv.sh
#   ros2 pkg create --build-type ament_cmake my_app ...
#   colcon build --mixin vxworks
#
# Must be SOURCED, not executed. Idempotent. Derives everything from the toolkit
# location, so the toolkit works wherever it is unpacked.

# --- locate the toolkit + the VxWorks SDK ---------------------------------------
# Kit dir: honor $TOOLKIT or $KIT (dev container), else derive from this script.
_src="${BASH_SOURCE[0]:-$0}"
TOOLKIT_DIR="${TOOLKIT:-${KIT:-$(cd "$(dirname "$_src")/.." && pwd)}}"
export ROS2SDK_TOOLKIT="$TOOLKIT_DIR"

_err() { echo "ros2sdkenv: $*" >&2; }

[ -d "$TOOLKIT_DIR/export/root" ] || { _err "no root/ in $TOOLKIT_DIR (the ROS 2 SDK)"; return 1 2>/dev/null || exit 1; }

# The vanilla Wind River SDK is provided by the USER. Resolve it from, in order:
#   $WRSDK (dev container mount / explicit), $WIND_SDK_HOME (already sourced),
#   or a bundled $TOOLKIT_DIR/wrsdk (standalone toolkits that choose to include it).
SDK_DIR="${WRSDK:-${WIND_SDK_HOME:-$TOOLKIT_DIR/wrsdk}}"
[ -f "$SDK_DIR/sdkenv.sh" ] || { _err "no VxWorks SDK at '$SDK_DIR' (set WRSDK to your SDK, or mount it)"; return 1 2>/dev/null || exit 1; }

# --- 1) the VxWorks SDK cross toolchain + host tools ------------------------
# shellcheck disable=SC1091
_had_u=$(set +o | grep -q "set -o nounset" && echo 1 || true); set +u
source "$SDK_DIR/sdkenv.sh"
[ -n "${_had_u:-}" ] && set -u || true
export WIND_CC_SYSROOT="${WIND_CC_SYSROOT:-$WIND_SDK_CC_SYSROOT}"

# --- 2) keep TARGET libs out of the HOST build LD_LIBRARY_PATH --------------
export COLCON_EXTENSION_BLOCKLIST=colcon_core.environment.library_path

# --- 3) overlay the ROS 2 SDK (CMake configs on CMAKE_PREFIX_PATH, host tools)
export COLCON_PYTHON_EXECUTABLE="$WIND_SDK_HOME/vxsdk/host/x86_64-linux/bin/python3"
# Sourcing setup.bash runs the ament/colcon library_path.dsv hooks, which PREPEND
# export/root/lib (TARGET VxWorks .so's) to the HOST LD_LIBRARY_PATH. That poisons
# every system binary run in this shell (e.g. `ip`, which then fails to load
# libc.so.1). We don't want target libs on the host loader path at all -- the
# cross-build resolves target libs via CMAKE_FIND_ROOT_PATH/sysroot, not
# LD_LIBRARY_PATH. So snapshot LD_LIBRARY_PATH before sourcing and restore it after.
_saved_ld="${LD_LIBRARY_PATH:-}"
set +u
# shellcheck disable=SC1091
source "$TOOLKIT_DIR/export/root/setup.bash"
set -u 2>/dev/null || true
# restore the host loader path (drop whatever setup.bash prepended)
if [ -n "$_saved_ld" ]; then export LD_LIBRARY_PATH="$_saved_ld"; else unset LD_LIBRARY_PATH; fi
unset _saved_ld

# --- 3b) host rclpy stub so the host `ros2` CLI works -----------------------
# export/root's rclpy is a TARGET (VxWorks) build whose C extension can't load
# on the host; the `ros2` CLI imports it eagerly. Prepend a tiny host stub
# (provides just rclpy.executors.ExternalShutdownException) so host-only verbs
# like `ros2 pkg create` work. Verified NOT to affect `colcon build --mixin
# vxworks` (a C++ node build does not import host rclpy).
export PYTHONPATH="$TOOLKIT_DIR/host-shims:${PYTHONPATH:-}"

# --- 4) use the vxworks colcon mixin shipped in the ROS 2 SDK ----------------
# The mixins (vxworks / warnings-low / build-testing) are the ONES THE MAIN
# BUILD USED -- they ship in export/root/.colcon/mixin/default/. ros2sdk-prepare.sh
# relocated their build-time absolute paths (/work, /wrsdk) to this toolkit + SDK, so
# we just point COLCON_HOME at them. Single source of truth: no regeneration here.
export COLCON_HOME="$TOOLKIT_DIR/export/root/.colcon"
_vxmixin="$COLCON_HOME/mixin/default/vxworks.mixin"
if [ ! -f "$_vxmixin" ]; then
  _err "no vxworks mixin at $_vxmixin -- run scripts/ros2sdk-prepare.sh first"
elif ! grep -qF "$TOOLKIT_DIR/export/root" "$_vxmixin"; then
  # same check as ros2sdk-prepare.sh vxworks_mixin_relocate (a literal '/work/'
  # also matches a toolkit that lives under e.g. /home/runner/work/)
  _err "vxworks mixin does not point at this toolkit's export/root -- re-run scripts/ros2sdk-prepare.sh"
fi
unset _vxmixin

# Rust (rclrs): nothing to set here. The SDK's sdkenv.sh (sourced above) already
# runs rustenv.linux, which exports CARGO_HOME=$WIND_CC_SYSROOT/usr/rust/.cargo
# (the generic VxWorks cargo config: crt-static off, --sysroot, [build] target).
# The ROS 2-specific cargo config (rclrs/rosidl_runtime_rs + install-lib link
# flags) is a WORKSPACE file placed at $WS/.cargo/config.toml by the self-test /
# the user; cargo merges it with the CARGO_HOME config. Do NOT override CARGO_HOME.

echo "ros2sdkenv: ready."
echo "  toolkit:    $TOOLKIT_DIR"
echo "  SDK:    $WIND_SDK_HOME"
echo "  ROS 2:  $TOOLKIT_DIR/export/root  (CMAKE_FIND_ROOT_PATH)"
echo "  mixin:  vxworks  (colcon mixin list)"
