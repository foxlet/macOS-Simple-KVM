#!/bin/bash

# jumpstart.sh: Fetches BaseSystem and converts it to a viable format.
# by Foxlet <foxlet@furcode.co>

TOOLS=$PWD/tools

print_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -s, --high-sierra   Fetch High Sierra media."
    echo " -m, --mojave        Fetch Mojave media."
    echo " -c, --catalina      Fetch Catalina media."
    echo " -a, --all           Fetch ALL media."
    echo
}

error() {
    local error_message="$@"
    echo "${error_message}" 1>&2;
}

argument="$1"
case $argument in
    -s|--high-sierra)
        $TOOLS/FetchMacOS/fetch.sh -p 091-95155 -c PublicRelease13 || exit 1;
        ;;
    -m|--mojave)
        $TOOLS/FetchMacOS/fetch.sh -l -c PublicRelease14 || exit 1;
        ;;
    -c|--catalina|*)
        $TOOLS/FetchMacOS/fetch.sh -l -c DeveloperSeed || exit 1;
        ;;
    -a|--all)
        $TOOLS/FetchMacOS/fetch.sh -a -k BaseSystem || exit 1;
        for p in $(ls -1 $TOOLS/FetchMacOS/SoftwareUpdate/) do
            dmg2img $TOOLS/FetchMacOS/SoftwareUpdate/$p/BaseSystem.dmg $TOOLS/FetchMacOS/SoftwareUpdate/$p/BaseSystem.img;
        done;
        echo "NOTE: Because you chose to download ALL media instead of a specific version, you can find each image in ./tools/FetchMacOS/SoftwareUpdate/\$VERSION/BaseSystem.img instead of the default location."
        ;;

    -h|--help)
        print_usage
        ;;
esac

$TOOLS/dmg2img $TOOLS/FetchMacOS/BaseSystem/BaseSystem.dmg $PWD/BaseSystem.img
