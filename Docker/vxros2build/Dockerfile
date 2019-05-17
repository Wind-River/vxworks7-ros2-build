FROM vxbuild:1.0

# Environment variables
ENV ROS_DISTRO crystal
ENV ROS2_WS /opt/ros2_ws
## Let the script create the workspace
## ENV PRJ_WS_NAME ${BSP}_${BOARD}_${PRJ}_ws

# Set timezone to UTC
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

# Install packages needed for ROS2 builds
## From docker_images/ros2/source/source/Dockerfile
## Added curl for vxworks-ros-scripts

RUN apt-get update && apt-get install -q -y \
    bash-completion \
    dirmngr \
    gnupg2 \
    lsb-release \
    python3-pip \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Setup Keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# Setup sources.list
RUN echo "deb http://packages.ros.org/ros2/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros2-latest.list

# Setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*
## What do we need python3-rosdep for?

## Add development headers for GUI tools (0006-prj-create.sh)
RUN apt-get update && apt-get install --no-install-recommends -y \
    libxaw7-dev \
    libxaw3dxft8-dev \
    libxrandr-dev \
    python3-sip-dev \
    python3-pyqt5 \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
## List comes from ROS2 docker_images Dockerfile
## Added empy for rcutils
##
## Some modules may complain that they already exist because
## they came as packages in the Ubuntu base image. In which case
## newer versions will be installed in /usr/local/lib/python3*
## and take precendence. We shall leave the list intact so that
## we have them explicitly listed should we change the base image.
RUN pip3 install -U --no-cache-dir \
    argcomplete \
    flake8 \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-docstrings \
    flake8-import-order \
    flake8-quotes \
    pytest-repeat \
    pytest-rerunfailures \
    empy

# Additional developer tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    autoconf \
    automake \
    cmake \
    libtool \
    libltdl-dev \
    mercurial \
    && rm -rf /var/lib/apt/lists/*

# For native ROS2 builds
RUN apt-get update && apt-get install --no-install-recommends -y \
    libasio-dev \
    libtinyxml2-dev \
    libeigen3-dev \
    libopencv-dev \
    && rm -rf /var/lib/apt/lists/*

# Add development headers for rviz
RUN apt-get update && apt-get install --no-install-recommends -y \
    libassimp-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libgles2-mesa-dev \
    libglu1-mesa \
    libogre-1.9-dev \
    libqt5core5a \
    libqt5gui5 \
    libqt5opengl5 \
    libqt5widgets5 \
    qtbase5-dev \
    && rm -rf /var/lib/apt/lists/*

# Add development headers for rqt
RUN apt-get update && apt-get install --no-install-recommends -y \
    pyqt5-dev \
    python3-pyqt5 \
    python3-pyqt5.qtsvg \
    python3-sip-dev \
    python3-pydot \
    python3-pygraphviz \
    && rm -rf /var/lib/apt/lists/*
