#!/usr/bin/env bash

hdmiCheck="$(cat /sys/class/drm/card0-HDMI-A-1/status | grep '^connected')"

if [ "$hdmiCheck" = 'connected' ]
then
    sh $HOME/.config/scripts/desktopSetup.sh
else
    sh $HOME/.config/scripts/desktopEnd.sh
fi
