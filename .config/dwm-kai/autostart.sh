#!/bin/sh

sh $HOME/.screenlayout/screenRes.sh &
sh $HOME/.fehbg &
nix-search --cache &
dwmblocks &
picom &
lxsession &
udiskie &
cbatticon -u 20 -i standard -c "poweroff" -l 15 -r 5 &
nextcloud --background &
#nm-applet --no-agent &
brave &
logseq &
kitty &
