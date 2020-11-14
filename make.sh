#!/bin/bash

# make.sh: Generate customized libvirt XML.
# by Foxlet <foxlet@furcode.co>

VMDIR=$PWD
MACHINE="$(qemu-system-x86_64 --machine help | grep q35 | cut -d" " -f1 | grep -Eoe ".*-[0-9.]+" | sort -rV | head -1)"
VMNAME="macOS-Simple-KVM"
VMUUID="d06d502a-904a-4b34-847d-debf1a3d76c7"
VMCPUS=4
VMMEM=2097152
OUT="template.xml"

print_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -a, --add        Add XML to virsh (uses sudo)."
    echo " -n, --name <str> Name of the VM (default 'macOS-Simple-KVM')"
    echo " -u, --uuid       Generates a new UUID for the VM"
    echo " -c, --cpu  <int> VM CPU count (default 4)"
    echo " -m, --mem  <int> VM memory in KiB (default 2097152)"
    echo
}

error() {
    local error_message="$*"
    echo "${error_message}" 1>&2;
}

generate(){
    sed -e "s|macOS-Simple-KVM|$VMNAME|g" -e "s|d06d502a-904a-4b34-847d-debf1a3d76c7|$VMUUID|g" -e "s|VMCPUS|$VMCPUS|g" -e "s|VMMEM|$VMMEM|g" -e "s|VMDIR|$VMDIR|g" -e "s|MACHINE|$MACHINE|g" tools/template.xml.in > $OUT
    echo "$OUT has been generated in $VMDIR"
}

while [[ $# -gt 0 ]]; do
    argument="$1"
    case $argument in
        -a|--add)
            ADD=1
            shift
            ;;
        -n|--name)
            VMNAME="$2"
            shift
            shift
            ;;
        -u|--uuid)
            VMUUID="$(uuidgen)"
            shift
            ;;
        -c|--cpu)
            VMCPUS=$2
            shift
            shift
            ;;
        -m|--mem)
            VMMEM=$2
            shift
            shift
            ;;
        -h|--help)
            print_usage
            shift
            ;;
    esac
done

generate

if [[ $ADD -eq 1 ]]; then
    sudo virsh define $OUT
fi