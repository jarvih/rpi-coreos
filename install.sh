#!/usr/bin/env bash

# Variables
UBOOTDIR=/efifiles
FCOSEFIDIR=/tmp/FCOSEfiPart
FCOSDISK=/dev/sdX

function usage () {
    echo "convert <inputfile>"
    echo "install <ignation file> <disk>"
}

function convert_ignation () {
  echo -n "Converting ignation file "


  echo "done"  

}

function install_coreos () {
    # Run CoreOS installer to disk 
    echo -n "installing CoreOS "
    coreos-installer install --architecture=aarch64 -i config.ign $FCOSDISK #> /dev/null 2>&1
    echo "done"


    # Installing u-boot files 
    echo -n "Installing u-boot files "

    FCOSEFIPARTITION=$(lsblk $FCOSDISK -J -oLABEL,PATH  | jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM")'.path)
    mkdir $FCOSEFIMOUNT
    mount $FCOSEFIPARTITION $FCOSEFIDIR
    rsync -avh --ignore-existing $UBOOTDIR/boot/efi/ $FCOSEFIDIR
    umount $FCOSEFIPARTITION

    echo "done"

}

