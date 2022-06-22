#!/bin/bash

command=$(fd -H . /home | fzf)

if [[ -n $command ]]; then
    floaterm $command
fi
