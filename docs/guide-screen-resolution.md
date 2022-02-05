## How to increase screen resolution for macOS-Simple-KVM

1. In the macOS Finder, look for **EFI** in the left bar under **Volumes**. If it isn't visible you will have to mount it:
 - Open the macOS Terminal and type `diskutil list` and look for the disk/partition location of the EFI. (There may be more than one.)
 - Type `sudo diskutil mount diskYsZ`, using the disk/partition location name where you see EFI.
 - The **EFI** partition will appear in the left Finder bar under **Volumes**.
 - If you don't see anything in that volume after browsing to it, try the other ones that you found in `diskutil`.
2. In the **EFI** volume, go into the `OC` directory and open the `config.plist` file in the macOS text editor.
3. There should be a section of the file that looks like this:

```````````````````
<key>Resolution</key>
<string>1280x720@32</string>
```````````````````

 - Edit that to your preferred screen resolution, but leave the @32 part as it is.
 - Some odd/intermediate resolutions like 1366×768 may not work well. Try to stick to more common 16:9, 16:10, and 4:3 form factors.

2. Shut down the VM, relaunch it using `basic.sh` script and follow the following steps:
 - Press `Escape` key as soon as the window comes up.
 - If you are using virt-manager, you may need to detach the USB keyboard to get to this screen. One you are done editing, re-add the USB keyboard and reboot
 - In the interface that comes up, select `Device Manager`->`OVMF Platform Configuration`->`Change Preferred` and select the correct resolution.
 - Press `F10` to save the changes.
 - Press `Escape` multiple times to come back to main menu, and then select `Continue` on it.
