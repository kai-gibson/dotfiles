#!/bin/bash

hdmiCheck="$(cat /sys/class/drm/card0-HDMI-A-1/status | grep '^connected')"

if [ "$hdmiCheck" = 'connected' ]
then
    bash desktopSetup.sh
else
    bash desktopEnd.sh
fi
