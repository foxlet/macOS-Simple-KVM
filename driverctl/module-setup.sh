#!/bin/bash

driverctl_dir=/etc/driverctl.d/

check()
{
    return 0
}

depends()
{
    return 0
}

installkernel()
{
    for f in ${driverctl_dir}/*; do
        mods=""
        if [ -s ${f} ]; then
            mod=$(cat ${f})
            mods="${mods} ${mod}"

            # hack, but this doesn't get automatically pulled in
            [ "${mod}"="vfio-pci" ] && mods="${mods} vfio-iommu-type1"
        fi
    done
    [ -n "$mods" ] && hostonly="" instmods $mods
}

install()
{
    inst_rules 05-driverctl.rules 89-vfio-uio.rules
    inst_multiple ${driverctl_dir}/* /usr/sbin/driverctl /usr/lib/udev/vfio_name /usr/bin/logger
}
