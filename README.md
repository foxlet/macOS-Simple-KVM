# macOS-Simple-KVM
Documentation to set up a simple macOS VM in QEMU, accelerated by KVM.

By [@FoxletFox](https://twitter.com/foxletfox), and the help of many others.

## Getting Started
You'll need a Linux system with `qemu`, `python3`, `pip` and the KVM extensions installed for this project. A Mac is **not** required. Some examples for different distributions:

```
    sudo apt-get install qemu python3 python3-pip  # for Ubuntu, Debian, Mint, and PopOS.
    sudo pacman -S qemu python python-pip          # for Arch.
    sudo xbps-install -Su qemu python3 python3-pip # for Void Linux.
```

## Step 1
Run `jumpstart.sh` to download installation media for macOS (internet required). The default installation uses Catalina, but you can choose which version to get by adding either `--high-sierra`, `--mojave`, or `--catalina`. For example:
```
./jumpstart.sh --mojave
```
> Note: You can skip this if you already have `BaseSystem.img` downloaded. If you have `BaseSystem.dmg`, you will need to convert it with the `dmg2img` tool.

## Step 2
Create an empty hard disk using `qemu-img`, changing the name and size to preference:
```
qemu-img create -f qcow2 MyDisk.qcow2 64G
```

and add it to the end of `basic.sh`:
```
    -drive id=SystemDisk,if=none,file=MyDisk.qcow2 \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
```

Then run `basic.sh` to start the machine and install macOS.

## Step 2a (Virtual Machine Manager)
If instead of QEMU, you'd like to import the setup into Virt-Manager for further configuration, just run `make.sh --add`.

## Step 3

You're done!

Look in the `docs` folder for more information on adding passthrough hardware (for GPU graphics), set up bridged networking, and enabling sound features.
