# How to increase screen resolution for macOS-Simple-KVM

Some odd/intermediate resolutions like 1366×768 may not work well. Try to stick to more common 16:9, 16:10, and 4:3 form factors.

# Step 1

## Manual (using text editor)

_(Thanks to [passthroughpo.st](https://passthroughpo.st/new-and-improved-mac-os-tutorial-part-1-the-basics/) and [urcomputertechnics.com](http://urcomputertechnics.com/how-to-mount-efi-partition-on-macos-mojave/) for the tips.)_

1. In the macOS Finder, look for **EFI** in the left bar under **Volumes**. If it isn't visible you will have to mount it:
 - Open the macOS Terminal and type `diskutil list` and look for the disk/partition location of the EFI. (There may be more than one.)
 - Type `sudo diskutil mount diskYsZ`, using the disk/partition location name where you see EFI.
 - The **EFI** partition will appear in the left Finder bar under **Volumes**.
 - If you don't see anything in that volume after browsing to it, try the other ones that you found in `diskutil`.
2. In the **EFI** volume, go into the `Clover` directory and open the `config.plist` file in the macOS text editor.
3. There should be a section of the file that looks like this:

```````````````````
<key>ScreenResolution</key>
<string>1280x720</string>
```````````````````

4. Edit that to your preferred screen resolution.
5. Shutdown the VM

## Using Clover Configruator

1. Open Clover Configurator
2. Mount the **EFI** partition (Sidepanel -> "Mount EFI")
3. Load current clover config.plist (Sidepanel bottom, "load config" button -> navigate to `EFI/CLOVER/config.plist`)
4. Change screen resolution in GUI settings to preferred value (Sidepanel -> "Gui")
5. Save clover config.plist (Sidepanel bottom, "save config" button -> "save")
6. Shutdown the VM

# Step 2 

Depending on your environment (plain qemu/virt-manager) mind or skip the steps annotated with QEMU or VIRT. Steps with no annotation must be performed either way.
 - QEMU: Launch the VM using `basic.sh` script
 - VIRT: Remove the USB Keyboard from the VM
 - VIRT: Launch the VM
 - Press `Escape` key as soon as the window comes up/machine is starting.
 - In the interface that comes up, select `Device Manager`->`OVMF Platform Configuration`->`Change Preferred` and select the correct resolution.
 - Press `F10` to save the changes.
 - Press `Escape` multiple times to come back to main menu, and then select `Continue` on it.
 - VIRT: Readd the USB Keyboard to the VM
 - VIRT: It might be neccessary to perform a reboot to get the screen running properly
