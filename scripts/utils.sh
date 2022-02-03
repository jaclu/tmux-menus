#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-02-03
#
#  Common stuff
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
#  If $log_file is empty or undefined, no logging will occur.
#
log_it() {
    if [ -z "$log_file" ]; then
        return
    fi
    printf "%s\n" "$@" >> "$log_file"
}


#
#  W - By the current window name in the status line
#  P - Lower left of current pane
#  C - Centered in window (tmux 3.2 and up)
#  M - Mouse position
#  R - Right edge of terminal (Only for x)
#  S - Next to status line (Only for y)
#  Number - In window coordinates 0,0 is top left
#
menu_location_x="$(get_tmux_option "@menus_location_x" "P")"
menu_location_y="$(get_tmux_option "@menus_location_y" "P")"
