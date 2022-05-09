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

direction="$1"


#
#  If not numerical, change param to center screen
#
to_numerical() {
    log_it "to_numerical() $1"
    case $cached_location_x in
	''|*[!0-9]*)
        cached_location_x="$(tmux display -p '(#{window_width} - 52) / 2' | bc)"
	    ;;
    esac

    case $cached_location_y in
	''|*[!0-9]*)
        cached_location_y="$(tmux display -p '(#{window_height} + 15) / 2' | bc)"
        ;;
    esac
}


log_it "move_menu() [$direction]"

if [ -z "$direction" ]; then
    error_msg "move_menu.sh was called without direction param" 1
fi



#  It will be created with defaultsif not present
read_cache


if [ "$direction" = "up" ]; then
    to_numerical
    cached_location_y="$(echo $cached_location_y - $cached_inc_y | bc)"
elif [ "$direction" = "down" ]; then
    to_numerical
    cached_location_y="$(echo $cached_location_y + $cached_inc_y | bc)"
elif [ "$direction" = "left" ]; then
    to_numerical
    cached_location_x="$(echo $cached_location_x - $cached_inc_x | bc)"
elif [ "$direction" = "right" ]; then
    to_numerical
    cached_location_x="$(echo $cached_location_x + $cached_inc_x | bc)"
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
elif [ "$direction" = "x-inc" ]; then
    cached_inc_x="$(echo "$cached_inc_x + 1" | bc)"
elif [ "$direction" = "x-decr" ]; then
    cached_inc_x="$(echo "$cached_inc_x - 1" | bc)"
elif [ "$direction" = "y-inc" ]; then
    cached_inc_x="$(echo "$cached_inc_y + 1" | bc)"
elif [ "$direction" = "y-decr" ]; then
    cached_inc_x="$(echo "$cached_inc_y - 1" | bc)"
fi

write_cache
show_cache
