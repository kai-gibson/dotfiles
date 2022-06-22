#!/bin/sh

vim +$(bat init.vim | rg --smart-case --line-number $(bat --number init.vim | fzf) | rg -o -e '^(\\d*)') init.vim
