FROM ubuntu:18.04

RUN dpkg --add-architecture i386 && \
  apt-get update && apt-get install -y \
  g++-multilib libncurses5:i386 libc6:i386 libgcc1:i386 gcc-4.8-base:i386 \
  libstdc++5:i386 libstdc++6:i386 libxtst6 libgtk2.0-0:i386 libxtst6:i386 \
  unzip bc git wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG UID=1000
ARG GID=1000

ENV GID ${GID}
ENV GROUP wruser
ENV INSTALL_DIR /opt/windriver
ENV UID ${UID}
ENV USER wruser
ENV HOME /home/${USER}
ENV WRENV vxworks-7
ENV WORKSPACE_DIR /opt/windriver/workspace

COPY ./docker-entrypoint.sh /

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections \
&& DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

WORKDIR /work

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
