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
        "$TOOLS/FetchMacOS/fetch-macos.sh" -p 091-95155 -c PublicRelease13 || exit 1;
        ;;
    -m|--mojave)
        "$TOOLS/FetchMacOS/fetch-macos.sh" -l -c PublicRelease14 || exit 1;
        ;;
    -c|--catalina|*)
        "$TOOLS/FetchMacOS/fetch-macos.sh" -l -c DeveloperSeed || exit 1;
        ;;
esac

"$TOOLS/dmg2img" "$TOOLS/FetchMacOS/BaseSystem/BaseSystem.dmg" "$PWD/BaseSystem.img"
