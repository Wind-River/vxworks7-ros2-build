#!/usr/bin/env bash
# tests/ros2-sdk/test-ros2-hello-world.sh
#
# Host-side build test: prove the produced ROS 2 SDK (output/export/root, built
# by `make ros2`) can CREATE and BUILD a new ROS 2 application that links against
# the produced ROS 2 SDK.
#
# Non-relocatable (in-place): the export tree is sourced at its original
# location. The flow mirrors the doc exactly:
#   1) mkdir ros_ws && cd ros_ws
#   2) source sdkenv.sh + WIND_CC_SYSROOT + COLCON_EXTENSION_BLOCKLIST
#      + output/export/root/setup.bash
#   3) ros2 pkg create --build-type ament_cmake hello_world   (+ an rclcpp node)
#   4) colcon build --mixin vxworks ...
#   5) assert the result is a VxWorks RTP that links the SDK's librclcpp
#
# Usage:
#   source <wrsdk>/sdkenv.sh          # arch must match export/root (x86_64)
#   tests/ros2-sdk/test-ros2-hello-world.sh [<export_root>]
#     <export_root>  default: <repo>/output/export/root
#
# Env knobs: VX_SDK (sdk dir to source if none sourced), VX_WS (build ws).

set -euo pipefail

HB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HB/../.." && pwd)"
EXPORT_ROOT="${1:-$REPO/output/export/root}"
WS="${VX_WS:-/tmp/ros2-hw-test/ros_ws}"

log()  { printf '\n== %s ==\n' "$*"; }
info() { printf '   %s\n' "$*"; }
die()  { printf '\nFAIL: %s\n' "$*" >&2; exit 1; }

# ---- SDK -------------------------------------------------------------------
if [ -z "${WIND_SDK_HOME:-}" ]; then
  [ -n "${VX_SDK:-}" ] || die "source <wrsdk>/sdkenv.sh first, or set VX_SDK=<wrsdk dir>"
  [ -f "$VX_SDK/sdkenv.sh" ] || die "VX_SDK=$VX_SDK has no sdkenv.sh"
  # shellcheck disable=SC1091
  source "$VX_SDK/sdkenv.sh"
fi
export WIND_CC_SYSROOT="${WIND_CC_SYSROOT:-$WIND_SDK_CC_SYSROOT}"
command -v colcon >/dev/null || die "colcon not on PATH (SDK not sourced?)"
SDK_PY="$WIND_SDK_HOME/vxsdk/host/x86_64-linux/bin/python3"
[ -x "$SDK_PY" ] || die "SDK python3 not found"
SDK_TRIPLE="$(wr-c++ -print-target-triple 2>/dev/null | head -1)"
SDK_ARCH="$(printf '%s' "$SDK_TRIPLE" | cut -d- -f1 | sed 's/arm64/aarch64/')"
log "SDK $WIND_SDK_HOME  ($SDK_TRIPLE)"

# ---- the produced ROS 2 SDK must be a FULL one (ament_cmake + rclcpp) -------
[ -d "$EXPORT_ROOT" ] || die "export root not found: $EXPORT_ROOT (run 'make ros2' first)"
[ -f "$EXPORT_ROOT/share/ament_cmake/cmake/ament_cmakeConfig.cmake" ] \
  || die "export root has no ament_cmake -> it is not a full ROS 2 SDK (vendor-only). Build the full SDK."
ls "$EXPORT_ROOT"/lib/librclcpp.so* >/dev/null 2>&1 \
  || die "export root has no librclcpp -> not a full ROS 2 SDK."
[ -d "$EXPORT_ROOT/lib/python3.9/site-packages/ros2pkg" ] \
  || die "export root has no ros2pkg (host ros2 CLI) -> cannot 'ros2 pkg create'."
info "export root is a full ROS 2 SDK (ament_cmake + rclcpp + ros2pkg)"

# ---- 1) mkdir ros_ws -------------------------------------------------------
log "1) mkdir ros_ws"
rm -rf "$WS"; mkdir -p "$WS/src"; cd "$WS"

# ---- 2) source the environment (in place) ----------------------------------
log "2) source SDK env + export/root/setup.bash (in place)"
export COLCON_EXTENSION_BLOCKLIST=colcon_core.environment.library_path
export COLCON_PYTHON_EXECUTABLE="$SDK_PY"
set +u; source "$EXPORT_ROOT/setup.bash"; set -u
info "CMAKE_PREFIX_PATH head: $(printf '%s' "${CMAKE_PREFIX_PATH:-<empty>}" | cut -d: -f1)"

# ---- 3) ros2 pkg create --build-type ament_cmake ---------------------------
# The host ros2 CLI entrypoint eagerly imports rclpy, whose C-extension in
# export/root is built for the TARGET (VxWorks) and cannot load on the host.
# 'ros2 pkg create' itself does NOT need rclpy, so we invoke the real ros2pkg
# CreateVerb (the exact code path of 'ros2 pkg create') directly.
log "3) ros2 pkg create --build-type ament_cmake hello_world"
( cd src
  "$SDK_PY" - <<'PY'
import argparse
from ros2pkg.verb.create import CreateVerb
p = argparse.ArgumentParser(); v = CreateVerb(); v.add_arguments(p, 'ros2 pkg')
v.main(args=p.parse_args([
    '--build-type', 'ament_cmake', '--license', 'Apache-2.0',
    '--node-name', 'hello_world_node', 'hello_world']))
PY
)
[ -f src/hello_world/package.xml ] || die "ros2 pkg create did not produce the package"
info "created src/hello_world (ament_cmake)"

# ---- inject a real rclcpp Hello World node ---------------------------------
log "write an rclcpp Hello World node + wire deps"
cat > src/hello_world/src/hello_world_node.cpp <<'EOF'
#include <chrono>
#include <memory>
#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/string.hpp"
using namespace std::chrono_literals;

class HelloWorld : public rclcpp::Node {
public:
  HelloWorld() : Node("hello_world") {
    pub_ = create_publisher<std_msgs::msg::String>("chatter", 10);
    timer_ = create_wall_timer(500ms, [this]() {
      std_msgs::msg::String msg; msg.data = "Hello, world!";
      RCLCPP_INFO(get_logger(), "%s", msg.data.c_str());
      pub_->publish(msg);
    });
  }
private:
  rclcpp::TimerBase::SharedPtr timer_;
  rclcpp::Publisher<std_msgs::msg::String>::SharedPtr pub_;
};

int main(int argc, char ** argv) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<HelloWorld>());
  rclcpp::shutdown();
  return 0;
}
EOF

# deps in package.xml
sed -i 's#<buildtool_depend>ament_cmake</buildtool_depend>#<buildtool_depend>ament_cmake</buildtool_depend>\n  <depend>rclcpp</depend>\n  <depend>std_msgs</depend>#' \
  src/hello_world/package.xml

# CMake: find rclcpp/std_msgs, C++17 (Dinkum ceiling), modern targets
"$SDK_PY" - "$WS/src/hello_world/CMakeLists.txt" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
s = s.replace("find_package(ament_cmake REQUIRED)",
              "find_package(ament_cmake REQUIRED)\nfind_package(rclcpp REQUIRED)\nfind_package(std_msgs REQUIRED)")
s = s.replace("target_compile_features(hello_world_node PUBLIC c_std_17 cxx_std_20)  # Require C17 and C++20",
              "target_compile_features(hello_world_node PUBLIC c_std_17 cxx_std_17)  # Dinkum C++ ceiling = C++17\n"
              "target_link_libraries(hello_world_node rclcpp::rclcpp ${std_msgs_TARGETS})")
open(p, "w").write(s)
PY

# ---- register the vxworks colcon mixin (so --mixin vxworks works) ----------
log "register the vxworks colcon mixin"
export COLCON_HOME="$WS/.colcon"
rm -rf "$COLCON_HOME"; mkdir -p "$COLCON_HOME/mixin/default"
DISTRO_DIR="$REPO/pkg/ros2/files/lyrical"
export ROOT_DIR="$EXPORT_ROOT" BUILDSPECS_DIR="$REPO/buildspecs" \
       WIND_SDK_HOST_TOOLS="$WIND_SDK_HOME/vxsdk/host" \
       Python_INCLUDE_DIR="$WIND_CC_SYSROOT/usr/include/python3.9" \
       Python_LIBRARY="$WIND_CC_SYSROOT/usr/lib/common/libpython3.9.so.1.0" \
       Python3_NumPy_INCLUDE_DIR="" Python_SOABI="cpython-39-vxworks" \
       PYTHON_MODULE_EXTENSION=".so"
envsubst < "$DISTRO_DIR/vxworks.mixin.template" > "$COLCON_HOME/mixin/default/vxworks.mixin"
colcon mixin list 2>&1 | grep -q vxworks.mixin || die "vxworks mixin not registered"
info "colcon mixin list shows vxworks"

# ---- 4) colcon build --mixin vxworks ---------------------------------------
log "4) colcon build --mixin vxworks"
colcon build --paths src/hello_world --mixin vxworks \
  --cmake-args -DFORCE_BUILD_VENDOR_PKG=ON -DBUILD_TESTING=OFF -DBUILD_SHARED_LIB=ON \
  || die "colcon build --mixin vxworks failed"

# ---- 5) assert: VxWorks RTP linking the SDK's rclcpp -----------------------
log "5) verify the produced binary"
BIN="$WS/install/hello_world/lib/hello_world/hello_world_node"
[ -f "$BIN" ] || die "hello_world_node not produced"
desc="$(file -b "$BIN")"; info "file: $desc"
case "$SDK_ARCH" in
  aarch64) echo "$desc" | grep -qiE 'aarch64|ARM aarch64' || die "not aarch64: $desc" ;;
  x86_64)  echo "$desc" | grep -qiE 'x86-64|x86_64'       || die "not x86_64: $desc" ;;
esac
wr-readelf -l "$BIN" 2>/dev/null | grep -qE 'ld(64)?\.so\.1' \
  || info "note: could not confirm VxWorks RTP interpreter (non-fatal)"
wr-readelf -d "$BIN" 2>/dev/null | grep -qi 'librclcpp' \
  || die "binary does not link librclcpp from the SDK -> not built against ROS 2"
info "links librclcpp from the produced SDK (NEEDED)"

# ---- stage the RTP for the on-target run (part 2) --------------------------
# Copy the built binary into a USB-disk staging dir. Pass this dir to the test
# suite as VX_USB_DIR so qemu.exp attaches it as /bd0a and test09 can run it:
#   VX_USB_DIR=<dir> ./tests/main_script.exp output/ros2.img test09-ros2-sdk-hello
USB_DIR="${VX_USB_DIR:-/tmp/ros2-sdk-usb}"
rm -rf "$USB_DIR"; mkdir -p "$USB_DIR"
cp "$BIN" "$USB_DIR/hello_world_node"
info "staged RTP for the on-target run: $USB_DIR/hello_world_node"

log "PASS: ros2 pkg create + colcon build --mixin vxworks produced a $SDK_ARCH VxWorks RTP linking rclcpp"
echo
echo "Next (part 2 - run it on VxWorks/QEMU via the normal harness):"
echo "  VX_USB_DIR=$USB_DIR ./tests/main_script.exp output/ros2.img test09-ros2-sdk-hello"
