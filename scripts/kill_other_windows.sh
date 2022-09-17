#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.2 2022-09-17
#
#   Kill all other windows
#
# Global check exclude, ignoring: is referenced but not assigned
# shellcheck disable=SC2154



window_list="$(IFS=" " $TMUX_BIN list-windows -F '#{window_id}')"
current_window="$($TMUX_BIN display-message -p '#{window_id}')"

for w in $window_list; do
    if [ "$w" != "$current_window" ]; then
        $TMUX_BIN kill-window -t "$w"
    fi
done
