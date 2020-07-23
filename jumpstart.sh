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
    echo " -b, --big-sur       Fetch Big Sur media."
    echo
}

error() {
    local error_message="$*"
    echo "${error_message}" 1>&2;
}

argument="$1"
case $argument in
    -h|--help)
        print_usage
        ;;
    -s|--high-sierra)
        "$TOOLS/FetchMacOS/fetch.sh" -v 10.13 -k BaseSystem || exit 1;
        ;;
    -m|--mojave)
        "$TOOLS/FetchMacOS/fetch.sh" -v 10.14 -k BaseSystem || exit 1;
        ;;
    -b|--big-sur)
        "$TOOLS/FetchMacOS/fetch.sh" -v 10.16 -c DeveloperSeed -p 001-18401-003 || exit 1;
        ;;
    -c|--catalina|*)
        "$TOOLS/FetchMacOS/fetch.sh" -v 10.15 -k BaseSystem || exit 1;
        ;;
esac

"$TOOLS/dmg2img" "$TOOLS/FetchMacOS/BaseSystem/BaseSystem.dmg" "$PWD/BaseSystem.img"
