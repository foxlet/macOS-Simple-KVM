#!/usr/bin/env bash

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
        version=10.13
        ;;
    -m|--mojave)
        version=10.14
        ;;
    -c|--catalina|*)
        version=10.15
        ;;
esac

"$TOOLS/FetchMacOS/fetch.sh" -v $version || exit 1

if [ -x "$(command -v dmg2img)" ]; then
    dmg2img="dmg2img"
else
    dmg2img="$TOOLS/dmg2img"
fi

"$dmg2img" "$TOOLS/FetchMacOS/BaseSystem/BaseSystem.dmg" "$PWD/BaseSystem.img"
