#!/bin/sh
#  shellcheck disable=SC2154
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.2 2022-03-29
#
#   Moving current pane within same session or to other session.
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
. "$CURRENT_DIR/utils.sh"

req_win_width="$1"
req_win_height="$2"
direction="$3"




log_it "move_menu() w=[$menu_width] h=[$menu_height] [$direction]"


if [ -z "$direction" ]; then
    error_msg "move_menu.sh was called without direction param" 1
fi



#  It will be created with defaultsif not present
read_cache


if [ "$direction" = "up" ]; then
    to_numerical
    cached_location_y="$(echo $cached_location_y - $cached_incr_y | bc)"
elif [ "$direction" = "down" ]; then
    to_numerical
    cached_location_y="$(echo $cached_location_y + $cached_incr_y | bc)"
elif [ "$direction" = "left" ]; then
    to_numerical
    cached_location_x="$(echo $cached_location_x - $cached_incr_x | bc)"
elif [ "$direction" = "right" ]; then
    to_numerical
    cached_location_x="$(echo $cached_location_x + $cached_incr_x | bc)"
elif [ "$direction" = "C" ]; then
    cached_location_x="C"
    cached_location_y="C"
elif [ "$direction" = "R" ]; then
    cached_location_x="R"
elif [ "$direction" = "P" ]; then
    cached_location_x="P"
    cached_location_y="P"
elif [ "$direction" = "W" ]; then
    cached_location_x="W"
    cached_location_y="W"
elif [ "$direction" = "S" ]; then
    cached_location_y="S"
elif [ "$direction" = "x-incr" ]; then
    cached_incr_x="$(echo "$cached_incr_x + 1" | bc)"
elif [ "$direction" = "x-decr" ]; then
    [ "$cached_incr_x" -gt 1 ] && cached_incr_x="$(echo "$cached_incr_x - 1" | bc)"
elif [ "$direction" = "y-incr" ]; then
    cached_incr_y="$(echo "$cached_incr_y + 1" | bc)"
elif [ "$direction" = "y-decr" ]; then
    [ "$cached_incr_y" -gt 1 ] && cached_incr_y="$(echo "$cached_incr_y - 1" | bc)"
fi

show_cache
write_cache
show_cache
