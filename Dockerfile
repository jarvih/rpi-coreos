ARG RELEASE=37

FROM registry.fedoraproject.org/fedora:${RELEASE} as UBOOT
ARG RELEASE
RUN dnf install -y /usr/bin/cpio && \
    dnf clean all
RUN dnf -y install --downloadonly --release=${RELEASE} --forcearch=aarch64 \
    --destdir=/efifiles  uboot-images-armv8 bcm283x-firmware bcm283x-overlays && \
    dnf clean all
RUN mkdir -p /efifiles/boot/efi
WORKDIR /efifiles
RUN for rpm in *rpm; do rpm2cpio $rpm | sudo cpio -idv -D .; done
RUN mv usr/share/uboot/rpi_4/u-boot.bin boot/efi/rpi4-u-boot.bin
RUN chmod 755 boot/efi/rpi4-u-boot.bin


FROM registry.fedoraproject.org/fedora:${RELEASE}
RUN dnf install -y /usr/bin/gpg /usr/sbin/kpartx /usr/bin/lsblk \
    /usr/sbin/udevadm /usr/bin/rsync /usr/bin/butane && \
    dnf clean all
COPY --from=quay.io/coreos/coreos-installer:release /usr/sbin/coreos-installer /usr/sbin
copy --from=UBOOT /efifiles/boot/efi /efifiles/boot/efi

#ENTRYPOINT ["/usr/sbin/coreos-installer"]