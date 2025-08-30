ARG BASE_IMAGE=vxbuild:22.04
FROM $BASE_IMAGE

# Environment variables
ARG ROS_DISTRO=humble
ENV ROS_DISTRO ${ROS_DISTRO}
ENV ROS2_WS /opt/ros2_ws
## Let the script create the workspace
## ENV PRJ_WS_NAME ${BSP}_${BOARD}_${PRJ}_ws

# Set timezone to UTC
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

# Install packages needed for ROS 2 builds
RUN apt-get update && apt install -q -y \
    software-properties-common \
    curl gettext \
    && add-apt-repository universe \
    && rm -rf /var/lib/apt/lists/*

# Setup Keys
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Setup sources.list
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Install bootstrap tools
RUN apt-get update && apt -y upgrade \
    && apt install --no-install-recommends -y \
    ros-${ROS_DISTRO}-ros-base \
    ros-dev-tools \
    ros-${ROS_DISTRO}-cyclonedds \
    autoconf automake libtool libltdl-dev mercurial \
    && rm -rf /var/lib/apt/lists/*

# Missing tools for the native ROS 2 build
RUN apt-get update \
    && apt install --no-install-recommends -y \
    libacl1-dev libasio-dev liblttng-ust-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/lib && cd /usr/local/lib \
    && cp -a /opt/ros/${ROS_DISTRO}/lib/x86_64-linux-gnu/libdds* . \
    && cp -a /opt/ros/${ROS_DISTRO}/lib/x86_64-linux-gnu/libcyclonedds* . \
    && cp -a /opt/ros/${ROS_DISTRO}/lib/x86_64-linux-gnu/libiceoryx_* . \
    && cp /opt/ros/${ROS_DISTRO}/bin/idlc /usr/local/bin/. \
    && ldconfig
