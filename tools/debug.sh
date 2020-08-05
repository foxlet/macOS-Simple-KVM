#!/usr/bin/env bash

# debug.sh: Checks common virtualization programs and modules.
# by Foxlet <foxlet@furcode.co>

echo "== Distro Info ==" >&2
lsb_release -a

echo "== Loaded Modules ==" >&2
lsmod | grep kvm
lsmod | grep amd_iommu
lsmod | grep intel_iommu

echo "== Installed Binaries ==" >&2
if [ -x "$(command -v qemu-system-x86_64)" ]; then
    qemu-system-x86_64 --version
else
    echo "qemu is not installed." >&2
fi

if [ -x "$(command -v virt-manager)" ]; then
    echo "virt-manager version $(virt-manager --version)"
else
    echo "virt-manager is not installed." >&2
fi

if [ -x "$(command -v python)" ]; then
    python --version
else
    echo "python is not installed." >&2
fi

if [ -x "$(command -v pip)" ]; then
    pip --version
else
    echo "pip is not installed." >&2
fi
