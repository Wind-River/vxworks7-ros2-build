Building VxWorks with Docker
==============================

This Dockerfile will create a container image that is a build environment for VxWorks 7. Using it makes it easy to use VxWorks.

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

# Install VxWorks using the Wind River Installer

You may use any method you prefer to install VxWorks 7.  This includes the traditional way
with the Wind River Installer, an Engineering Git checkout, vxgitinstaller, vxprodinstaller,
or any other method.


# Build the vxbuild container image

Change directories to vxbuild directory where this README.md is found.

```
sudo docker build -t vxbuild:22.04 .
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
the vxbuild container is:
```
sudo docker run --rm -v $INSTALL_DIR:/opt/windriver \
    -v $LM_LICENSE_FILE:/opt/windriver/license/zwrsLicense.lic \
    -v $WORK_DIR:/work vxbuild:22.04 /work/myscript.sh
```

If you add the -it option to the docker run command, then vxbuild will automatically start an
interactive bash shell.  This is ideal for development or debugging problems that occur.
```
sudo docker run -it --rm -v $INSTALL_DIR:/opt/windriver \
    -v $LM_LICENSE_FILE:/opt/windriver/license/zwrsLicense.lic \
    -v $WORK_DIR:/work vxbuild:22.04
```

## Use Case A: Using a Docker volume

This use cases assumes you have a VxWorks 7 installation located on a a Docker volume.

For a volume named vxinstall with a script named vxexample.sh, use the following command:
```
sudo docker run --rm -v vxinstall:/opt/windriver \
    -v $PWD/encryptedLicense_201932382441440206_s.lic:/opt/windriver/license/zwrsLicense.lic \
    -v $PWD:/work vxbuild:22.04 /work/vxexample.sh
```

If you want to run the script again, you will need to remove the projects in the workspace
directory.  You may use the interactive mode to do this:

```
sudo docker run -it --rm -v vxinstall:/opt/windriver \
    -v $PWD/encryptedLicense_201932382441440206_s.lic:/opt/windriver/license/zwrsLicense.lic \
    -v $PWD:/work vxbuild:22.04
```

Then at the bash prompt you may simply delete the workspace directory to start over.

```
wruser@116970fb75cf:/$ rm -rf /opt/windriver/workspace
```

## Use Case B: Using your host installation

Bind mount /opt/windriver into the Docker container

```
sudo docker run --rm -v /opt/windriver:/opt/windriver \
    -v $PWD/encryptedLicense_201932382441440206_s.lic:/opt/windriver/license/zwrsLicense.lic \
    -v $PWD:/work vxbuild:22.04 /work/vxexample.sh
```

You may set environment variables to use a custom user id or installation directory that matches
your host environment:

```
sudo docker run --rm -v $HOME/windriver:$HOME/windriver \
    -v $PWD/encryptedLicense_201932382441440206_s.lic:$HOME/windriver/license/zwrsLicense.lic \
    -e UID=$(id -u $MYUSER) \
    -e GID=$(id -g $MYGROUP) \
    -e INSTALL_DIR=$HOME/windriver \
    -v $PWD:/work vxbuild:22.04 /work/vxexample.sh
```

## Use Case C: Skip Docker entirely

The vxexample.sh script runs both inside and outside the Docker container image.
This makes it easy to accomodate different workflows and eliminates any dependency on
Docker.

If you want to change the default installation directory you may change it using
environment variables.

```
INSTALL_DIR=/opt/windriver/vxworks-7-20190319 WORKSPACE=$HOME/workspace ./vxexample.sh
```
