#!/usr/bin/env bash

hdmiCheck="$(cat /sys/class/drm/card0-HDMI-A-1/status | grep '^connected')"

if [ "$hdmiCheck" = 'connected' ]
then
    sh desktopSetup.sh
else
    sh desktopEnd.sh
fi
