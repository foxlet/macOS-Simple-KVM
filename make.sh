#!/bin/bash

# make.sh: Generate customized libvirt XML.
# by Foxlet <foxlet@furcode.co>

VMDIR=$PWD
OUT="template.xml"

print_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -a, --add   Add XML to virsh (uses sudo)."
    echo
}

error() {
    local error_message="$@"
    echo "${error_message}" 1>&2;
}

generate(){
    sed -e "s|VMDIR|$VMDIR|g" tools/template.xml.in > $OUT
    echo "$OUT has been generated in $VMDIR"
}

generate

argument="$1"
case $argument in
    -a|--add)
        sudo virsh define $OUT
        ;;
    -h|--help)
        print_usage
        ;;
esac
