FROM ubuntu:18.04

RUN \
  apt-get update && apt-get install -y \
  qemu-system-x86 qemu-system-arm \
  iproute2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GID 1000
ENV GROUP wruser
ENV INSTALL_DIR /opt/windriver
ENV UID 1000
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
