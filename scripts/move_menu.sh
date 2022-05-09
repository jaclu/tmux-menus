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
param="$4"



log_it "move_menu() w=[$menu_width] h=[$menu_height] [$direction]"


if [ -z "$direction" ]; then
    error_msg "move_menu.sh was called without direction param" 1
fi



#  It will be created with defaults if not present
read_cache


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
elif [ "$direction" = "x" ]; then
    cached_location_x="$param"
elif [ "$direction" = "y" ]; then
    cached_location_y="$param"
fi

write_cache
