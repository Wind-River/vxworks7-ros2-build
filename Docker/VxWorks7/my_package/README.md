# Building VxWorks container image for "my_package" example

This Dockerfile will create a container image for "my_package" example that can be executed on the VxWorks 7.

This can be used in the following ways:
- as an independent deployment unit that can be shared publicly or within the team using one of the following registries:
    -   Docker Hub registry
    -   Amazon Elastic Container registry (Amazon ECR)
    -   Harbor registry

## Prerequisites 

- my_package ROS2 package has been created and cross-compiled [following instructions](../../../README.md#vxworks-ros-2-development)
- VSB and VIP have been configured to support containers

For more info, please refer to [official documentation](https://docs.windriver.com/bundle/vxworks_container_programmers_guide_23_03/page/orf1603893608622.html)

## Build the my_package.oci VxWorks container image

```bash
sudo ./Docker/VxWorks7/my_package/create_my_package_container.sh <path-to-wrsdk> my_package.build amd64 llvm
sudo buildah bud -f Docker/VxWorks7/my_package/Dockerfile -t my_package --platform vxworks/amd64 my_package.build
sudo buildah push my_package oci:my_package.oci
sudo buildah tag my_package <registrie-username>/my_package:vxworks7
sudo buildah push my_package oci:my_package.oci
sudo buildah push --creds <registrie-username>:<password> my_package docker://<registrie-username>/my_package.oci
```


## Pull, unpack and run my_package.oci VxWorks container image

```bash
vxc pull <registrie-username>/my_package.oci:vxworks7
vxc unpack --image ./my_package.oci --rootfs layered /home/my_package
vxc create --bundle /home/my_package my_package
vxc start my_package
```

## Kill, delete, and relaunch my_package.oci VxWorks container image

```bash
vxc kill my_package
vxc delete my_package
```

Then simply run:
```bash
vxc run --bundle /home/my_package my_package
```

or, 
```bash
vxc create --bundle /home/my_package my_package
vxc start my_package
```
