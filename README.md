# VxWorks® 7 ROS 2 Build

![vxworks ros2 build workflow](https://github.com/Wind-River/vxworks7-ros2-build/actions/workflows/vxworks-ros2-build.yml/badge.svg)

## VxWorks SDK and ROS 2 support

Wind River provides VxWorks ROS 2 build for selected SDKs and ROS 2 releases, see the following table for more details. The latest ROS 2 release is `iron` and the latest VxWorks SDK is `23.03`.

|           | [23.03 SDK](https://forums.windriver.com/t/vxworks-software-development-kit-sdk/43) |
|:---------:|:-------------|
|**[`humble`](https://docs.ros.org/en/humble/)**| [QEMU x86_64](https://labs.windriver.com/downloads/wrsdk-vxworks7-docs/2303/README_qemu.html) | |
|**[`iron`](https://docs.ros.org/en/iron/)**| [QEMU x86_64](https://labs.windriver.com/downloads/wrsdk-vxworks7-docs/2303/README_qemu.html) | |
|**[`rolling`](https://docs.ros.org/en/rolling/)**| [QEMU x86_64](https://labs.windriver.com/downloads/wrsdk-vxworks7-docs/2303/README_qemu.html) | |

## Prebuilt image

The VxWorks ROS 2 `iron` and `humble` images are prebuilt and can be tested by downloading them from [here](https://github.com/Wind-River/vxworks7-ros2-build/actions/workflows/vxworks-ros2-build.yml).

## Overview

The VxWorks 7 ROS 2 Build project provides a build environment to automate building
ROS 2 with a VxWorks SDK.

The Robot Operating System 2 is a set of software libraries and tools that
aid in building robot applications. ROS 2 is a re-architecture of the
framework to include support for new use cases.

These new use cases include:
* Teams of multiple robots
* Small embedded platforms
* Real-time systems
* Non-ideal networks
* Production environment
* Design patterns for building and structuring systems

The default configuration build configuration will build a minimal set of
ROS 2 packages are necessary for running the Turtlebot 3 and example Python and C++ applications.

This configuration is suited for prototyping and personal
use.  Please refer to the details of each individual ROS 2 package for details
on what requirements and terms of use they may have.

*NOTE*: ROS 2 is not part of any VxWorks® product. If you need help,
use the resources available or contact your Wind River sales representative
to arrange for consulting services.

## Project License

The source code for this project is provided under the Apache 2.0 license.
Text for the ROS 2 dependencies and other applicable license notices can be found in
the LICENSE file in the project top level directory. Different
files may be under different licenses. Each source file should include a
license notice that designates the licensing terms for the respective file.

*NOTE*: Your use of the VxWorks SDK is subject to the non-commercial use
license agreement that accompanies the software (the "License"). To review
the License, please read the file NCLA.txt which can be viewed from a
browser here: Non-Commercial License Agreement.

By downloading, installing or using the software, you acknowledge that you
have read, understand, and are agreeing to the terms of the License.
Subject to the License, you can proceed to download the VxWorks SDK.

## Prerequisite(s)

* Download a VxWorks Software Development Kit from Wind River Labs
   * [23.03 SDK](https://forums.windriver.com/t/vxworks-software-development-kit-sdk/43)

* The build system will need to download source code from github.com and bitbucket.org.  A
  working Internet connection with access to both sites is required.

For the standard build you must also have:

* Supported Linux host for both ROS 2 and VxWorks 7
   * ROS 2.0 Target Platforms
      * http://www.ros.org/reps/rep-2000.html
   * VxWorks 7 23.03
      * https://docs.windriver.com/bundle/vxworks_release_notes_23_03/page/index-release_notes.html
   * For ROS 2 Humble Hawksbill, Ubuntu Jammy (22.04) 64-bit LTS is the Tier 1 host
   * For ROS 2 Iron Irwini, Ubuntu Jammy (22.04) 64-bit LTS is the Tier 1 host
   * For ROS 2 Rolling Ridley, Ubuntu Jammy (22.04) 64-bit LTS is the Tier 1 host
* Docker Engine installed on your Linux host
   * https://docs.docker.com/engine/install/ubuntu/

## Branches

The following branches are active

- [x] `rolling-23.03` - builds [ROS 2 `rolling`](https://github.com/ros2/ros2/tree/rolling) against VxWorks `23.03` SDK
- [x] `iron-release-23.03` - builds [ROS 2 `iron-release`](https://github.com/ros2/ros2/tree/iron-release) against VxWorks `23.03` SDK
- [x] `humble-release-23.03` - builds [ROS 2 `humble-release`](https://github.com/ros2/ros2/tree/humble-release) against VxWorks `23.03` SDK
- [x] `master` - can build all other branches against VxWorks `23.03` SDK depending on what VxWorks SDK and what Docker image are used

## Directory Structure

The project uses Makefile to invoke a ros2 and turtlebot3 `colcon`-based build, and also builds some dependencies.

```bash
├── Docker          - Dockefiles used to build ROS 2
├── Makefile
├── pkg
│   ├── asio        - Fast-RTPS dependency
│   ├── colcon      - host tool to build ROS 2
│   ├── ros2        - ROS 2 middleware
│   ├── sdk         - various SDK improvements necessary to build ROS 2
│   ├── tinyxml2    - Fast-RTPS dependency
│   ├── turtlebot3  - Turtlebot3 packages
│   └── unixextra   - extra Unix functions necessary to build ROS 2
```

After the build following artifacts will be created:

```bash
├── build      - pkg build artifacts
    ├── asio
    ├── colcon
    ├── ros2
        ├── patches
        └── ros2_ws - ROS 2 workspace
    ├── tinyxml2
    └── unixextra
├── downloads  - download artifacts
├── export
    ├── deploy - a ready-to-deploy filesystem with ROS 2 libraries and binaries
    └── root   - development artifacts with ROS 2 libraries and headers
``` 

## ROS 2 VxWorks patches

Patches are necessary to build ROS 2 for VxWorks, and are located in the separate [`layer` repository](https://github.com/Wind-River/vxworks7-layer-for-ros2)
The repository is cloned during the build to the *patches* dir.

```bash
├── build
│   ├── ros2
│   │   ├── patches
```

The branch name of the `layer` repository is the same as the name of the `build` repository.

## Build ROS 2 and its dependencies

### Clone this repository using the `master` branch

```bash
git clone https://github.com/Wind-River/vxworks7-ros2-build.git
cd vxworks7-ros2-build
```

### Build Docker image

A Docker (Ubuntu 22.04) based build is recommended to avoid the necessity of installing build dependencies.

```bash
docker build --no-cache -t vxbuild:22.04 Docker/22.04/vxbuild/.
docker build --no-cache -t vxros2build:humble Docker/22.04/vxros2build/.

docker build --no-cache --build-arg ROS_DISTRO=iron -t vxros2build:iron Docker/22.04/vxros2build/.
docker build --no-cache --build-arg ROS_DISTRO=rolling -t vxros2build:iron Docker/22.04/vxros2build/.
```

### Download and extract the VxWorks SDK

The 23.03 SDK for IA - QEMU x86_64 shall be used from https://forums.windriver.com/t/vxworks-software-development-kit-sdk/43

```bash
cd ~/Downloads 
wget https://d13321s3lxgewa.cloudfront.net/wrsdk-vxworks7-qemu-1.12.tar.bz2
mkdir ~/Downloads/wrsdk && cd ~/Downloads/wrsdk
tar –jxvf ~/Downloads/wrsdk-vxworks7-qemu-1.12.tar.bz2 --strip 1
```

### Run Docker image

```bash
cd vxworks7-ros2-build
docker run -ti -v ~/Downloads/wrsdk:/wrsdk -v $PWD:/work vxros2build:humble
```

By default it runs as a user ```wruser``` with ```uid=1000(wruser) gid=1000(wruser)```, if you have different ids, run it as

```bash
$ docker run -ti -e UID=`id -u` -e GID=`id -g` -v ~/Downloads/wrsdk:/wrsdk -v $PWD:/work vxros2build:humble
```

See [Dockerfile](Docker/vxbuild/Dockerfile) for the complete list of environment variables

### Start build

Inside the Docker container: check the `ROS_DISTRO` version, source the development environment and start build

```bash
wruser@d19165730517:/work echo $ROS_DISTRO
humble

wruser@d19165730517:/work source /wrsdk/sdkenv.sh
wruser@d19165730517:/work make
wruser@d19165730517:/work exit
```

Build artifacts are in the `export` directory

```bash
wruser@d19165730517:/work ls export/deploy/
bin  lib
```

Rebuild from scratch

```bahs
wruser@d19165730517:/work make distclean
wruser@d19165730517:/work make
wruser@d19165730517:/work exit
```

It could be that the build fails if it runs behind the firewall, see [#22](https://github.com/Wind-River/vxworks7-ros2-build/issues/22).
In this case, rerun it without a certificate check as

```bash
wruser@d19165730517:/work WGET_OPT="--no-check-certificate -O" CURL="" make
```

## Run ROS 2 examples

QEMU is used to boot VxWorks and run Python and C++ ROS 2 examples, for that `tap0` interface shall be configured.

```bash
sudo apt-get install uml-utilities
sudo tunctl -u $USER -t tap0
sudo ifconfig tap0 192.168.200.254 up
```

VxWorks is tested with

```bash
$ qemu-system-x86_64 --version
QEMU emulator version 6.2.0 (Debian 1:6.2+dfsg-2ubuntu6.2)
Copyright (c) 2003-2021 Fabrice Bellard and the QEMU Project developers
```

A filesystem with ROS 2 artifacts needs to be prepared to boot with VxWorks.

### Create an HDD image

Run QEMU with a prebuilt VxWorks kernel and a created HDD image.

```bash
# create a disk 1024MB
$ dd if=/dev/zero of=ros2.img count=1024 bs=1M
# format it as a FAT32
$ mkfs.vfat -F 32 ./ros2.img

# mount, copy, unmount, you need to be `sudo`
$ mkdir -p ~/tmp/mount
$ sudo mount -o loop -t vfat ./ros2.img ~/tmp/mount
$ sudo cp -r -L ./export/deploy/* ~/tmp/mount/.
$ sudo umount ~/tmp/mount
```

```bash
sudo qemu-system-x86_64 -m 512M -kernel ~/Downloads/wrsdk/vxsdk/bsps/*/vxWorks -net nic -net tap,ifname=tap0,script=no,downscript=no -display none -serial stdio -append "bootline:fs(0,0)host:/vxWorks h=192.168.200.254 e=192.168.200.1 u=ftp pw=ftp123 o=gei0 s=/ata4/vxscript" -device ich9-ahci,id=ahci -drive file=./ros2.img,if=none,id=ros2disk,format=raw -device ide-hd,drive=ros2disk,bus=ahci.0
```

The HDD image will be mounted inside VxWorks under the `/usr` directory

```bash
-> ls "/usr"
/usr/bin
/usr/lib
/usr/share
/usr/vxscript
```

### Telnet to the VxWorks QEMU target

```bash
telnet 192.168.200.1
```

### Run ROS 2 C++ examples

It is possible to run examples by directly invoking binaries

```bash
-> cmd
[vxWorks *]# /usr/lib/examples_rclcpp_minimal_timer/timer_lambda
Launching process 'timer_lambda' ...
Process 'timer_lambda' (process Id = 0xffff80000046f070) launched.
[INFO] [minimal_timer]: Hello, world!
[INFO] [minimal_timer]: Hello, world!
```

Or by using the `ros2cli` interface

```bash
-> cmd
[vxWorks *]# python3 ros2 run examples_rclcpp_minimal_timer timer_lambda
Launching process 'python3' ...
Process 'python3' (process Id = 0xffff800008268ac0) launched.
[INFO] [minimal_timer]: Hello, world!
[INFO] [minimal_timer]: Hello, world!
```

### Run ROS 2 Python examples

It is possible to run examples by directly invoking Python scripts. First, figure out the full path.

```bash
[vxWorks *]# python3 ros2 pkg executables --full-path demo_nodes_py
 Launching process 'python3' ...
 Process 'python3' (process Id = 0xffff80000046f070) launched.
/usr/lib/demo_nodes_py/add_two_ints_client
/usr/lib/demo_nodes_py/add_two_ints_client_async
/usr/lib/demo_nodes_py/add_two_ints_server
/usr/lib/demo_nodes_py/listener
/usr/lib/demo_nodes_py/listener_qos
/usr/lib/demo_nodes_py/listener_serialized
/usr/lib/demo_nodes_py/talker
/usr/lib/demo_nodes_py/talker_qos
```

Then invoke the Python interpreter and pass the script as a parameter

```bash
[vxWorks *]# python3 /usr/lib/demo_nodes_py/talker
[INFO] [talker]: Publishing: "Hello World: 0"
[INFO] [talker]: Publishing: "Hello World: 1"
```

Or by using the `ros2cli` interface

```bash
[vxWorks *]# python3 ros2 run demo_nodes_py talker
Launching process 'python3' ...
Process 'python3' (process Id = 0xffff800008269c00) launched.

[INFO] [talker]: Publishing: "Hello World: 0"
[INFO] [talker]: Publishing: "Hello World: 1"
```

## Build a simple CMake-based OSS project

```
$ cd vxworks7-ros2-build
$ docker run -ti -v ~/Downloads/wrsdk:/wrsdk -v $PWD:/work vxros2build:humble
wruser@690af330acaa:/work$ source /wrsdk/sdkenv.sh

wruser@690af330acaa:/work$ git clone https://github.com/ttroy50/cmake-examples.git
wruser@690af330acaa:/work$ cd cmake-examples/01-basic/A-hello-cmake; mkdir vxworks-build; cd vxworks-build
wruser@690af330acaa:/work/cmake-examples/01-basic/A-hello-cmake/vxworks-build$ cmake .. -DCMAKE_TOOLCHAIN_FILE=/work/buildspecs/cmake/toolchain.cmake
-- The C compiler identification is Clang 9.0.1
-- The CXX compiler identification is Clang 9.0.1
-- Check for working C compiler: /wrsdk/toolkit/host_tools/x86_64-linux/bin/wr-cc
-- Check for working C compiler: /wrsdk/toolkit/host_tools/x86_64-linux/bin/wr-cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /wrsdk/toolkit/host_tools/x86_64-linux/bin/wr-c++
-- Check for working CXX compiler: /wrsdk/toolkit/host_tools/x86_64-linux/bin/wr-c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Configuring done
-- Generating done
-- Build files have been written to: /work/cmake-examples/01-basic/A-hello-cmake/vxworks-build

wruser@690af330acaa:/work/cmake-examples/01-basic/A-hello-cmake/vxworks-build$ make
Scanning dependencies of target hello_cmake
[ 50%] Building CXX object CMakeFiles/hello_cmake.dir/main.cpp.o
[100%] Linking CXX executable hello_cmake
[100%] Built target hello_cmake
```

## Native ROS 2 compilation

Native ROS 2 is used mostly for fast prototyping during ROS 2 development. Use the same docker image for that.

```bash
$ cd vxworks7-ros2-build
$ docker run -ti -h ros2native -v $PWD:/work vxros2build:humble
wruser@ros2native:/work$ mkdir -p ros2_native/src && cd ros2_native
wruser@ros2native:/work/ros2_native$ vcs import src < /work/build/ros2/ros2_ws/ros2.repos
wruser@ros2native:/work/ros2_native$ colcon build --merge-install --cmake-force-configure --packages-up-to-regex examples_rcl* ros2action ros2component ros2node ros2pkg ros2service ros2topic ros2cli ros2lifecycle ros2multicast ros2param ros2run  --cmake-args -DCMAKE_BUILD_TYPE:STRING=Debug -DBUILD_TESTING:BOOL=OFF

wruser@ros2native:/work/ros2_native/install$ source setup.bash
wruser@ros2native:/work/ros2_native/install$ ros2 run demo_nodes_py talker
[INFO] [talker]: Publishing: "Hello World: 0"
[INFO] [talker]: Publishing: "Hello World: 1"
```

## VxWorks ROS 2 development

The following example shows how to develop and run ROS 2 package called `my_package` under VxWorks. It is recommended to prototype it first under the native ROS 2 build environment that contains the same ROS 2 version as a VxWorks one. After the package is developed and tested, it can be copied and compiled under VxWorks ROS 2 build environment.

### Step 1: create and test a new ROS 2 package under the native ROS 2 build environment

1. Follow [the procedure](#native-ros2-compilation) of how to prepare native ROS 2 build environment.
2. Create a new ROS 2 package

```bash
wruser@ros2native:/work$ cd ros2_native/src
wruser@ros2native:/work/ros2_native/src$ source ../install/setup.bash
wruser@ros2native:/work/ros2_native/src$ ros2 pkg create --build-type ament_cmake my_package
going to create a new package
package name: my_package
destination directory: /work/ros2_ws/src
package format: 3
version: 0.0.0
description: TODO: Package description
maintainer: ['wruser <wruser@todo.todo>']
licenses: ['TODO: License declaration']
build type: ament_cmake
dependencies: []
creating folder ./my_package
creating ./my_package/package.xml
creating source and include folder
creating folder ./my_package/src
creating folder ./my_package/include/my_package
creating ./my_package/CMakeLists.txt
```

3. Create `my_package.cpp` file

```bash
wruser@ros2native:/work/ros2_native/src$ cd my_package/src
wruser@ros2native:/work/ros2_native/src/my_package/src$ cat > my_package.cpp <<EOF
#include <iostream>

using namespace std;

int main(int argc, char * argv[])
{
  cout << "Hello World!" << endl;
  return 0;
}
EOF
```

4. Modify `CMakeLists.txt` to build `my_package`

Add the following lines to the `CMakeLists.txt` before `if(BUILD_TESTING)`

```bash
add_executable(my_package src/my_package.cpp)

install(TARGETS
  my_package
  DESTINATION lib/${PROJECT_NAME}
)
```

You can use `sed` for it.

```bash
wruser@ros2native:/work/ros2_native/src/my_package$ sed -i '/find_package(<depen/aadd_executable(my_package src/my_package.cpp)\ninstall(TARGETS\n  my_package\n  DESTINATION lib/\${PROJECT_NAME}\n)' CMakeLists.txt
```

5. Build `my_package`

```bash
wruser@ros2native:/work/ros2_native/src/my_package$ cd ../..
wruser@ros2native:/work/ros2_native$ colcon build --merge-install --packages-up-to my_package
```

6. Run `my_package`

```bash
wruser@ros2native:/work/ros2_native$ source install/setup.bash
wruser@ros2native:/work/ros2_native/install$ ros2 run my_package my_package
Hello World!
```

### Step 2: Build and run a new ROS 2 package under VxWorks ROS 2 build environment

1. Start docker and copy `my_package` to the VxWorks `ros2_ws` workspace

```bash
$ docker run -ti -v ~/Downloads/wrsdk:/wrsdk -v $PWD:/work vxros2build:humble
wruser@690af330acaa:/work$ cp -r ros2_native/src/my_package build/ros2/ros2_ws/src/.
```

2. Rebuild ROS 2 with `my_package`

```bash
wruser@690af330acaa:/work$ source /wrsdk/sdkenv.sh
wruser@690af330acaa:/work$ rm /work/build/.stamp/ros2.build
wruser@690af330acaa:/work$ PKG_PKGS_UP_TO=my_package DEFAULT_BUILD=ros2 make
wruser@690af330acaa:/work$ exit
```

3. Create `ros2.img` as described [here](#create-an-hdd-image) and start QEMU

```bash
$ sudo qemu-system-x86_64 -m 512M -kernel ~/Downloads/wrsdk/vxsdk/bsps/*/vxWorks -net nic -net tap,ifname=tap0,script=no,downscript=no -display none -serial stdio -append "bootline:fs(0,0)host:/vxWorks h=192.168.200.254 e=192.168.200.1 u=ftp pw=ftp123 o=gei0 s=/ata4/vxscript" -device ich9-ahci,id=ahci -drive file=./ros2.img,if=none,id=ros2disk,format=raw -device ide-hd,drive=ros2disk,bus=ahci.0
```

4. Setup environment variables and run `my_package`

```bash
-> cmd
[vxWorks *]# python3 ros2 run my_package my_package
Launching process 'python3' ...
Process 'python3' (process Id = 0xffff80000036cb10) launched.
Hello World!
```

5. Create `my_package` VxWorks 7 OCI container image

Follow the instructions [here](/examples/vxc/my_package/README.md)

## Legal Notices

All product names, logos, and brands are property of their respective owners. All company,
product and service names used in this software are for identification purposes only.
Wind River and VxWorks are registered trademarks of Wind River Systems, Inc. UNIX is a
registered trademark of The Open Group.

Disclaimer of Warranty / No Support: Wind River does not provide support
and maintenance services for this software, under Wind River’s standard
Software Support and Maintenance Agreement or otherwise. Unless required
by applicable law, Wind River provides the software (and each contributor
provides its contribution) on an “AS IS” BASIS, WITHOUT WARRANTIES OF ANY
KIND, either express or implied, including, without limitation, any warranties
of TITLE, NONINFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR
PURPOSE. You are solely responsible for determining the appropriateness of
using or redistributing the software and assume any risks associated with
your exercise of permissions under the license.
