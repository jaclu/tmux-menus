#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1 2021-11-11
#


get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
	echo "$default_value"
    else
	echo "$option_value"
    fi
}



#
#  C (tmux 3.2 and up)  Centered in window
#  P Lower left of current pane
#  W by the current window name in the status line
#  M by the mouse position
#
menu_location_x="$(get_tmux_option "@menus_location_x" "W")"
menu_location_y="$(get_tmux_option "@menus_location_y" "W")"
