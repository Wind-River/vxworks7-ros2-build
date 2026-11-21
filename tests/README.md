# ROS 2 VxWorks Test Suite

This directory contains automated Expect-based test scripts for verifying ROS 2 functionality on a VxWorks target using QEMU.

## Structure

```bash
/tests
├── main_script.exp   # Entry point: boots VxWorks in QEMU, runs the selected suites/tests
├── lib/              # Expect libraries (vxworks, qemu, telnet)
├── ros2/             # suite: ROS 2 nodes from the image (default)
│   ├── test01-env.exp                # Validate environment setup
│   ├── test02-timer_lambda.exp       # C++ timer lambda execution
│   ├── test03-timer_lambda_py.exp    # Python timer lambda execution
│   ├── test04-talker.exp             # C++ talker/listener (Fast-DDS, shared memory)
│   ├── test05-sros2.exp              # SROS 2 secure talker/listener (skips if no keystore)
│   ├── test06-rclrs.exp              # Rust rclrs pub/sub (Fast-DDS, shared memory)
│   ├── test07-talker-udpv4.exp       # C++ talker/listener (Fast-DDS, UDPv4)
│   └── test08-talker-cyclonedds.exp  # C++ talker/listener (CycloneDDS, loopback)
├── toolkit/          # suite: nodes the SDK toolkit built (needs VX_USB, /bd0a)
│   ├── test01-cpp-hello.exp
│   ├── test02-rust-hello.exp
│   └── test03-python-hello.exp
└── unixextra/        # suite: unixextra C function tests (needs VX_USB, /bd0a)
    └── test01-functions.exp          # runs every *_test binary in VX_USB
```

Each suite numbers its tests from 01. The tables below describe the `ros2` suite;
`toolkit` is produced by `toolkit/scripts/selftest-build.sh`, `unixextra` by
`pkg/unixextra` (`flock`, `posix_fallocate`, `socketpair`, `vdprintf`).

## Tests

| Test | What it verifies | RMW / transport |
|------|------------------|-----------------|
| `test01-env` | Target env is set (`LD_LIBRARY_PATH`, `AMENT_PREFIX_PATH`, `ROS_LOG_DIR`) | — |
| `test02-timer_lambda` | C++ timer lambda node (`Hello, world!`) | — |
| `test03-timer_lambda_py` | Python timer lambda node (`Hello, world!`) | — |
| `test04-talker` | C++ `demo_nodes_cpp` talker (`Publishing`) + telnet listener (`I heard`) | `rmw_fastrtps_cpp` / SHM |
| `test05-sros2` | SROS 2 secure pub/sub: talker (`Publishing`) + telnet listener (`I heard`), each with its enclave, `ROS_SECURITY_STRATEGY=Enforce`; **skips** if `/usr/demo_keystore/public` has no `ca.cert.pem` | `rmw_fastrtps_cpp` |
| `test06-rclrs` | Rust `examples_rclrs_minimal_pub_sub` publisher/subscriber (`Publishing`) | `rmw_fastrtps_cpp` / SHM |
| `test07-talker-udpv4` | Same talker/listener as test04 but forcing the UDPv4 builtin transport (no shared memory) | `rmw_fastrtps_cpp` / UDPv4 |
| `test08-talker-cyclonedds` | Same talker/listener as test04 under CycloneDDS; points `CYCLONEDDS_URI` at the shipped `/usr/cyclonedds.xml` (loopback `127.0.0.1`) so the two RTPs discover each other | `rmw_cyclonedds_cpp` / loopback |

Transport env is set **per-RTP**, so pub/sub tests set `RMW_IMPLEMENTATION` (and the
transport knob) on **both** consoles — the serial console (publisher/talker) and the
telnet console (subscriber/listener). CycloneDDS does not use
`FASTDDS_BUILTIN_TRANSPORTS`; it needs `CYCLONEDDS_URI` bound to loopback, otherwise
the talker publishes but the listener stays silent.


## Prerequisites

- QEMU (`qemu-system-x86_64` for x86; a GENET+SD-patched `qemu-system-aarch64` for
  raspi4b — see *Targets* below)
- A valid `ros2.img` disk image in the current directory or passed as an argument
- VxWorks kernel image available at `$WIND_SDK_HOME/vxsdk/bsps/**/vxWorks` (x86) or
  `**/uVxWorks` (raspi4b)
- Expect (`expect` CLI tool)
- Network interface `tap0` configured and up with IP `192.168.200.254`

### Example `tap0` Setup

```bash
sudo ip tuntap add dev tap0 mode tap
sudo ip addr add 192.168.200.254/24 dev tap0
sudo ip link set tap0 up
```

## Usage

```bash
./main_script.exp [<ros2.img>] [<suite>|<suite>/<test> ...]
```

- `<ros2.img>` — image path (default `./ros2.img`).
- `<suite>` — a directory under `tests/` (`ros2` is the default); runs all its tests.
- `<suite>/<test>` — one test, with or without `.exp`. Anything else is the image path.
- `toolkit` and `unixextra` need `VX_USB=<dir>`, a host dir attached as `/bd0a`
  that holds the binaries; without it the script exits with an error. The dir
  is a USB disk: EHCI on x86, xHCI behind the PCIe root port on raspi4b.

```bash
./main_script.exp ros2.img                               # the ros2 suite
./main_script.exp ros2.img ros2/test06-rclrs             # just one test
./main_script.exp ros2.img ros2/test04-talker ros2/test06-rclrs   # a subset
VX_USB=<dir> ./main_script.exp ros2.img unixextra        # the unixextra suite
```

To see usage instructions:

```
./main_script.exp --help
```

### Targets: x86_64 and aarch64 (raspi4b)

The suite auto-detects the target from the SDK you have sourced (the BSP dir under
`$WIND_SDK_HOME/vxsdk/bsps`): `itl_generic*` → x86_64, `rpi_4*` → raspi4b. Behavior is
tuned per target and controlled by these env vars:

| Var | Default | Purpose |
|-----|---------|---------|
| `VX_TARGET` | auto (from SDK BSP) | force `x86` or `rpi4` |
| `VX_QEMU` | `qemu-system-x86_64` / `qemu-system-aarch64` (PATH) | QEMU binary |
| `VX_DTB` | `<kernel-dir>/rpi-4b.dtb` (stock SDK dtb) | raspi4 device tree |
| `VX_BOOTLINE` | `fs(0,0)...o=genet0 f=0x0 s=/sd0/vxscript` | raspi4 boot line (via `-append`) |
| `VX_TIMEOUT` | `60` (x86) / `300` (raspi4) | per-command Expect timeout (s) |

**x86_64** (default, KVM-accelerated):

```bash
source /path/to/wrsdk-vxworks7-qemu/sdkenv.sh
./tests/main_script.exp output/ros2.img ros2
```

**aarch64 / raspi4b** — needs a QEMU with the BCM2838 GENET + SD→emmc2 model
(`razr/qemu` branch `raspi4b-vxworks`); stock `qemu-system-aarch64` won't work, so
point `VX_QEMU` at your build. Fully emulated (TCG, no KVM) so it is slow — the 300 s
default timeout accounts for that.

```bash
cd <harness>
source ~/Downloads/wrsdk-vxworks7-raspberrypi4b-1.9.0/sdkenv.sh
VX_QEMU=/path/to/patched/qemu-system-aarch64 \
  ./tests/main_script.exp output-rpi-4/ros2.img
```

Run a single test (recommended on raspi4, since TCG boot is slow):

```bash
VX_QEMU=/path/to/patched/qemu-system-aarch64 \
  ./tests/main_script.exp output-rpi-4/ros2.img ros2/test02-timer_lambda
```

The raspi4 boot line is passed via QEMU `-append` (lands in the dtb `/chosen/bootargs`,
which VxWorks reads via `vxFdtBootargsGet`) — the stock SDK dtb is used unmodified.

## How It Works

- `main_script.exp` launches `QEMU` with the ROS 2 image and VxWorks kernel.
- Once the `->` shell prompt is detected, it:
  - Sources the `test*.exp` scripts of the selected suites, in order.
  - Automatically detects and runs all procedures starting with test.
  - Sends necessary keystrokes and awaits test completion markers.
  - Exits QEMU via `Ctrl-A x` after all tests run.

Each test script defines one or more `test*` procedures that are called in order.

