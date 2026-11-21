<!-- RELEASE_NOTES.in.md - template for the notes of a vxworks7-ros2-build release.

     Tag: <distro>-<vxworks release>-v<major>.<minor>, e.g. lyrical-26.03-v1.0;
     release candidates <tag>-rc<m> (lyrical-26.03-v1.0-rc1). The version counts the
     releases of one distro/VxWorks pair, from v1.0: minor = fixes and additions that
     do not affect users of a toolkit; major = changes that do (export/root layout,
     SDK package, script interfaces).

     Release steps:
       1. tag the harness commit the release CI run built:  git tag -a <tag>
       2. tag the layer (vxworks7-layer-for-ros2) at the commit that build used
          (toolkit manifest.json: layer.commit) with the same <tag>
       3. copy this file to RELEASE_NOTES-<tag>.md (not committed), fill every <...>
       4. gh release create <tag> --title "<tag>" --notes-file RELEASE_NOTES-<tag>.md \
            toolkit-<vxworks>-<distro>-x86_64.tar.zst toolkit-<vxworks>-<distro>-aarch64.tar.zst
-->

# <tag>

ROS 2 **<distro>** for VxWorks **<vxworks release>**, built from
`vxworks7-ros2-build` @ `<harness commit>`.

## Overview

`vxworks7-ros2-build` cross-compiles ROS 2 from source for VxWorks 7: the ROS 2
packages run as VxWorks user-space processes (RTPs). It builds against a vanilla
Wind River VxWorks SDK, applies the VxWorks support from `vxworks7-layer-for-ros2`
and the SDK fixes ROS 2 needs, and verifies the result on QEMU.

A release provides:

- **The build** (this repo at the tag): `make` builds ROS 2 <distro> for an SDK,
  `make image` packs the bootable target image `ros2.img` (VxWorks startup script +
  ROS 2 runtime), `make toolkit` packs the toolkit.
- **The toolkit** per target (assets below): the prebuilt ROS 2 SDK, an overlay
  that adds what ROS 2 needs to a vanilla VxWorks SDK, `ros2.img`, the scripts and
  the on-target tests. With it you build your own ROS 2 packages for VxWorks
  (`colcon build --mixin vxworks`) without building ROS 2 itself.

ROS 2 on the target:

- client libraries: C++ (`rclcpp`, C++17), Python 3.9 (`rclpy`), Rust (`rclrs`);
- middleware: Fast DDS (shared memory, UDPv4) and Cyclone DDS;
- SROS 2 security (DDS Security, enclaves from a keystore);
- the ROS 2 examples and demo nodes.

Targets: VxWorks SDKs for QEMU x86_64 and for Raspberry Pi 4 (aarch64; tested on
QEMU `raspi4b`). Every release passes the on-target tests (`tests/`, results below).

## Quick start

Download the VxWorks SDK for your target from https://labs.windriver.com/vxworks-sdk/
and the toolkit for that target from the assets below. Booting on QEMU needs
`tap0` once (root):

```bash
sudo ip tuntap add dev tap0 mode tap
sudo ip addr add 192.168.200.254/24 dev tap0
sudo ip link set tap0 up
```

### Run ROS 2 on VxWorks

QEMU x86_64, with the x86_64 toolkit and the qemu SDK:

```bash
tar -xf toolkit-<vxworks>-<distro>-x86_64.tar.zst && cd toolkit-<vxworks>-<distro>-x86_64
WRSDK=/path/to/wrsdk-vxworks7-qemu ./scripts/run-qemu.sh
```

Raspberry Pi 4 on QEMU `raspi4b`, with the aarch64 toolkit, the raspberrypi4b SDK
and the QEMU from `razr/qemu-raspi4-deb` `<qemu release>`
(`qemu-system-aarch64-raspi4`):

```bash
tar -xf toolkit-<vxworks>-<distro>-aarch64.tar.zst && cd toolkit-<vxworks>-<distro>-aarch64
BSP=$(dirname $(find /path/to/wrsdk-vxworks7-raspberrypi4b/vxsdk/bsps -name uVxWorks))
qemu-system-aarch64-raspi4 -M raspi4b -smp 4 -m 2G -nographic \
  -kernel $BSP/uVxWorks -dtb $BSP/rpi-4b.dtb \
  -append "fs(0,0)host:vxWorks h=192.168.200.254 e=192.168.200.1:ffffff00 g=192.168.200.254 u=target pw=vxTarget o=genet0 f=0x0 s=/sd0/vxscript" \
  -nic tap,ifname=tap0,model=bcm2838-genet,script=no,downscript=no \
  -sd ros2.img -serial null -serial mon:stdio
```

On the target:

```
-> cmd
[vxWorks *]# /usr/lib/demo_nodes_cpp/talker
```

Quit QEMU with `Ctrl-A x`.

### Build your own ROS 2 application

```bash
./scripts/ros2sdk-prepare.sh /path/to/wrsdk   # once
source ./scripts/ros2sdkenv.sh
ros2 pkg create --build-type ament_cmake my_app
colcon build --mixin vxworks
```

Attach the build output as a USB disk; on the target it is `/bd0a/my_app`:

- x86_64: `./scripts/run-qemu.sh --usb install/my_app/lib/my_app`
- raspi4b: add to the QEMU command above
  `-device qemu-xhci,id=xhci,bus=pcie.1,msi=off,msix=off -device usb-storage,bus=xhci.0,drive=fat32 -drive file=fat:rw:install/my_app/lib/my_app,id=fat32,format=raw,if=none`

C++, Python and Rust packages, the self-test and the image customization are
described in the toolkit's `README.md`.

### Rebuild ROS 2 from source

Check out this repo at `<tag>` and follow its `README.md` (`make`, `make image`,
`make toolkit` in the `vxros2build` Docker container). Only needed for more
packages, your own patches or another SDK.

## This release

| | |
|---|---|
| ROS 2 distro | `<distro>` (`pkg/ros2/files/<distro>/`) |
| VxWorks release | `<vxworks release>` |
| VxWorks SDKs | qemu x86_64: `<wrsdk-vxworks7-qemu-x.y.z>`; raspberrypi4b aarch64: `<wrsdk-vxworks7-raspberrypi4b-x.y.z>` |
| ROS 2 layer | `vxworks7-layer-for-ros2` tag `<tag>` = branch `<distro>-release-<vxworks release>` @ `<layer commit>` |
| Build container | Ubuntu `<ubuntu>` (`Docker/<ubuntu>/`) |
| QEMU (x86_64 tests) | distro `qemu-system-x86` `<x.y.z>` of the CI runner (version printed in the `setup-qemu` step of the CI run) |
| QEMU (raspi4b tests) | `razr/qemu-raspi4-deb` `<qemu release>` (from `razr/qemu` `raspi4b-vxworks` @ `<qemu commit>`) |
| CI run | `<run url>` |

## Requirements

To use a toolkit: see its `RELEASE_NOTES.md`. To build everything from source
(`make`, `make image`, `make toolkit`) with this repo:

- Docker: the build runs in the `vxros2build:<distro>` container
  (`Docker/<ubuntu>/vxbuild` → `vxros2build`).
- The Wind River VxWorks SDKs above (not shipped; download them from
  https://labs.windriver.com/vxworks-sdk/), mounted into the container.
- For the on-target tests (`tests/`): QEMU (`qemu-system-x86_64`; for raspi4b the
  `razr/qemu-raspi4-deb` release above), `expect`, `telnet`, and `tap0` up at
  `192.168.200.254/24` (root, set up once).

## Assets

| File | What |
|---|---|
| `toolkit-<vxworks>-<distro>-x86_64.tar.zst` | ROS 2 VxWorks SDK toolkit for the qemu x86_64 SDK (see its `RELEASE_NOTES.md`) |
| `toolkit-<vxworks>-<distro>-aarch64.tar.zst` | the same for the raspberrypi4b SDK |

Only our own builds are attached. Third-party software (the VxWorks SDKs, QEMU and
the raspi4b QEMU package, Docker) is not: get it as listed under Requirements and
"This release".

## Test results

On QEMU, from the CI run above (`tests/`, per suite):

| Suite | x86_64 | raspi4b |
|---|---|---|
| `ros2` (test01-07, test99-sros2) | <n passed / n> | <n passed / n> |
| `toolkit` (test01-03) | <...> | <...> |
| `unixextra` (test01) | <...> | — |

## Changes since <previous tag>

- <change, one line each; group as SDK fixes / build / toolkit / tests / CI>

## Known issues

- <issue: symptom, scope (target, test), workaround>
