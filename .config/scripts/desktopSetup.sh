#!/bin/sh

xrandr --output eDP-1 --off --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-2 --off
nitrogen --restore &

sleep 1

# run the program bluez
echo -e 'power off\npower on\nscan on\nquit' | bluetoothctl

# Clear the screen
clear
