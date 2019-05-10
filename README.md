# macOS-Simple-KVM
Documentation to set up a simple macOS VM in QEMU, accelerated by KVM.

## Getting Started
You'll need a Linux system with `qemu`, `python` and the KVM extensions installed for this project. A Mac is **not** required.

## Step 1
Run `jumpstart.sh` to download installation media for macOS (internet required). The default installation uses High Sierra, but you can upgrade to Mojave later.

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
