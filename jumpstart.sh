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


version[0]="10.15"
version[1]="Catalina"
argument="$1"
if [ ! -z "$argument" ]
then
    case $argument in
        -h|--help)
            print_usage
            ;;
        -s|--high-sierra)
            version[0]="10.13"
            version[1]="High Sierra"
            ;;
        -m|--mojave)
            version[0]="10.14"
            version[1]="Mojave"
            ;;
        -c|--catalina)
            version[0]="10.15"
            version[1]="Catalina"
            ;;
        *) echo "Invalid argument, $argument."
           print_usage
           exit 1
           ;;
    esac
fi

echo "Fetching Mac OS ${version[1]}"
"$TOOLS/FetchMacOS/fetch.sh" -v "${version[0]}" || exit 1;
"$TOOLS/dmg2img" "$TOOLS/FetchMacOS/BaseSystem/BaseSystem.dmg" "$PWD/BaseSystem.img"
