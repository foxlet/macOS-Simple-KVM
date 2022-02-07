#!/bin/bash
sudo apt update && sudo apt -y upgrade
sudo apt -y install build-essential libncurses-dev bison flex libssl-dev libelf-dev cpu-checker qemu-kvm aria2
sudo apt-get install qemu-system qemu-utils python3 python3-pip -y
cd ~
aria2c -x 10 https://github.com/microsoft/WSL2-Linux-Kernel/archive/4.19.104-microsoft-standard.tar.gz
tar -xf WSL2-Linux-Kernel-4.19.104-microsoft-standard.tar.gz
cd WSL2-Linux-Kernel-4.19.104-microsoft-standard/
cp Microsoft/config-wsl .config
make menuconfig
cd ~
nano .bashrc
