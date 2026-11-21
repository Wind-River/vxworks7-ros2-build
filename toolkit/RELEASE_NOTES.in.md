<!-- toolkit/RELEASE_NOTES.in.md
     Curated notes appended to the auto-generated per-toolkit RELEASE_NOTES.md by
     make-toolkit.sh. Identity/contents are auto-generated; keep this TLDR. -->

## Requirements

- The Wind River VxWorks SDK matching the identity above (not shipped): download it
  from https://labs.windriver.com/vxworks-sdk/.
- QEMU: `qemu-system-x86_64` for x86_64; for aarch64 (raspi4b) the patched
  `qemu-system-aarch64-raspi4` from `razr/qemu-raspi4-deb` (stock QEMU cannot boot it).
- `tap0` up at `192.168.200.254/24` for the target network (root, set up once; see
  `README.md`).
- `zstd`, `mtools`, `dosfstools` on the host.
- `expect` and `telnet` for the on-target tests (`tests/`, shipped; the pub/sub tests
  open a second target shell over telnet). `run-qemu.sh` needs neither.

## Use

1. `tar -xf toolkit-<release>-<distro>-<arch>.tar.*` and `cd` into it.
2. Install the SDK (see Requirements).
3. `./scripts/ros2sdk-prepare.sh <sdk>` — install the SDK overlay and relocate the
   ROS 2 SDK to this directory (once).
4. `source ./scripts/ros2sdkenv.sh`
5. `ros2 pkg create ...` + `colcon build --mixin vxworks`
6. x86_64: `./scripts/run-qemu.sh --usb <bindir>` boots `ros2.img` with your binary as `/bd0a`.

See `README.md` for details.

## Features

- C++17 (rclcpp), Python 3.9 (rclpy), Rust 1.85 (rclrs)
- `colcon build --mixin vxworks` → VxWorks RTP (C++/Rust); Python runs on target
- `scripts/selftest-build.sh [--lang all|cpp|rust|python]` → builds a hello node per
  language and stages it on a USB dir; `tests/main_script.exp ros2.img toolkit` checks
  them on QEMU (`tests/toolkit`: `test01-cpp-hello`, `test02-rust-hello`,
  `test03-python-hello`); `tests/main_script.exp ros2.img` checks the image (`tests/ros2`)
- run on QEMU with the binary on a USB disk (`/bd0a`), no image repack
- VS Code build/run tasks (`.vscode/`)
- extensible — build more ROS 2 packages on top of `export/root`

## Known limitations

- Host `ros2` CLI uses a tiny rclpy shim (target rclpy can't load on host).
- Rust (rclrs) support is present only if this toolkit was built with `ROS2_RUST`
  (the rclrs crate sources ship under `export/root/share/*/rust`).
- `run-qemu.sh` boots x86_64 only. For aarch64 (raspi4b) start QEMU by hand; the USB
  disk there is xHCI behind PCIe (`-device qemu-xhci,bus=pcie.1,msi=off,msix=off`).
- aarch64 (raspi4b) on QEMU is emulated (no KVM for the board model): boot takes ~2 min,
  a Python node several minutes.
- VS Code: edit + build + run; in-editor RTP debug not wired.
