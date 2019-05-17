FROM vxbuild:1.0

RUN groupadd --gid ${GID} ${GROUP}
RUN useradd --create-home --shell /bin/bash --uid ${UID} --gid ${GID} --home-dir ${HOME} ${USER}
USER ${USER}

WORKDIR ${WORKSPACE_DIR}

ENTRYPOINT ["/opt/windriver/wrenv.sh", "-p", "vxworks-7"]
