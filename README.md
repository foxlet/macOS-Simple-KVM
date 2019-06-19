# macOS-Simple-KVM
Documentation to set up a simple macOS VM in QEMU, accelerated by KVM.

By [@FoxletFox](https://twitter.com/foxletfox), and the help of many others. Find this useful? [You can donate here!](https://commerce.coinbase.com/checkout/96dc5777-0abf-437d-a9b5-a78ae2c4c227)

New to macOS KVM? Check [the FAQs.](docs/FAQs.md)

## Getting Started
You'll need a Linux system with `qemu` (3.1 or later), `python3`, `pip` and the KVM extensions installed for this project. A Mac is **not** required. Some examples for different distributions:

```
sudo apt-get install qemu-system qemu-utils python3 python3-pip  # for Ubuntu, Debian, Mint, and PopOS.
sudo pacman -S qemu python python-pip            # for Arch.
sudo xbps-install -Su qemu python3 python3-pip   # for Void Linux.
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

Then run `basic.sh` to start the machine and install macOS, setting the
`SYSTEM_DISK` environment variable to the path to your freshly created
system disk image:

```
SYSTEM_DISK=MyDisk.qcow2 ./basic.sh
```

If you're running on a headless system (such as on Cloud providers), set
the `HEADLESS` environment variable to 1:

```
SYSTEM_DISK=MyDisk.qcow2 HEADLESS=1 ./basic.sh
```

Remember to partition in Disk Utility first!

## Step 2a (Virtual Machine Manager)
If instead of QEMU, you'd like to import the setup into Virt-Manager for further configuration, just run `make.sh --add`.

## Step 3

You're done!

To fine-tune the system and improve performance, look in the `docs` folder for more information on [adding memory](docs/guide-performance.md), seting up [bridged networking](docs/guide-networking.md), adding [passthrough hardware (for GPUs)](docs/guide-passthrough.md), and enabling sound features.
