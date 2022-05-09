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
param_1="$4"
param_2="$5"



log_it "move_menu() w=[$menu_width] h=[$menu_height] [$direction]"


if [ -z "$direction" ]; then
    error_msg "move_menu.sh was called without direction param" 1
fi



#  It will be created with defaults if not present
read_cache

#
#  If not numerical, change param to center screen
#
not_to_numerical() {
    log_it "to_numerical()"
    log_it "---->> full win width [$(tmux display -p '#{window_width}')]"
    log_it "---->> menu size: ($req_win_width,$req_win_height)"
    case $cached_location_x in
	''|*[!0-9]*)
	    log_it " fixing x"
	    cached_location_x="$(tmux display -p "(#{window_width} - $req_win_width) / 2" | bc)"
	    ;;
    esac

    case $cached_location_y in
	''|*[!0-9]*)
	    log_it "  fixing y"
	    cached_location_y="$(tmux display -p "(#{window_height} + $req_win_height) / 2" | bc)"
            ;;
    esac

    log_it "  post to_numerical()  x[$cached_location_x] y[$cached_location_y]"
}



if [ "$direction" = "C" ]; then
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
elif [ "$direction" = "coord" ]; then
    cached_location_x="$param_1"
    cached_location_y="$param_2"
fi

write_cache
