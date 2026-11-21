<!-- toolkit/RELEASE_NOTES.in.md
     Curated notes appended to the auto-generated per-toolkit RELEASE_NOTES.md by
     make-toolkit.sh. Identity/contents are auto-generated; keep this TLDR. -->

## Use

1. `tar -xf toolkit-<release>-<distro>-<arch>.tar.*` and `cd` into it.
2. Install the Wind River VxWorks SDK (not shipped).
3. `./scripts/ros2sdk-prepare.sh <sdk>` — apply the overlay (once).
4. `source ./scripts/ros2sdkenv.sh`
5. `ros2 pkg create ...` + `colcon build --mixin vxworks`
6. `./scripts/run-qemu.sh --usb <bindir>`

See `README.md` for details.

## Features

- C++17 (rclcpp), Python 3.9 (rclpy), Rust 1.85 (rclrs)
- `colcon build --mixin vxworks` → VxWorks RTP (C++/Rust); Python runs on target
- `scripts/selftest-build.sh [--lang all|cpp|rust|python]` → builds+deploys a
  hello-world per language; tests `test09`/`test10`/`test11`
- run on QEMU (binary via USB `/bd0a`, no image repack)
- VS Code dev container + build/run tasks
- extensible — build more ROS 2 packages on top of `export/root`

## Known limitations

- `export/root` not fully relocatable (build-time path in some cmake/ament/`.pc`).
- Host `ros2` CLI uses a tiny rclpy shim (target rclpy can't load on host).
- Rust (rclrs) support is present only if this toolkit was built with `ROS2_RUST`
  (the rclrs crate sources ship under `export/root/share/*/rust`).
- `run-qemu.sh` needs `tap0` @ `192.168.200.254` (root, set up once).
- VS Code: edit + build + run; in-editor RTP debug not wired.
