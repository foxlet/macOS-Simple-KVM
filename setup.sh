#!/bin/bash

sudo apt-get install qemu-system qemu-utils python python3-pip -y  # for Ubuntu, Debian, Mint, and PopOS.

qemu-img create -f qcow2 macOS.qcow2 64G

./fetch-macOS.py

(ls RecoveryImage.dmg >> /dev/null 2>&1 && mv RecoveryImage.dmg BaseSystem.dmg) || echo ""

sudo ./basic.sh
