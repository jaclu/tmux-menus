#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0 2021-11-08
#
#   Updates global prefix, if prefix param is given
#


prefix_char="$1"

if [ -z "$prefix_char" ]; then
    tmux display-message -d 5000 "ERROR: tmux-menus: No prefix given!"
    exit 0
fi


prefix="C-${prefix_char}"

tmux set-option -g prefix "$prefix"

tmux display-message -d 5000 "Be aware <prefix> is now: $prefix"
