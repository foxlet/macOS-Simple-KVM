#!/bin/bash

sudo apt-get install qemu-system qemu-utils python3 python3-pip -y  # for Ubuntu, Debian, Mint, and PopOS.

qemu-img create -f qcow2 macOS.qcow2 64G

python fetch-macOS.py

if [ -e BaseSystem.dmg ]
then
    qemu-img convert BaseSystem.dmg -O raw BaseSystem.img
else
    if [ -e RecoveryImage.dmg ]
then
    qemu-img convert RecoveryImage.dmg -O raw BaseSystem.img
else
    echo "macOS installer not found"
fi

sudo ./basic.sh
