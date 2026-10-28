# ROS 2 VxWorks Test Suite

This directory contains automated Expect-based test scripts for verifying ROS 2 functionality on a VxWorks target using QEMU.

## Structure

```bash
/tests
├── main_script.exp # Main entry point: launches QEMU, boots VxWorks, and runs all tests
├── test01-env.exp # Test: Validate environment setup
├── test02-timer_lambda.exp # Test: C++ timer lambda execution
├── test03-timer_lambda_py.exp # Test: Python timer lambda execution
├── test04-talker.exp # Test: C++ talker/listener (Fast-DDS, shared memory)
├── test05-sros2.exp # Test: SROS 2 security functionality (skips if no keystore)
├── test06-rclrs.exp # Test: Rust rclrs pub/sub (Fast-DDS, shared memory)
├── test07-talker-udpv4.exp # Test: C++ talker/listener (Fast-DDS, UDPv4 transport)
└── test08-talker-cyclonedds.exp # Test: C++ talker/listener (CycloneDDS RMW, loopback)
```

## Tests

| Test | What it verifies | RMW / transport |
|------|------------------|-----------------|
| `test01-env` | Target env is set (`LD_LIBRARY_PATH`, `AMENT_PREFIX_PATH`, `ROS_LOG_DIR`) | — |
| `test02-timer_lambda` | C++ timer lambda node (`Hello, world!`) | — |
| `test03-timer_lambda_py` | Python timer lambda node (`Hello, world!`) | — |
| `test04-talker` | C++ `demo_nodes_cpp` talker (`Publishing`) + telnet listener (`I heard`) | `rmw_fastrtps_cpp` / SHM |
| `test05-sros2` | SROS 2 security (`Found security directory` + `Publishing`); **skips** if `/usr/demo_keystore/public` has no `ca.cert.pem` | `rmw_fastrtps_cpp` |
| `test06-rclrs` | Rust `examples_rclrs_minimal_pub_sub` publisher/subscriber (`Publishing`) | `rmw_fastrtps_cpp` / SHM |
| `test07-talker-udpv4` | Same talker/listener as test04 but forcing the UDPv4 builtin transport (no shared memory) | `rmw_fastrtps_cpp` / UDPv4 |
| `test08-talker-cyclonedds` | Same talker/listener as test04 under CycloneDDS; points `CYCLONEDDS_URI` at the shipped `/usr/cyclonedds.xml` (loopback `127.0.0.1`) so the two RTPs discover each other | `rmw_cyclonedds_cpp` / loopback |

Transport env is set **per-RTP**, so pub/sub tests set `RMW_IMPLEMENTATION` (and the
transport knob) on **both** consoles — the serial console (publisher/talker) and the
telnet console (subscriber/listener). CycloneDDS does not use
`FASTDDS_BUILTIN_TRANSPORTS`; it needs `CYCLONEDDS_URI` bound to loopback, otherwise
the talker publishes but the listener stays silent.


## Prerequisites

- QEMU (`qemu-system-x86_64`)
- A valid `ros2.img` disk image in the current directory or passed as an argument
- VxWorks kernel image available at `$WIND_SDK_HOME/vxsdk/bsps/**/vxWorks`
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
./main_script.exp [<ros2.img>] [test ...]
```

- `<ros2.img>` — image path (default `./ros2.img`).
- `test ...` — one or more test names to run (default: **all**). A test name is any
  argument starting with `test`, with or without the `.exp` suffix; anything else is
  treated as the image path.

```bash
./main_script.exp ros2.img                          # all tests
./main_script.exp ros2.img test06-rclrs             # just one test
./main_script.exp ros2.img test04-talker test06-rclrs   # a subset
./main_script.exp test08-talker-cyclonedds          # default image, one test
```

To see usage instructions:

```
./main_script.exp --help
```

## How It Works

- `main_script.exp` launches `QEMU` with the ROS 2 image and VxWorks kernel.
- Once the `->` shell prompt is detected, it:
  - Dynamically sources all test scripts named `test*.exp`.
  - Automatically detects and runs all procedures starting with test.
  - Sends necessary keystrokes and awaits test completion markers.
  - Exits QEMU via `Ctrl-A x` after all tests run.

Each test script defines one or more `test*` procedures that are called in order.

