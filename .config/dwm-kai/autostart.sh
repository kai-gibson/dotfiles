#!/bin/sh

dwmblocks &
sh $HOME/.fehbg &
picom &
lxsession &
udiskie &
cbatticon -u 20 -i standard -c "poweroff" -l 15 -r 5 &
nextcloud --background &
nm-applet --no-agent &
brave &
#logseq &
st &
