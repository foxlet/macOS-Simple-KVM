#!/bin/bash

# createdisk.sh: Creates an empty hard disk using qemu-img
# by Foxlet <foxlet@furcode.co>

# Default values
FORMAT="qcow2"
SIZE="64G"
VMDIR="$PWD"
BNAME="MyDisk"

print_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -h                 Show this message"
    echo
    echo " -f [format]        Disk image format     (default is 'qcow2')."
    echo " -s [size]          Disk image size       (default is '64G')."
    echo " -d [directory]     Disk image path       (default is '\$PWD')."
    echo " -b [basename]      Disk image basename   (default is 'MyDisk')."
    echo
}

error() {
    local error_message="$*"
    echo -e "${error_message}" 1>&2;
}

while getopts f:s:d:b:h flag
do
    case "${flag}" in
        h) print_usage; exit 1;;
        f) FORMAT="${OPTARG}";;
        s) SIZE="${OPTARG}";;
        d) VMDIR="${OPTARG}";;
        b) BNAME="${OPTARG}";;
    esac
done

BNAME="$(basename --suffix=".${FORMAT}" "$BNAME")"	# Remove redundant suffix if given
VMPATH="${VMDIR}/${BNAME}.${FORMAT}"	# Concat Path


# Verify qemu-img is installed
command -v qemu-img &>/dev/null
if [ $? -ne 0 ]; then
    error "This script requires the qemu-img command, but could not find it."
    error "Please see the README.md for details on installing this package."
    exit 2
fi

# Verify space is sufficient
FREE_M="$(df -Pm "$VMDIR" | tail -1 | awk '{print $4}')"	# Get free space of VMDIR in MB
SIZE_M="$(( $(echo "${SIZE^^}" | sed 's/K/ \/ 1024/g;s/M//g;s/G/ * 1024/g;s/T/ * 1048576/g') ))" #Convert K/M/G/T to MB

if [ $SIZE_M -gt $FREE_M ]; then
    error "Not enough space to create a ${SIZE} disk image in ${VMDIR}, (only $((FREE_M / 1024)) GB free)."
    error "Adjust the size with the -s flag, or the output directory with the -d flag."
    exit 3
fi

# Verify image doesn't already exist
if [[ -e "$VMPATH" ]]; then
    read -n1 -p "The file $VMPATH already exists, do you want delete the existing image? [y/N]: " yn
    if [[ "${yn,,}" == "y" ]]; then
        rm -iv "$VMPATH"
    else
        error "Okay. Aborting."
        exit 4
    fi
fi

# Confirm
echo "This will create a $SIZE sized $FORMAT type virtual disk at $VMPATH ..."
read -n 1 -p "Create image now? [Y/n]: " yn; echo
if [[ "${yn,,}" == "n" ]]; then
    error "Aborting disk image creation."
    exit 5
fi

# Create image
qemu-img create -f "$FORMAT" "$VMPATH" "$SIZE"

if [ $? -ne 0 ]; then
    error "Problem creating disk image. Aborting."
    exit 6
fi

# Write lines to basic.sh
OLD_CONF="$(grep -E '^\s*\-d.*=SystemDisk.*$' "$(dirname "$0")/basic.sh")"     # Make sure we're not adding redundant lines
NEW_CONF="$(printf '    -drive id=SystemDisk,if=none,file="$VMDIR/%s.%s" \\\n    -device ide-hd,bus=sata.4,drive=SystemDisk' "$BNAME" "$FORMAT") "

echo -e "\nYou must add these lines to basic.sh to use this disk:\n"
echo -e "${NEW_CONF}\n"
read -n 1 -p "Do you want to add these line automatically? [Y/n]: " yn; echo
if [[ "${yn,,}" == "n" ]]; then
    error "Okay."
    exit 0
elif [[ -n "${OLD_CONF}" ]]; then
    echo -e "\nYour basic.sh script already contains the following SystemDisk config:\n"
    echo -e "${OLD_CONF}\n"
    echo -e "This will be replaced with these lines:\n"
    echo -e "${NEW_CONF}\n"

    read -n 1 -p "Do you want do this replacement? [Y/n]: " yn; echo
    if [[ "${yn,,}" == "n" ]]; then
        error "Okay."
        exit 0
     else
        touch /tmp/basic.sh
        grep -Ev '^\s*\-d.*=SystemDisk.*$' "$(dirname "$0")/basic.sh" > /tmp/basic.sh;
        echo -e "${NEW_CONF}" >> /tmp/basic.sh
		cat /tmp/basic.sh > "$(dirname "$0")/basic.sh"
        rm /tmp/basic.sh
        error "SystemDisk configuration in basic.sh was updated."
        exit 0
     fi
else
    echo -e "${NEW_CONF}" >> "$(dirname "$0")/basic.sh"
    error "SystemDisk configuration added to basic.sh."
fi
