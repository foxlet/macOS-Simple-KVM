## Requirements and Clone script

`wget https://raw.githubusercontent.com/downthecrop/macOS-Simple-KVM/master/install.sh -v -O install.sh; chmod +x install.sh; ./install.sh`

## Check to see if processor virtualization is enabled

`dmesg | grep -E "DMAR|IOMMU"`

if no output then enable virtulization in BIOS

## GET ID USBs

`lspci -nn | grep -i USB`

## Record the first number for QEMU, the second for GRUB.

`00:14.0 USB controller [0c03]: Intel Corporation Cannon Lake PCH USB 3.1 xHCI Host Controller [8086:a36d] (rev 10)`

## Add the second number to grub. [8086:a36d]

`sudo gedit /etc/default/grub`

Intel

`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash iommu=pt intel_iommu=on vfio-pci.ids=XXXX:XXXX"`

AMD

`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash iommu=pt amd_iommu=on vfio-pci.ids=XXXX:XXXX"`

## Update GRUB

`sudo update-grub`

## Reboot

`sudo reboot`

## Check if vfio is enabled

`dmesg | grep -i vfio`

## Change Configuration Files

Uncomment bottom lines from `macOS.sh` using the first number from the `lspci -nn | grep -i USB` device you passed through

edit `USBmacOS.sh` using the first number from the `lspci -nn | grep -i USB` device you passed through

## Make sure you have macOS.qcow2 in the folder.

Download macOS.7z Virtual Disk Image: https://drive.google.com/open?id=1EnbopO0On4vZN7X_8zPr-k4EjCTuoQLM

Alt Link: https://archive.org/details/macOS.7z

## Execute the Virtual Machine and Pass through PCI USB Controller

`sudo ./USBmacOS.sh`


## If you'd rather download the offical BaseSystem.dmg of macOS you can follow the original [macOS-Simple-KVM](https://github.com/foxlet/macOS-Simple-KVM/blob/master/README.md) instructions for downloading and setup.
