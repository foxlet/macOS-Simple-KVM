#!/bin/bash


OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VMDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
OVMF=$VMDIR/firmware
#export QEMU_AUDIO_DRV=pa
#QEMU_AUDIO_DRV=pa

qemu-system-x86_64 \
    -enable-kvm \
    -m 2G \
    -machine q35,accel=kvm \
    -smp 4,cores=2 \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \
    -vga qxl \
    -device ich9-intel-hda -device hda-output \
    -usb -device usb-kbd -device usb-tablet \
    -netdev user,id=net0 \
    -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
    -device ich9-ahci,id=sata \
    -drive id=ESP,if=none,format=qcow2,file="$VMDIR/ESP.qcow2" \
    -device ide-hd,bus=sata.2,drive=ESP \
    -drive id=InstallMedia,format=raw,if=none,file="$VMDIR/BaseSystem.img" \
    -device ide-hd,bus=sata.3,drive=InstallMedia \
    -drive id=SystemDisk,if=none,file="$VMDIR/macOS.qcow2" \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
