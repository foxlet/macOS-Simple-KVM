#!/bin/bash

# make.sh: Generate customized libvirt XML.
# by Foxlet <foxlet@furcode.co>

VMDIR=$PWD
QEMU_HOME="$HOME/.config/libvirt/qemu"
BOXES_HOME="$HOME/.local/share/gnome-boxes/images"
MACHINE="$(qemu-system-x86_64 --machine help | grep q35 | cut -d" " -f1 | grep -Eoe ".*-[0-9.]+" | sort -rV | head -1)"
OUT="template.xml"
DOMAIN_NAME=macOS-Simple-KVM
DEFAULT_STORAGE=60G
DEFAULT_MEMORY=2
MEMORY_MULTIPLIER=1048576

print_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -a, --add       Add XML to virsh (uses sudo)."
    echo
    echo " -i, --install   Install virtual machine in GNOME Boxes."
    echo
}

error() {
    local error_message="$*"
    echo "${error_message}" 1>&2;
}

generate(){
    NAME="macOS"

    read -p "How much RAM? [$DEFAULT_MEMORY]: " MEMORY
    ## Use default 2GB memory if no memory provided
    if [[ -n $MEMORY ]]; then MEMORY=$(($MEMORY_MULTIPLIER*$MEMORY)); else MEMORY=$(($MEMORY_MULTIPLIER*$DEFAULT_MEMORY)); fi

    ## TODO do some input validation

    if [[ -e version ]]; then
        NAME="$NAME $(cat version)"
    fi
    UUID=$( cat /proc/sys/kernel/random/uuid )
    sed -e "s|BOXESHOME|$BOXES_HOME|g" -e "s|MACOSNAME|$NAME|g" -e "s|BOXESHOME|$BOXES_HOME|g" -e "s|QEMUHOME|$QEMU_HOME|g" -e "s|UUID|$UUID|g" -e "s|MACHINE|$MACHINE|g" -e "s|MACHINE|$MACHINE|g" tools/template.xml.in > $OUT
    echo "$OUT has been generated in $VMDIR"
}

install(){
    echo Creating direcories $QEMU_HOME/firmware and $BOXES_HOME
    mkdir -p $BOXES_HOME
    mkdir -p $QEMU_HOME/firmware

    read -p "How much storage? [$DEFAULT_STORAGE]: " STORAGE
    ## Use default 60G storage if no storage provided
    if [[ -z $STORAGE ]]; then STORAGE=$DEFAULT_STORAGE; fi

    ## TODO do some input validation

    echo Creating system disk $BOXES_HOME/macOS.qcow2 of size $STORAGE
    qemu-img create -f qcow2 $BOXES_HOME/macOS.qcow2 $STORAGE
    echo Coping BaseSystem.img and ESP.qcow2 in $BOXES_HOME
    cp -Zfu BaseSystem.img $BOXES_HOME
    cp -Zfu ESP.qcow2 $BOXES_HOME
    echo Coping OVMF_CODE.fd in $QEMU_HOME/firmware/
    cp -Zfu firmware/OVMF_CODE.fd $QEMU_HOME/firmware/
    echo Coping OVMF_CODE.fd in $QEMU_HOME/nvram/
    cp -Zfu firmware/OVMF_VARS-1024x768.fd $QEMU_HOME/nvram/
    echo Copy $OUT to $QEMU_HOME
    cp -Zfu $OUT $QEMU_HOME/$DOMAIN_NAME.xml
    virsh -c qemu:///session define $QEMU_HOME/$DOMAIN_NAME.xml
}

if [[ ! -e BaseSystem.img ]]; then 
    echo "Can't find base image, please run ./jumpstart.sh to download it."
    echo
    exit 1
fi

generate

argument="$1"
case $argument in
    -i|--install)
        install
        ;;
    -h|--help)
        print_usage
        ;;
esac
