# macOS-Simple-KVM
Documentation to set up a simple macOS VM in QEMU, accelerated by KVM.

By [@FoxletFox](https://twitter.com/foxletfox), and the help of many others. Find this useful? You can donate [on Coinbase](https://commerce.coinbase.com/checkout/96dc5777-0abf-437d-a9b5-a78ae2c4c227) or [Paypal!](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=QFXXKKAB2B9MA&item_name=macOS-Simple-KVM).

New to macOS and KVM? Check [the FAQs.](docs/FAQs.md)

## OneClick Method
Run these commands
```
chmod u+x setip.sh
chmod +x fetch-macOS-v2.py
```
Then run `sudo ./setup.sh` to make the VM. Monterey may not work.
Once the VM boots up, just hit enter even if you don't see anything (do this every boot) Then format the biggest drive as macOS Extended Journaled, Then go to reinstall macOS and install it to the newly formatted hard drive.

Once installed, run run ./basic.sh to boot up the VM again. Do not run ./setup.sh twice if the install was succesful, as it will redownload the image and that is not needed.

## You're done!

To fine-tune the system and improve performance, look in the `docs` folder for more information on [adding memory](docs/guide-performance.md), setting up [bridged networking](docs/guide-networking.md), adding [passthrough hardware (for GPUs)](docs/guide-passthrough.md), tweaking [screen resolution](docs/guide-screen-resolution.md), and enabling sound features.

## Manual method (for other distros that aren't debian based)

## Getting Started
You'll need a Linux system with `qemu` (3.1 or later), `python3`, `pip` and the KVM modules enabled. A Mac is **not** required. Some examples for different distributions:

```
sudo apt-get install qemu-system qemu-utils python3 python3-pip  # for Ubuntu, Debian, Mint, and PopOS.
sudo pacman -S qemu python python-pip python-wheel  # for Arch.
sudo xbps-install -Su qemu python3 python3-pip   # for Void Linux.
sudo zypper in qemu-tools qemu-kvm qemu-x86 qemu-audio-pa python3-pip  # for openSUSE Tumbleweed
sudo dnf install qemu qemu-img python3 python3-pip # for Fedora
sudo emerge -a qemu python:3.4 pip # for Gentoo
```

## Step 1
Run `fetch-macOS-v2.py` to download installation media for macOS (internet required).
```
./fetch-macOS-v2.py
```
Then run 
```
qemu-img convert BaseSystem.dmg -O raw BaseSystem.img
```

## Step 2
Create an empty hard disk using `qemu-img`, changing the name and size to preference:
```
qemu-img create -f qcow2 macOS.qcow2 64G
```

if you change the drive name, change the line below according to the new name in `basic.sh`:
```
    -drive id=SystemDisk,if=none,file=macOS.qcow2 \
```
> Note: If you're running on a headless system (such as on Cloud providers), you will need `-nographic` and `-vnc :0 -k en-us` for VNC support.

Then run `basic.sh` to start the machine and install macOS. Remember to partition in Disk Utility first! (macOS extended journaled)

## Step 2a (Virtual Machine Manager)
1. If instead of QEMU, you'd like to import the setup into Virt-Manager for further configuration, just run `sudo ./make.sh --add`.
2. After running the above command, add `macOS.qcow2` as storage in the properties of the newly added entry for VM.

## Step 2b (Headless Systems)
If you're using a cloud-based/headless system, you can use `headless.sh` to set up a quick VNC instance. Settings are defined through variables as seen in the following example. VNC will start on port `5900` by default.
```
HEADLESS=1 MEM=1G CPUS=2 SYSTEM_DISK=MyDisk.qcow2 ./headless.sh
```

## Step 3

You're done!

To fine-tune the system and improve performance, look in the `docs` folder for more information on [adding memory](docs/guide-performance.md), setting up [bridged networking](docs/guide-networking.md), adding [passthrough hardware (for GPUs)](docs/guide-passthrough.md), tweaking [screen resolution](docs/guide-screen-resolution.md), and enabling sound features.
