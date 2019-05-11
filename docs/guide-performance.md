Guide to Performance Tuning
===========================
The default macOS VM configuration (`basic.sh`) assumes some sane defaults, however this may not reflect the actual topology or peformance capabilities of the underlaying machine.

Here's some tunable parameters to get the most of out QEMU:

## Memory
The following line controls memory allocation. The default is 2GB of RAM.

Increase this as needed (limited to the real amount of memory in your machine).
```
    -m 2G \
```

## Cores
The default configuration enables 4 threads, divided into CPUs with 2 cores each.
```
    -smp 4,cores=2 \
```

The following example describes all possible topology flags:
```
    -smp cores=4,threads=4,sockets=1 \
```
