VxWorks® 7 ROS2 Build Scripts
===
---

# Overview

The VxWorks 7 ROS2 Build Scripts provide build scripts to automate building
ROS2 with a VxWorks SDK.

The Robot Operating System 2 is a set of software libraries and tools that
aid in building robot applications. ROS2 is a re-architecture of the
framework to include support for new use cases.

These new use cases include:
* Teams of multiple robots
* Small embedded platforms
* Real-time systems
* Non-ideal networks
* Production environment
* Design patterns for building and structuring systems


The default configuration build configuration will build a minimal set of
ROS2 packages necessary for running the example applications.

This configuration is suited for prototyping and personal
use.  Please refer to the details of each individual ROS2 package for details
on what requirements and terms of use they may have.

*NOTE*: ROS2 is not part of any VxWorks® product. If you need help,
use the resources available or contact your Wind River sales representative
to arrange for consulting services.

# Project License

The source code for this project is provided under the Apache 2.0 license license.
Text for the ROS2 dependencies and other applicable license notices can be found in
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

# Prerequisite(s)

* Download a VxWorks Software Development Kit from Wind River Labs
   * https://labs.windriver.com/downloads/wrsdk.html

* The build system will need to download source code from github.com and bitbucket.org.  A
  working Internet connection with access to both sites is required.

For the standard build you must also have:

* Supported Linux host for both ROS2 and VxWorks 7
   * ROS 2.0 Target Platforms
      * http://www.ros.org/reps/rep-2000.html
   * VxWorks 7 SR0640
      * https://docs.windriver.com/bundle/vxworks_7_release_notes_sr0640/page/bym1551818657142.html
   * For ROS2 Dashing Diademata, Ubuntu Bionic (18.04) 64-bit LTS is the Tier 1 host
* Install the development tools and ROS tools from “Building ROS 2 on Linux”
   * https://index.ros.org/doc/ros2/Installation/Dashing/Linux-Development-Setup/
* Install the “Required Linux Host OS Packages”  for VxWorks 7
   * https://docs.windriver.com/bundle/2020_03_Workbench_Release_Notes_SR0640_1/page/age1436590316395.html
* Mercurial (hg) package for Eigen (optional)

## Directory Structure
Packages
```
├── Docker
├── Makefile
├── pkg
│   ├── asio
│   ├── ros2
│   ├── tinyxml2
│   ├── turtlebot3
│   └── unixextra
```
It uses Makefile to invoke ros2 and turtlebot3 colcon build, and also build some dependencies.
A Docker (Ubuntu 18.04) based build is used to avoid a necessity for installing build dependencies.
Build Artifacs
```
├── build     - pkg build artifacts
├── downloads - download arctifacts
├── export    - a ready-to-deploy filesystem with ROS2 libraries and binaries
``` 

## ROS2 VxWorks patches
ROS2 patches for VxWorks are located in the separate repository
https://github.com/Wind-River/vxworks7-layer-for-ros2

It is cloned during the build to the *patches* dir
```
├── pkg
│   ├── ros2
│   │   ├── patches

```
## Build VxWorks 7 and ROS2

Clone this repository using the master branch
```
git clone https://github.com/Wind-River/vxworks7-ros2-build.git
cd vxworks7-ros2-build
```

Build Docker image
```
cd Docker/vxbuild
docker build -t vxbuild:1.0 .
cd Docker/vxros2build
docker build -t vxros2build:1.0 .
```

Download the VxWorks SDK for IA - UP Squared from https://labs.windriver.com/downloads/wrsdk.html
```
wget https://labs.windriver.com/downloads/wrsdk-vxworks7-up2-1.6.tar.bz2
```

Extract the VxWorks SDK tarball
```
tar –jxvf wrsdk-vxworks7-up2-1.6.tar.bz2
```

Run Docker image
```
cd vxworks7-ros2-build
docker run -ti -v <path-to-the-wrsdk>:/wrsdk -v $PWD:/work vxros2build:1.0
```

Inside Docker container: Source the development environment
```
wruser@d19165730517:/work source /wrsdk/toolkit/wind_sdk_env.linux
```

Inside Docker container: Run make to build ROS2 using the SDK
```
wruser@d19165730517:/work make
```

Buid artifacts are in export directory
```
wruser@d19165730517:/work ls export/root/
include  lib  llvm
```

Rebuild from scratch
```
wruser@d19165730517:/work make distclean
wruser@d19165730517:/work make
```

## Run ROS2 examples

Run QEMU
```
sudo apt-get install uml-utilities
sudo tunctl -u $USER -t tap0
sudo ifconfig tap0 192.168.200.254 up

cd vxworks7-ros2-build
qemu-system-x86_64 -m 512M  -kernel $WIND_SDK_TOOLKIT/../bsps/itl_generic_2_0_2_1/boot/vxWorks -net nic  -net tap,ifname=tap0,script=no,downscript=no -display none -serial stdio -monitor none -append "bootline:fs(0,0)host:vxWorks h=192.168.200.254 e=192.168.200.1 u=target pw=boot o=gei0" -usb -device usb-ehci,id=ehci  -device usb-storage,drive=fat32 -drive file=fat:ro:./export/root,id=fat32,format=raw,if=none
```
Run QEMU with a prebuilt VxWorks kernel and the *export* directory mounted as a USB device

Run ROS2 example
```
telnet 192.168.200.1
```

```
-> cmd
[vxWorks *]# set env LD_LIBRARY_PATH="/bd0a/lib"
[vxWorks *]# cd  /bd0a/llvm/bin/
[vxWorks *]# rtp exec -u 0x20000 timer_lambda.vxe
Launching process 'timer_lambda.vxe' ...
Process 'timer_lambda.vxe' (process Id = 0xffff80000046f070) launched.
[INFO] [minimal_timer]: Hello, world!
[INFO] [minimal_timer]: Hello, world!
[INFO] [minimal_timer]: Hello, world!
[INFO] [minimal_timer]: Hello, world!
```

## Build a simple CMake based OSS project

```
git clone https://github.com/Wind-River/vxworks7-ros2-build.git
cd vxworks7-ros2-build
export WIND_USR_MK=$PWD/mk/usr
export TOP_BUILDDIR=$PWD
export PACKAGE_DIR=$PWD/pkg

git clone https://github.com/leethomason/tinyxml2.git
cd tinyxml2; mkdir vxworks-build; cd vxworks-build
cmake .. -DCMAKE_MODULE_PATH=$TOP_BUILDDIR/buildspecs/cmake -DCMAKE_TOOLCHAIN_FILE=$TOP_BUILDDIR/buildspecs/cmake/rtp.cmake
make VERBOSE=1
```

# Legal Notices

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
