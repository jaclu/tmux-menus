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

if [ -z "$direction" ]; then
    error_msg "move_menu.sh was called without direction param" 1
fi

log_it "move_menu() [$direction]"

to_numerical() {
    log_it "to_numerical() $1"
    case $cached_location_x in
	''|*[!0-9]*)
	    c="$(tmux display -p '(#{window_width} - 52) / 2')"
	    cached_location_x="$(echo $c | bc)"
	    log_it "Converted x from C into [$cached_location_x]"
	    ;;
    esac

    case $cached_location_y in
	''|*[!0-9]*)
	    c="$(tmux display -p '(#{window_height} + 15) / 2')"
	    cached_location_y="$(echo $c | bc)"
	    log_it "Converted x from C into [$cached_location_x]"
	    ;;
    esac
}


#  It will be created with defaultsif not present
read_cache


if [ "$direction" = "up" ]; then
    to_numerical
    cached_location_y="$(echo $cached_location_y - 1 | bc)"
elif [ "$direction" = "down" ]; then
    to_numerical
    cached_location_y="$(echo $cached_location_y + 1 | bc)"
elif [ "$direction" = "left" ]; then
    to_numerical
    cached_location_x="$(echo $cached_location_x - 1 | bc)"
elif [ "$direction" = "right" ]; then
    to_numerical
    cached_location_x="$(echo $cached_location_x + 1 | bc)"
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
fi

write_cache
show_cache
