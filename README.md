VxWorks® 7 ROS2 Build Scripts
===
---

# Overview

The VxWorks 7 ROS2 Build Scripts provide build scripts to automate building
ROS2 for VxWorks 7 SR0620.

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

This layer is an adapter to make standard ROS2 build and run on
VxWorks. This layer does not contain the ROS2 source, it only
contains all functions required to allow ROS2 to build and execute
on top of VxWorks. Use this layer to add the ROS2 framework to your 
user space, and to build the ROS2 example applications as RTPs.

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

# Prerequisite(s)

* Install the Wind River® VxWorks® 7 operating system version SR0620.

* The build system will need to download source code from github.com and bitbucket.org.  A
  working Internet connection with access to both sites is required.

* A user-writeable VxWorks 7 product installation that may be patched with
  changes specific to building ROS2.

For the standard build you must also have:

* Supported Linux host for both ROS2 and VxWorks 7
   * ROS 2.0 Target Platforms
      * http://www.ros.org/reps/rep-2000.html
   * VxWorks 7 SR0620
      * https://docs.windriver.com/bundle/vxworks_7_release_notes_sr0620/page/bym1551818657142.html
   * For ROS2 Dashing Diademata, Ubuntu Bionic (18.04) LTS is the Tier 1 host
* Install the development tools and ROS tools from “Building ROS 2 on Linux”
   * https://index.ros.org/doc/ros2/Installation/Linux-Development-Setup/
* Install the “Required Linux Host OS Packages” for VxWorks 7
   * https://docs.windriver.com/bundle/Workbench_4_Release_Notes_SR0620_1/page/age1436590316395.html
* Mercurial (hg) package for Eigen

# Standard Build

Use the git command to clone the vxworks7-ros2-build repository from GitHub.  
The scripts assume your VxWorks 7 installation is located in /opt/windriver 
with the workspace directory at /opt/windriver/workspace.

If these defaults are fine, then you may just execute make to start your build:

	make

If you need to override these defaults you may set the INSTALL_DIR and WORKSPACE
environment variables in your shell or manually specify them as make variables:

Using environment variables:
```
export INSTALL_DIR=/opt/windriver
export WORKSPACE=/opt/windriver/workspace
make
```

Using make variables:
```
make INSTALL_DIR=/opt/windriver WORKSPACE=/opt/windriver/workspace
```

Should you encounter any errors which cause the build to fail.  You may run 
"make" again to resume from where it stopped.

# Docker Build

Starting in vxworks7-ros2-builds, go into the Docker subdirectory.

1. Change directories into the vxprodinstaller subdirectory
```
cd vxprodinstaller
```
2. Build the container image using the Docker tool
```
sudo docker build -t vxprodinstaller:1.0 .
```
3. Go up one directory to return to the Docker directory
```
cd ..
```
4. Repeat steps 1 to 3 for vxbuild and vxros2build by replacing vxprodinstaller in the commands.


## Installing VxWorks 7 SR0620

Download the VxWorks 7 on-line installer for Linux from your WindShare account.
Go to the directory where the installer zip file is located and follow the steps below.

Create a windshare.txt file with your Wind River Support Network username and 
password.   This is done to pass this information to the installer without 
your password being saved in your shell history or in the Docker container logs. 

windshare.txt
```
USERNAME=youruser
PASSWORD=yourpassword
```

Create a Docker volume named vxinstall to store the VxWorks 7 installation directory.
```
sudo docker volume create vxinstall
```

Run the vxprodinstaller container image with Docker to perform a complete 
install.  The time this step can take may vary depending on your network 
connection and speed of your computer.

```
sudo docker run --rm --env-file windshare.txt -v vxinstall:/opt/windriver -v $PWD:/work vxprodinstaller
```


## Build VxWorks 7 and ROS2

Go to the vxworks7-ros2-build directory where you cloned the GitHub repository.
```
cd vxworks7-ros2-build
```

Create a new Docker volume to store the contents of the build.
```
sudo docker volume create vx7ROS2workspace
```

Execute the build using the vxros2build container image which has all the necessary 
dependencies for both VxWorks 7 and ROS2.  For this step, we must also supply our 
Wind River License file to ensure that the build tools will execute.

```
sudo docker run  --rm -v vxinstall:/opt/windriver     \
    -v $HOME/encryptedLicense.lic:/opt/windriver/license/zwrsLicense.lic \
    -v vx7ROS2workspace:/opt/windriver/workspace \
    -v $PWD:/work \
    vxros2build:1.0 make
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
