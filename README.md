# macOS-Simple-KVM
Documentation to set up a simple macOS VM in QEMU, accelerated by KVM.

Here's how to get started:

## Dependencies
You'll need a Linux system with `qemu`, `python` and the KVM extensions installed for this project. A Mac is **not** required.

## Step 1
Run `jumpstart.sh` to fetch installation media for macOS (internet required). The default installation uses High Sierra.

## Step 2
Create an empty hard disk using `qemu-img`
```
qemu-img create -f qcow2 MyDisk.qcow2 64G
```

and add it to the end of `basic.sh`
```
    -drive id=SystemDisk,if=none,file=MyDisk.qcow2 \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
```

Then run `basic.sh` to start the machine and install macOS.

## Step 3

You're done!

Look in the `docs` folder for more information on adding passthrough hardware (for GPU graphics), set up bridged networking, and enabling sound features.
