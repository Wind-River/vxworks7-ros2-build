FROM scratch

WORKDIR /lib

COPY rootfs/lib /lib

WORKDIR /usr

COPY rootfs/usr/bin /usr/bin

CMD ["/usr/bin/my_package"]

LABEL com.windriver.vxworks.rtp.rtpStackSize 0x10000000
LABEL com.windriver.vxworks.rtp.rtpPriority 50
LABEL com.windriver.vxworks.rtp.rtpOptions 0x80
LABEL com.windriver.vxworks.rtp.rtpTaskOption 0x1000000
