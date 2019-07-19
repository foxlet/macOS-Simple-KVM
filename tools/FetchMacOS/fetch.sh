#!/bin/bash

# fetch.sh: Run fetch-macos.py with safety checks
# by Foxlet <foxlet@furcode.co>

set +x;
SCRIPTDIR="$(dirname "$0")";
cd "$SCRIPTDIR"

initpip() {
    if [ -x "$(command -v easy_install)" ]; then
        sudo easy_install pip
    else
        echo "Please install python3-pip or easy_install before continuing."
        exit 1;
    fi
    pip install -r requirements.txt --user
}

getpip(){
    if [ -x "$(command -v pip3)" ]; then
        pip3 install -r requirements.txt --user
    elif [ -x "$(command -v pip)" ]; then
        pip install -r requirements.txt --user
    else
        echo "pip will be installed..." >&2
        initpip
    fi
}

getpython(){
    if [ -x "$(command -v python3)" ]; then
        PYTHONBIN=python3
    elif [ -x "$(command -v python)" ]; then
        PYTHONBIN=python
    elif [ -x "$(command -v python2)" ]; then
        PYTHONBIN=python2
    else
        echo "Please install Python 3 before continuing." >&2
        exit 1;
    fi
}

getpip
getpython
$PYTHONBIN fetch-macos.py "$@"

exit;
