Developing VxWorks with Docker
==============================

This Dockerfile will create a container image that is a development environment for VxWorks 7. 
Running the container interactively automatically invokes the development shell, sets
the VxWorks 7 environment variables, and places you in the workspace directory.

# Install Docker

```
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
```

NOTE: If you wish to run docker without sudo you must logout and back in

# Install VxWorks using the Wind River Installer

You may use any method you prefer to install VxWorks 7.  This includes the traditional way
with the Wind River Installer, an Engineering Git checkout, vxgitinstaller, vxprodinstaller,
or any other method.

# Build the vxbuild container image

If you haven't already built the vxbuild container image, change to the vxbuild directory
and follow the instructions in README.md.

# Build the vxdev container image
Change directories back to vxdev directory where this README.md is found.

```
sudo docker build -t vxdev:1.0 .
```

NOTE: If building on Windows please use --config core.autocrlf=input to
check out the Dockerfile with UNIX line endings, otherwise your Docker
container will fail to run.  Also, you may use --platform linux when
running the Docker container.

# Run the Docker image

NOTE: Some Linux distributions, like Ubuntu, use dnsmasq to cache DNS queries
locally.  This can cause problems with DNS from inside the container on corporate
network. Please add *--network host* to the docker command to workaround this problem.

Please refer to the examples below for your specific use case.  The general format for running
the vxdev container is:
```
sudo docker run -it --rm -v $INSTALL_DIR:/opt/windriver \
    -v $LM_LICENSE_FILE:/opt/windriver/license/zwrsLicense.lic \
    vxdev:1.0
```

You may optionally supply a separate workspace volume as well:
```
sudo docker run -it --rm -v $INSTALL_DIR:/opt/windriver \
    -v $LM_LICENSE_FILE:/opt/windriver/license/zwrsLicense.lic \
    -v $WORKSPACE_DIR:/opt/windriver/workspace \
    vxdev:1.0
```
