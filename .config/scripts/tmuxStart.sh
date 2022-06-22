#!/bin/sh

if [ "`tmux ls | grep 0`" ]; then
	exit 1
fi

tmux new-session -d -n "fish"
tmux neww -d -n "lf" lf 
tmux neww -d -n "etc"
tmux neww -d -n "var"
tmux a
