# ROS 2 SDK — build + run a Hello World app

This directory tests the **ROS 2 SDK**: that the artifacts the project produces
are a usable SDK a developer can build their own ROS 2 application against and
run on VxWorks.

## Why a ROS 2 SDK?

The main build (`make ros2`) cross-compiles a large set of ROS 2 packages for
VxWorks and installs them into a single prefix, `output/export/root`. That prefix
is the **ROS 2 SDK**: a relocatable tree that contains, for the target
architecture,

- the **core libraries** — `rclcpp`, `rcl`, `rmw` + an RMW implementation
  (Fast-DDS / CycloneDDS), the `rosidl` typesupports, the message packages
  (`std_msgs`, …);
- the **build tooling** a consumer needs — `ament_cmake` and its extensions, the
  CMake package configs (`find_package(rclcpp)` etc.), and the colcon `vxworks`
  mixin;
- the **host tools** — the Python 3.9 `colcon`, `vcs`, and the `ros2` CLI
  (`ros2 pkg create`, …) built for the build host.

The point of shipping an SDK (rather than only a prebuilt `ros2.img`) is that a
downstream developer can **create a brand-new package, build it against the SDK,
and run it on the target** — without rebuilding ROS 2 from source. If any of the
three groups above is missing or wrong, that workflow breaks. This test exercises
exactly that workflow end to end, so a broken or incomplete SDK is caught.

## How it works

A ROS 2 app build has a clear **host vs target** split, and the SDK serves both:

- **Host side:** `ros2 pkg create` scaffolds the package and `colcon` drives the
  build — both run on the build host (Python 3.9 tools from the SDK). You source
  `sdkenv.sh` (the VxWorks cross toolchain: `wr-cc`/`wr-c++`, sysroot) **and**
  `output/export/root/setup.bash` (puts the SDK's CMake configs on
  `CMAKE_PREFIX_PATH`, the host tools on `PATH`).
- **Target side:** the compiled package is a **VxWorks RTP** linked against the
  SDK's target `.so`s (`librclcpp.so`, …). It runs on VxWorks under QEMU, finding
  its libraries via the environment the image's `/ata0/vxscript` sets up
  (`LD_LIBRARY_PATH=/usr/lib`, `AMENT_PREFIX_PATH=/usr`, `rtpSpStackSize`, …).

The cross-build itself is driven by the colcon **`vxworks` mixin**, which points
`CMAKE_FIND_ROOT_PATH` at `output/export/root` (so `find_package` resolves the
SDK), selects the VxWorks toolchain file, and sets the target Python/link flags —
the same mixin the SDK's own `make ros2` uses.

So the test has **two parts**:

### Part 1 — build (host, no QEMU)

`test-ros2-hello-world.sh` does, non-relocatable (the export tree is used in
place):

**1. Create the workspace:**

```bash
mkdir ros_ws && cd ros_ws
```

**2. Set up the environment.** Four things, each with a distinct purpose:

```bash
# (a) the VxWorks cross toolchain: puts wr-cc/wr-c++, colcon, cmake, the host
#     ros2 CLI on PATH, and sets WIND_SDK_* / WIND_SDK_CC_SYSROOT.
source ~/Downloads/wrsdk-vxworks7-qemu-<ver>/sdkenv.sh

# (b) tell the toolchain file where the target sysroot is (headers + target libs).
export WIND_CC_SYSROOT=$WIND_SDK_CC_SYSROOT

# (c) disable colcon's build-time library_path extension so a cross-build does
#     NOT inject the TARGET .so dirs into the HOST build subprocess LD_LIBRARY_PATH
#     (they are VxWorks libs, useless/harmful on the host). The SDK's own
#     make ros2 sets the same flag.
export COLCON_EXTENSION_BLOCKLIST=colcon_core.environment.library_path

# (d) overlay the produced ROS 2 SDK: puts its CMake package configs on
#     CMAKE_PREFIX_PATH / AMENT_PREFIX_PATH and its host python tools on PATH,
#     so find_package(rclcpp) etc. resolve and `ros2 pkg create` is available.
source output/export/root/setup.bash
```

**3. Create the package and add a node:**

```bash
ros2 pkg create --build-type ament_cmake hello_world
#   ... then write a minimal rclcpp node (publisher + 500 ms timer logging
#   "Hello, world!") into src/hello_world/src/, and add rclcpp/std_msgs deps.
```

**4. Cross-build it against the SDK** (the `vxworks` mixin points
`CMAKE_FIND_ROOT_PATH` at `output/export/root` and selects the VxWorks toolchain):

```bash
colcon build --mixin vxworks \
  --cmake-args -DFORCE_BUILD_VENDOR_PKG=ON -DBUILD_TESTING=OFF -DBUILD_SHARED_LIB=ON
```

**5. Verify + stage:** assert the output is a **VxWorks RTP** that links the SDK's
`librclcpp`, then copy the binary into a USB-disk staging dir (default
`/tmp/ros2-sdk-usb`) for part 2.

### Part 2 — run on VxWorks/QEMU (normal harness)

`../test09-ros2-sdk-hello.exp` is a regular `test*.exp`, so it runs through
`../main_script.exp` like every other test. The built binary is delivered to the
target as a **USB mass-storage disk**: set `VX_USB_DIR` and `qemu.exp` attaches
that directory as `/bd0a` at boot. The test runs `/bd0a/hello_world_node` and
expects `Hello, world!`.

## Run

```bash
# source a FULL ROS 2 SDK's matching VxWorks SDK (x86_64 for the x86_64 export root)
source ~/Downloads/wrsdk-vxworks7-qemu-<ver>/sdkenv.sh

# Part 1: build + verify the RTP; stages it into /tmp/ros2-sdk-usb
./tests/ros2-sdk/test-ros2-hello-world.sh

# Part 2: run it on the target via the normal harness (VX_USB_DIR -> /bd0a)
VX_USB_DIR=/tmp/ros2-sdk-usb \
  ./tests/main_script.exp output/ros2.img test09-ros2-sdk-hello
```

Part 1 exits `0` and prints `PASS`; `VX_WS` overrides its build workspace, and
`VX_SDK=<wrsdk dir>` lets it source the SDK itself. Part 2 runs the whole suite
(or just the named test) with the Hello World binary attached; `test09` **skips
cleanly** if `VX_USB_DIR` is not set (so a normal suite run is unaffected).

The `VX_USB_DIR` knob in `qemu.exp` is general: set it to any host directory to
expose its files on the target as `/bd0a` for a run.

### Run it by hand (raw QEMU, no harness)

If you want to drive it interactively instead of through the Expect harness,
after part 1 boot QEMU directly with the staging dir attached as a USB disk:

```bash
qemu-system-x86_64 -enable-kvm -smp 8 -m 2G -machine q35 -cpu Nehalem \
  -kernel $WIND_SDK_HOME/vxsdk/bsps/itl_generic_*/vxWorks \
  -net nic -net tap,ifname=tap0,script=no,downscript=no \
  -display none -serial mon:stdio \
  -append "bootline:fs(0,0)host:/vxWorks h=192.168.200.254 e=192.168.200.1 g=192.168.200.254 u=ftp pw=ftp123 o=gei0 s=/ata0/vxscript" \
  -device ich9-ahci,id=ahci \
  -drive file=output/ros2.img,if=none,id=ros2disk,format=raw \
  -device ide-hd,drive=ros2disk,bus=ahci.0 \
  -usb -device usb-ehci,id=ehci -device usb-storage,drive=fat32 \
  -drive file=fat:rw:/tmp/ros2-sdk-usb,id=fat32,format=raw,if=none
```

`ros2.img` mounts as `/ata0` and runs `/ata0/vxscript` (which sets up `/usr`,
`LD_LIBRARY_PATH`, `AMENT_PREFIX_PATH`, `rtpSpStackSize`, …); the USB staging dir
appears as `/bd0a`. At the command shell, run the RTP:

```
-> cmd
[vxWorks *]# /bd0a/hello_world_node
Launching process '/bd0a/hello_world_node' ...
Process '/bd0a/hello_world_node' (process Id = 0xffff800018a22000) launched.
[INFO] [...] [hello_world]: Hello, world!
[INFO] [...] [hello_world]: Hello, world!
[INFO] [...] [hello_world]: Hello, world!
```

Stop the node with `Ctrl-C`, and quit QEMU with `Ctrl-A x`. (Requires `tap0` up
at `192.168.200.254`.)

## Requirements / notes

- **A full ROS 2 SDK** at `output/export/root` — i.e. `make ros2` has installed
  `ament_cmake` + `rclcpp` + the host `ros2` CLI (`ros2pkg`). Part 1 fails fast
  with a clear message if the export root is vendor-only (no rclcpp/ament_cmake).
- The SDK **arch must match** the export tree (the x86_64 export root needs an
  x86_64 `wrsdk-vxworks7-qemu` SDK).
- `ros2 pkg create` is a **host** tool from `export/root`. Its `ros2` CLI
  entrypoint eagerly imports `rclpy`, whose C-extension in `export/root` is built
  for the **target** (VxWorks) and cannot load on the host — so part 1 invokes the
  real `ros2pkg` *CreateVerb* (the exact `pkg create` code path, which does not
  need rclpy) rather than the `ros2` wrapper script.
- The generated `CMakeLists.txt` is adjusted to **C++17** (the Dinkum C++ library
  ceiling) and uses modern targets (`rclcpp::rclcpp`, `${std_msgs_TARGETS}`).
- The ROS 2 runtime env on the target (`LD_LIBRARY_PATH=/usr/lib`,
  `AMENT_PREFIX_PATH=/usr`, `rtpSpStackSize`, …) is set by the image's
  `/ata0/vxscript` at boot, so part 2 just launches the RTP by path.
