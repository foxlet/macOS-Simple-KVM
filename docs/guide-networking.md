Guide to Bridged Networking
===========================

*Note*: you don't need to set up bridged networking just to get internet access. With `basic.sh` you should be able to access the internet from MacOS automatically. *However*, the ICMP protocol (used for `ping`) is not supported with the default networking solution. 

To set up bridged networking for the macOS VM, use one of the following methods:


## Using /etc/network/interfaces

It is possible to create the bridge and tun/tap interfaces by adding the following lines to `/etc/network/interfaces`. Replace `DEVICENAME` with your ethernet card's device name, and `MYUSERNAME` with the user that is starting the VM.

```
auto br0
iface br0 inet dhcp
  bridge_ports DEVICENAME tap0

auto tap0
iface tap0 inet dhcp
  pre-up tunctl -u MYUSERNAME -t tap0
```

## Using NetworkManager
You can use NetworkManager to control the bridge and tun/tap interfaces, by creating them with the following commands. Replace `DEVICENAME` with your ethernet card's device name.

### Make the Bridge
```
nmcli connection add type bridge \
    ifname br1 con-name mybridge
```

### Attach Bridge to Ethernet
```
nmcli connection add type bridge-slave \
    ifname DEVICENAME con-name mynetwork master br1
```

### Make the Tun/Tap
```
nmcli connection add type tun \
    ifname tap0 con-name mytap \
    mode tap owner `id -u`
```

### Attach Tun/Tap to Bridge
```
nmcli connection mod mytap connection.slave-type bridge \
    connection.master br1
```

## Attach Bridge to QEMU
Once you have set up the bridge and tun/tap on the host, you'll have to add the following line to `basic.sh`, replacing `-netdev user,id=net0`. Change `tap0` to your corresponding device name.

```
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
```
You can optionally use the `vmxnet3` driver for higher performance compared to the default e1000. Note that replacing it requires macOS El Capitan or higher.
```
    -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
```

## Using Netctl
You can also use netctl and the qemu bridge helper to control the bridge and tun/tap interfaces. Replace `DEVICENAME` with your ethernet card's device name.

### Create netctl configuration file in /etc/netctl (f.e. /etc/netctl/kvm-bridge)
```
Description="Bridge Interface br10 : DEVICENAME"
Interface=br10
Connection=bridge
BindsToInterfaces=(DEVICENAME)
IP=dhcp
# If you want also for DHCPv6,uncomment below line
#IP6=dhcp
```

### Activate netctl bridge handler with system boot
```
sudo netctl enable kvm-bridge
```

### Create bridge whitelist file for qemu (/etc/qemu/bridge.conf)
```
allow br10
```

## Attach Bridge to QEMU
Now you'll have to add the following line to `basic.sh`, replacing `-netdev user,id=net0`. Change `br10` to your corresponding device name.

```
    -netdev bridge,br=br10,id=net0 \
```
