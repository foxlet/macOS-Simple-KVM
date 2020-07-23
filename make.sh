#!/bin/bash

# make.sh: Generate customized libvirt XML.
# by Foxlet <foxlet@furcode.co>

VMDIR=$PWD
MACHINE="$(qemu-system-x86_64 --machine help | grep q35 | cut -d" " -f1 | grep -Eoe ".*-[0-9.]+" | sort -rV | head -1)"
OUT="template.xml"

print_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -a, --add   Add XML to virsh."
    echo
}

error() {
    local error_message="$*"
    echo "${error_message}" 1>&2;
}

generate(){
    UUID=$( cat /proc/sys/kernel/random/uuid )
    sed -e "s|VMDIR|$VMDIR|g" -e "s|UUID|$UUID|g" -e "s|MACHINE|$MACHINE|g" tools/template.xml.in > $OUT
    echo "$OUT has been generated in $VMDIR"
}

generate

argument="$1"
case $argument in
    -a|--add)
        virsh -c qemu:///session define $OUT
        ;;
    -h|--help)
        print_usage
        ;;
esac
