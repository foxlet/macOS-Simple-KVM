#!/bin/bash

# jumpstart.sh: Fetches BaseSystem and converts it to a viable format.

TOOLS=$PWD/tools

$TOOLS/FetchMacOS/fetch.sh
$TOOLS/dmg2img $TOOLS/FetchMacOS/BaseSystem/BaseSystem.dmg $PWD/BaseSystem.img
