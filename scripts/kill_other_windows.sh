#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-02-03
#
#   Kill all other windows
#

window_list="$(IFS=" " tmux list-windows -F '#{window_id}')"
current_window="$(tmux display-message -p '#{window_id}')"

for w in $window_list; do
    if [ "$w" != "$current_window" ]; then
        tmux kill-window -t "$w"
    fi
done
