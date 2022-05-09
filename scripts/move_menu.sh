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
param_1="$2"
param_2="$3"



log_it "move_menu() w=[$menu_width] h=[$menu_height] [$direction]"


if [ -z "$direction" ]; then
    error_msg "move_menu.sh was called without direction param" 1
fi



#  It will be created with defaults if not present
read_config


if [ "$direction" = "C" ]; then
    location_x="C"
    location_y="C"
elif [ "$direction" = "R" ]; then
    location_x="R"
elif [ "$direction" = "P" ]; then
    location_x="P"
    location_y="P"
elif [ "$direction" = "W" ]; then
    location_x="W"
    location_y="W"
elif [ "$direction" = "S" ]; then
    location_y="S"
elif [ "$direction" = "coord" ]; then
    location_x="$param_1"
    location_y="$param_2"
fi

write_config
