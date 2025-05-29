# ROS 2 VxWorks Test Suite

This directory contains automated Expect-based test scripts for verifying ROS 2 functionality on a VxWorks target using QEMU.

## Structure

```bash
/tests
├── main_script.exp # Main entry point: launches QEMU, boots VxWorks, and runs all tests
├── test01-env.exp # Test: Validate environment setup
├── test02-timer_lambda.exp # Test: C++ timer lambda execution
├── test03-timer_lambda_py.exp # Test: Python timer lambda execution
├── test04-talker.exp # Test: C++ talker node
├── test05-sros2.exp # Test: SROS 2 security functionality
```


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
./main_script.exp [ros2.img]
```

If no image is specified, it defaults to ./ros2.img.
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

