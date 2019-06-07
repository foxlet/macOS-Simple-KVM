Guide to PCIe Passthrough
=========================

## Enable BIOS features
To use PCIe Passthrough, you will need a compatible motherboard and CPU with support for iommu. Look up your motherboard manual on how to enable these features, but they are commonly named `VT-d` or `AMD Vi`.

## Get Some Information
To pass through a card, you'll need to know some value pertaining to the card itself: The Device IDs, and BDF IDs. The following command will give a list of relevant devices to use in the next steps.

```
lspci -nn | grep "VGA\|Audio"
```

### Example
An example output might look like this:

```
26:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Curacao XT / Trinidad XT [Radeon R7 370 / R9 270X/370X] [1002:6810]
26:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Oland/Hainan/Cape Verde/Pitcairn HDMI Audio [Radeon HD 7000 Series] [1002:aab0]
```

The first value (`26:00.0`) is the BDF ID, and the last (`1002:6810`) is the Device ID. Cards with a built-in audio controller have to be passed together, so note the IDs for both subdevices.

## Load the vfio-pci module
The `vfio-pci` module is not included in the kernel on all systems, you may need for load it as part of initramfs. Look up your distro's documentation on how to do this.

## Add Kernel Flags
The `iommu` kernel module is not enabled by default, but you can enable it on boot by passing the following flags to the kernel. Replace the Device IDs with your corresponding card.

### AMD
```
iommu=pt amd_iommu=on vfio-pci.ids=1002:66af,1002:ab20
```

### Intel
```
iommu=pt intel_iommu=on vfio-pci.ids=1002:66af,1002:ab20
```

To do this permanently, you can add it to your bootloader. If you're using GRUB, for example, edit `/etc/default/grub` and add the previous lines to the `GRUB_CMDLINE_LINUX_DEFAULT` section, then run `sudo update-grub` (or `sudo grub-mkconfig` on some systems) and reboot.

## Attach card to QEMU
You will need to attach the cards using the BDF IDs for the audio and video controller. The following example shows the config for a card with two devices. The romfile parameter is optional. 

**Note:** You may need to run `basic.sh` as sudo for the card to work.

```
    -vga none \
    -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1 \
    -device vfio-pci,host=26:00.0,bus=port.1,multifunction=on,romfile=/path/to/card.rom \
    -device vfio-pci,host=26:00.1,bus=port.1 \
```
