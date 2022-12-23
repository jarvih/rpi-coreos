#!/usr/bin/env bash

# Variables
UBOOTDIR=/efifiles
FCOSEFIDIR=/tmp/FCOSEfiPart
FCOSDISK=/dev/sdX
BUTANEFILE="/data/input.btn"
G="\033[0;32m"
R="\033[0;31m"
NOCOLOR="\033[0m"

function usage () {
    echo "convert <butane file>"
    echo "install <butane file> <disk>"
}

function convert_ignation () {
    echo -n "Converting ignation file - "
    
    if [ -s $1 ]; then
        butane -o config.ign $1 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${G}done${NOCOLOR}"
        else    
            echo -e "${R}File not valid${NOCOLOR}"
        fi
    else 
        echo -e "${R}file not found${NOCOLOR}"
        #exit 1
    fi
     

}

function install_coreos () {
    # Run CoreOS installer to disk 
    convert_ignation $1
    echo -n "Installing CoreOS - "

    if [ -f $2 ]; then
        coreos-installer install --architecture=aarch64 -i config.ign $2 #> /dev/null 2>&1
        echo -e "${G}done${NOCOLOR}"
    else
        echo -e "${R}disk not found${NOCOLOR}"
        exit 1
    fi
    # Installing u-boot files 
    echo -n "Installing u-boot files - "

    FCOSEFIPARTITION=$(lsblk $2 -J -oLABEL,PATH  | jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM")'.path)
    mkdir $FCOSEFIMOUNT
    mount $FCOSEFIPARTITION $FCOSEFIDIR
    rsync -avh --ignore-existing $UBOOTDIR/boot/efi/ $FCOSEFIDIR
    umount $FCOSEFIPARTITION

    echo -e "${G}done${NOCOLOR}"

}

if [ $# -gt 1 ]; then
    case $1 in
        convert)
        convert_ignation $2;;

        install)
        if [ $# -gt 2 ]; then
            install_coreos $2 $3
        else 
            usage
        fi;;
        *)
        usage
        exit 1;;
    esac

else
    usage
fi
