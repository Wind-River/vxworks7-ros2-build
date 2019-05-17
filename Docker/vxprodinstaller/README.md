Installing VxWorks with Docker
==============================

This package will create a container image that is a development environment for VxWorks 7. Using it makes it easy to use VxWorks.

This can be used in the following ways:
- as an interactive development environment
- as a previous layer to a build or SDK container

# Install Docker

```
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
```

NOTE: If you wish to run docker without sudo you must logout and back in

# Download the Wind River Installer

In order to download the installer, you will need a Wind River account.

   1. Go to Wind Share (https://windshare.windriver.com/) and log in with your Wind River account.
   2. You should see the heading *Wind Share - Wind River's Download and Installation Portal* 
   3. Click on *My Products* on the left-hand side.
   4. On the *My Products* page, look for a heading with *VxWorks* in large font.
   5. Click the plus sign next to *VxWorks 7* to display the *Installation Options*.
   6. Scroll down to *Option 2: Online installation*.
   7. Click on the red button titled, *Installer for Linux*.
   8. Wait for the file with the name *vxworks_7_r2_linux_*.zip to download.
   9. Copy this file to the *vxprodinstaller* directory.

# Build the vxprodinstaller

Change directories to vxprodinstaller directory where this README.md is found.

```
docker build -t vxprodinstaller:1.0 .
```


NOTE: If building on Windows please use --config core.autocrlf=input to
check out the Dockerfile with UNIX line endings, otherwise your Docker
container will fail to run.  Also, you may use --platform linux when
running the Docker container.

# Run the Docker image

NOTE: Some Linux distributions, like Ubuntu, use dnsmasq to cache DNS queries
locally.  This can cause problems with DNS from inside the container on corporate
network. Please add *--network host* to the docker command to workaround this problem.

```
rm windshare.txt
echo USERNAME=myuser >> windshare.txt
echo PASSWORD=mypassword >> windshare.txt
```

## Use Case A: Create a new Docker image containing a VxWorks installation

```
docker run --env-file windshare.txt -v $PWD:/work vxprodinstaller:1.0
docker ps
docker commit c3f279d17e0a vxworks7:201901231742
docker run --rm -it --entrypoint /bin/bash vxworks7:201901231742
```


## Use Case B: Create a Docker volume

```
docker volume create --name vxinstall
docker run --rm --env-file windshare.txt -v $PWD:/work -v vxinstall:/opt/windriver vxprodinstaller:1.0
```

Use the volume with any other Docker container of your choice
```
docker run -it -v vxinstall:/opt/windriver ubuntu:18.04
```

NOTE: The Docker container you choose must have the appropriate 32-bit dependencies
installed in order for wrenv.sh, Wind River Workbench, and the VxWorks build system
to run.  You may refer to the Dockerfile to see an example of the packages needed
by Ubuntu Linux 18.04

## Use Case C: Install to your host machine

Bind mount /opt/windriver into the Docker container

```
docker run --rm --env-file windshare.txt -v $PWD:/work -v /opt/windriver:/opt/windriver vxprodinstaller:1.0
```

Alternatively, you may set environment variables to configure the installation

```
docker run --rm --env-file windshare.txt \
  -v /opt/windriver:/opt/windriver \
  -e UID=$(id -u $MYUSER) \
  -e GID=$(id -g $MYGROUP) \
  -e INSTALL_DIR=/opt/windriver \
  vxprodinstaller:1.0
```

## Use Case D: Skip Docker entirely

The install_vxworks.sh script used by the Docker container image works for native
installations as well.  You must install any required host packages yourself
before executing the script.   Packages for Ubuntu 18.04 are listed in the
Dockerfile.   Packages for other Linux distributions may be found in the VxWorks
documentation.

> USERNAME=myuser PASSWORD=mypassword ./install_vxworks.sh

If you want to change the default installation directory you may change it using
environment variables.

```
INSTALL_DIR=/opt/windriver/vxworks-7-20190319 USERNAME=myuser PASSWORD=mypassword ./install_vxworks.sh
```
