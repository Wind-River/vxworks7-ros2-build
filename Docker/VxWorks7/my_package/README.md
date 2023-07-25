# Building VxWorks Container Image for "my_package" Example

This document provides a guide for creating a container image for the "my_package" example. This image is designed to run on VxWorks 7.

This container can be used in several ways:
- As a standalone deployment unit, which can be shared either publicly or within a team.
- It can be stored on one of the following registries:
    - Docker Hub registry
    - Amazon Elastic Container Registry (Amazon ECR)
    - Harbor registry

## Prerequisites 

Before proceeding with the container creation, make sure you have the following:

- The `my_package` ROS2 package has been created and cross-compiled. Follow the instructions [here](../../../README.md#vxworks-ros-2-development).
- VSB and VIP have been configured to support containers. 

More information can be found in the [official documentation](https://docs.windriver.com/bundle/vxworks_container_programmers_guide_23_03/page/orf1603893608622.html).

## Building the my_package.oci VxWorks Container Image

Execute the following commands to build the container image:

```bash
# This script creates the my_package container
sudo ./Docker/VxWorks7/my_package/create_my_package_container.sh <path-to-wrsdk> my_package.build amd64 llvm

# This command builds the my_package Docker image
sudo buildah bud -f Docker/VxWorks7/my_package/Dockerfile -t my_package --platform vxworks/amd64 my_package.build

# This command tags the my_package image with the registry information
sudo buildah tag my_package <registry-username>/my_package:vxworks7

# This command pushes the my_package image to the local OCI directory
sudo buildah push my_package oci:my_package.oci

# This command pushes the my_package image to the specified registry
sudo buildah push --creds <registry-username>:<password> my_package docker://<registry-username>/my_package.oci:vxworks7
```

## Pull, unpack and run my_package.oci VxWorks container image

```bash
# This command pulls the my_package image from the registry
vxc pull <registry-username>/my_package.oci:vxworks7

# This command unpacks the my_package image into a layered file system
vxc unpack --image ./my_package.oci --rootfs layered /home/my_package

# This command creates a new container from the my_package image
vxc create --bundle /home/my_package my_package

# This command starts the my_package container
vxc start my_package
```

## Kill, delete, and relaunch my_package.oci VxWorks container image

```bash
# This command kills the my_package container
vxc kill my_package

# This command deletes the my_package container
vxc delete my_package
```

Then you can relaunch the container by running:
```bash
# This command runs the my_package container
vxc run --bundle /home/my_package my_package
```

or, 
```bash
# This command creates a new container from the my_package image
vxc create --bundle /home/my_package my_package

# This command starts the my_package container
vxc start my_package
```

Please replace the placeholders `<registry-username>` and `<password>` with your actual registry username and password. Similarly, replace `<path-to-wrsdk>` with the actual path to your wrsdk directory.

For testing purposes one can simply pull [this image](https://hub.docker.com/repository/docker/mkrunic/my_package.oci) that is build for amd64 target platform and VxWorks 7 OS.
