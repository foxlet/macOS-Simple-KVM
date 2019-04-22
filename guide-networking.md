Guide to Bridged Networking
===========================
To set up bridged networking for the macOS VM, use one of the following methods:


## Using /etc/network/interfaces

It is possible to create the bridge and tun/tap interfaces using adding the following lines to `/etc/network/interfaces`. Replace `DEVICENAME` with your ethernet card's device name, and `MYUSERNAME` with the user that is starting the VM.

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
