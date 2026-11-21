# AGENTS.md - ROS 2 VxWorks toolkit

Instructions for AI coding assistants working in a project that uses this
toolkit. `README.md` has the full steps; this file has what an assistant needs
to get right. Paths are relative to the toolkit root.

## What this is

A prebuilt ROS 2 SDK for VxWorks 7 (`export/root/`), a bootable target image
(`ros2.img`), scripts and on-target tests. The user builds their own ROS 2
packages against it; ROS 2 itself is not rebuilt. Applications run on VxWorks
as user-space processes (RTPs). See `manifest.json` for the ROS 2 distro,
VxWorks release and target architecture.

## Build

```bash
./scripts/ros2sdk-prepare.sh /path/to/wrsdk   # once per toolkit location
source ./scripts/ros2sdkenv.sh                # in every new shell
colcon build --mixin vxworks                  # cross-compiles for VxWorks
optimize-python-startup install               # after building Python packages
```

- Always build with `--mixin vxworks`. A plain `colcon build` builds for the
  host and the result does not run on VxWorks.
- Use the tools on `PATH` after sourcing `ros2sdkenv.sh` (`cmake`, `python3`,
  `colcon`, the `wr-cc`/`wr-c++` compilers), not the host's copies.
- Package types: `ament_cmake` (C++, `rclcpp`), `ament_python` (`rclpy`),
  `ament_cargo` (Rust, `rclrs`, add `<depend>rclrs</depend>`).

## Run

```bash
./scripts/run-qemu.sh --usb install/<pkg>/lib/<pkg>   # QEMU x86_64
```

On the target: `cmd`, then `/bd0a/<executable>`. Quit QEMU with `Ctrl-A x`.
QEMU needs `tap0` at `192.168.200.254/24` (set up once by the user, as root).
`tests/main_script.exp` runs the on-target tests (needs `expect`, `telnet`).

## Rules for generated code

- **C++17.** The compiler is clang 18 and accepts `-std=c++20`, but the C++
  standard library (Dinkum) implements C++17: `<ranges>`, `<concepts>`,
  `<format>`, `<span>` do not exist. `std::filesystem`, `std::optional`,
  `std::variant` work. The `vxworks` mixin sets `CMAKE_CXX_STANDARD 17`; do not
  raise it.
- **VxWorks is not Linux.** Do not use `fork`/`exec*`/`waitpid`, `epoll`,
  `inotify`, `eventfd`, `signalfd`, `execinfo.h`/`backtrace`. Before using a
  less common POSIX header or function, check that it exists in the SDK sysroot
  (`$WIND_CC_SYSROOT/usr/h`); if it is missing, guard the code with
  `#ifdef __VXWORKS__` and use an alternative.
- **Python on the target is 3.9.** Do not use newer syntax or modules
  (`match`, `X | Y` type unions at runtime, `tomllib`).
- **Shared libraries.** Build libraries shared (`BUILD_SHARED_LIBS=ON`), as the
  ROS 2 SDK is.
- **Cross-compiling.** Do not add `try_run()` or other configure checks that run
  a built program; they cannot run on the host. If a package's tests do not
  configure, build with `--cmake-args -DBUILD_TESTING=OFF`.

## Do not modify

- the VxWorks SDK directory (only `ros2sdk-prepare.sh` installs into it);
- `export/root/` (the ROS 2 SDK) and `sdk-overlay/`;
- `ros2.img` directly; rebuild it with `scripts/extract-deploy.sh` +
  `scripts/make-image.sh` (see `README.md`).

Put the user's packages in their own workspace (`src/`), not in the toolkit.
