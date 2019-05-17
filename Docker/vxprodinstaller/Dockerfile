FROM ubuntu:18.04

RUN dpkg --add-architecture i386 && \
  apt-get update && apt-get install -y \
  g++-multilib libncurses5:i386 libc6:i386 libgcc1:i386 gcc-4.8-base:i386 \
  libstdc++5:i386 libstdc++6:i386 libxtst6 libgtk2.0-0:i386 libxtst6:i386 \
  unzip bc git wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GID 1000
ENV GROUP wruser
ENV INSTALL_DIR /opt/windriver
ENV INSTALLER_FILE /work/vxworks_7_r2_linux_*.zip
ENV UID 1000
ENV USER wruser
ENV HOME /home/${USER}
ENV WRENV vxworks-7
ENV HOSTS x86-linux2,x86-linux_64
ENV BASELINE=

COPY install_vxworks.sh .

COPY docker-entrypoint.sh /usr/local/bin
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections \
&& DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["./install_vxworks.sh"]
