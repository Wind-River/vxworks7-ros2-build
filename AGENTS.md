# AGENTS.md - vxworks7-ros2-build

Instructions for AI coding assistants changing this repo. `README.md` has the
full user steps. For the rules on code that runs on VxWorks (C++17, POSIX gaps,
Python 3.9) see `toolkit/AGENTS.md`; they apply here too.

## What this repo is

A Makefile harness that cross-compiles ROS 2 from source for VxWorks 7 user
space (RTPs) against a vanilla Wind River VxWorks SDK, packs a bootable image
(`ros2.img`) and a toolkit for application developers, and tests both on QEMU.

| Path | What |
|---|---|
| `Makefile`, `mk/` | top-level targets and shared make definitions |
| `pkg/<pkg>/` | one package each (`Makefile`, `files/`); `pkg/ros2/files/<distro>/` holds the ROS 2 package lists, `.repos`, mixins and `vxscript.*` |
| `pkg/sdk/files/<vxworks release>/` | SDK fixes ROS 2 needs, applied through the SDK overlay |
| `buildspecs/cmake/toolchain.cmake` | the CMake toolchain file |
| `Docker/<ubuntu>/` | the `vxbuild` and `vxros2build` build containers |
| `tests/` | on-target Expect tests: `main_script.exp`, `lib/`, suites `ros2`, `toolkit`, `unixextra` |
| `toolkit/` | `make-toolkit.sh`, the toolkit's scripts, `README.md`, `AGENTS.md` and release-notes template |
| `.github/` | CI: per-target workflows, the reusable build workflow, `setup-qemu`/`setup-wrsdk` actions |
| `output/` | build output (not committed) |

## Scope

Change only the current release: ROS 2 **lyrical**, VxWorks **26.03**, Ubuntu
**26.04** (`pkg/*/files/26.03/`, `pkg/ros2/files/lyrical/`, `Docker/26.04/`,
the `lyrical-26.03-*` workflows). Leave the files of older releases alone.

## Build

In the `vxros2build:lyrical` container, with the SDK mounted at `/wrsdk`:

```bash
source /wrsdk/sdkenv.sh
make info        # check the configuration
make             # build ROS 2 and its dependencies -> output/export/root
make image       # pack output/ros2.img
make toolkit     # pack the toolkit tarball
```

## Test

```bash
tests/main_script.exp output/ros2.img                    # the ros2 suite
tests/main_script.exp output/ros2.img ros2/test04-talker # one test
VX_USB=<dir> tests/main_script.exp output/ros2.img toolkit
```

Needs QEMU, `expect`, `telnet` and `tap0` up at `192.168.200.254/24`. The target
(x86_64 or raspi4b) follows the sourced SDK; `VX_TARGET` overrides it.

- Tests are `tests/<suite>/test<NN>-<name>.exp`, numbered per suite and run in
  sorted order. SROS2 is `ros2/test99-sros2.exp` so it runs last.
- `main_script.exp` restores the boot environment and closes telnet sessions
  after every test, pass or fail. Tests do not clean up their own environment.
- Shell semantics go in `tests/lib/vxworks.exp`, the QEMU transport in
  `lib/qemu.exp`, telnet in `lib/telnet.exp`.

## Where a fix goes

- ROS 2 source patches: the layer repo `vxworks7-layer-for-ros2`, branch
  `lyrical-release-26.03`, cloned by the build into `output/build/ros2/patches`.
  Not in this repo.
- SDK problems: `pkg/sdk/files/26.03/` (applied by the SDK overlay). Never edit
  the SDK itself.
- ROS 2 package selection, ignores, vendors: `pkg/ros2/files/lyrical/`.
- Build options: CMake cache variables and mixins before source patches.

## Release

Manual, following the steps at the top of `RELEASE_NOTES.in.md`: tags
`<distro>-<vxworks>-v<major>.<minor>` (e.g. `lyrical-26.03-v1.0`) on this repo
and on the layer, toolkits taken from green CI runs. Only our own builds are
attached; no SDKs, QEMU or Docker images.
