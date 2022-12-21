#!/usr/bin/env bash

# Variables
RELEASE=37 # The target Fedora Release. Use the same one that current FCOS is based on.


# Prepare u-boot files
mkdir -p /tmp/RPi4boot/boot/efi/
sudo dnf install -y --downloadonly --release=$RELEASE --forcearch=aarch64 --destdir=/tmp/RPi4boot/  uboot-images-armv8 bcm283x-firmware bcm283x-overlays

for rpm in /tmp/RPi4boot/*rpm; do rpm2cpio $rpm | sudo cpio -idv -D /tmp/RPi4boot/; done
sudo mv /tmp/RPi4boot/usr/share/uboot/rpi_4/u-boot.bin /tmp/RPi4boot/boot/efi/rpi4-u-boot.bin

# Run CoreOS installer to disk 
FCOSDISK=/dev/sdX
sudo coreos-installer install --architecture=aarch64 -i config.ign $FCOSDISK

# Installing u-boot files 
FCOSEFIPARTITION=$(lsblk $FCOSDISK -J -oLABEL,PATH  | jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM")'.path)
mkdir /tmp/FCOSEFIpart
sudo mount $FCOSEFIPARTITION /tmp/FCOSEFIpart
sudo rsync -avh --ignore-existing /tmp/RPi4boot/boot/efi/ /tmp/FCOSEFIpart/
sudo umount $FCOSEFIPARTITION

# Clean up
rm -rf /tmp/FCOSEFIpart
rm -rf /tmp/RPi4boot/boot/efi/

