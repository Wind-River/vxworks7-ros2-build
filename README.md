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
   * VxWorks 7 SR0620
      * https://docs.windriver.com/bundle/Release_Notes_SR0610_1/page/jgn1464040947636.html
   * For ROS2 Dashing Diademata, Ubuntu Bionic (18.04) 64-bit LTS is the Tier 1 host
* Install the development tools and ROS tools from “Building ROS 2 on Linux”
   * https://index.ros.org/doc/ros2/Installation/Dashing/Linux-Development-Setup/
* Install the “Required Linux Host OS Packages”  for VxWorks 7
   * https://docs.windriver.com/bundle/Workbench_4_Release_Notes_SR0610_1/page/age1446069416293.html
* Mercurial (hg) package for Eigen (optional)

## Build VxWorks 7 and ROS2

Clone this repository using the wrsdk branch
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

Extract the VxWorks SDK tarball
```
tar –jxvf wrsdk-vxworks7-qemu-1.3.tar.bz2
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
