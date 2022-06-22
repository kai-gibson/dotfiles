#!/bin/sh

command=$1

if [ -n $command ]; then
    floaterm $command
fi
