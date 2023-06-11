FROM vxbuild:22.04

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
    curl \
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
    && rm -rf /var/lib/apt/lists/*

