#!/bin/sh

if [ "`tmux ls | grep 0`" ]; then
	exit 1
fi

tmux new-session -d -n "dev"
tmux neww -d -n "var"
tmux neww -d -n "etc"
tmux neww -d -n "mp3" mocp

tmux a
