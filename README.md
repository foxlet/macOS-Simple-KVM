# macOS-Simple-KVM
Documentation to set up a simple macOS VM in QEMU, accelerated by KVM.

By [@FoxletFox](https://twitter.com/foxletfox), and the help of many others. Find this useful? You can donate [on Coinbase](https://commerce.coinbase.com/checkout/96dc5777-0abf-437d-a9b5-a78ae2c4c227) or [Paypal!](https://paypal.com/cgi-bin/webscr?cmd=_xclick&business=foxlet%40furcode%2eco&item_name=macOS%2dSimple%2dKVM).

New to macOS and KVM? Check [the FAQs.](docs/FAQs.md)

## Getting Started
You'll need a Linux system with `qemu` (3.1 or later), `curl`, `xmlstarlet` and the KVM modules enabled. A Mac is **not** required. Some examples for different distributions:

```
sudo apt-get install qemu-system qemu-utils curl xmlstarlet  # for Ubuntu, Debian, Mint, and PopOS.
sudo pacman -S qemu curl xmlstarlet          # for Arch.
sudo xbps-install -Su qemu curl xmlstarlet   # for Void Linux.
sudo zypper in qemu-tools qemu-kvm qemu-x86 qemu-audio-pa curl xmlstarlet  # for openSUSE Tumbleweed
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
> Note: If you're running on a headless system (such as on Cloud providers), you will need `-nographic` and `-vnc :0 -k en-us` for VNC support.

Then run `basic.sh` to start the machine and install macOS. Remember to partition in Disk Utility first!

## Step 2a (Virtual Machine Manager)
If instead of QEMU, you'd like to import the setup into Virt-Manager for further configuration, just run `sudo ./make.sh --add`.

## Step 2b (Headless Systems)
If you're using a cloud-based/headless system, you can use `headless.sh` to set up a quick VNC instance. Settings are defined through variables as seen in the following example. VNC will start on port `5900` by default.
```
HEADLESS=1 MEM=1G CPUS=2 SYSTEM_DISK=MyDisk.qcow2 ./headless.sh
```

## Step 3

You're done!

To fine-tune the system and improve performance, look in the `docs` folder for more information on [adding memory](docs/guide-performance.md), setting up [bridged networking](docs/guide-networking.md), adding [passthrough hardware (for GPUs)](docs/guide-passthrough.md), and enabling sound features.
