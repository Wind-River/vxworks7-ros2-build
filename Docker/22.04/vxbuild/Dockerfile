FROM ubuntu:22.04

RUN dpkg --add-architecture i386 && \
  apt-get update && apt-get -y dist-upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  g++-multilib libstdc++6:i386 libgtk2.0-0:i386 libxtst6:i386 \
  gtk2-engines-murrine:i386 libcanberra-gtk-module:i386 libatk-adaptor:i386 \
  unzip bc git wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GID 1000
ENV GROUP wruser
ENV INSTALL_DIR /opt/windriver
ENV UID 1000
ENV USER wruser
ENV HOME /home/${USER}
ENV WRENV vxworks/22.09
ENV WORKSPACE_DIR /opt/windriver/workspace

COPY ./docker-entrypoint.sh /

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections \
&& DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

WORKDIR /work

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
