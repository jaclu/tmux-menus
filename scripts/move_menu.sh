#!/bin/sh
#  shellcheck disable=SC2154
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Moving current pane within same session or to other session.
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

_this="move_menu.sh"
if [ "$(basename "$0")" != "$_this" ]; then
    echo "ERROR: $_this should NOT be sourced"
    exit 1
fi

D_TM_SCRIPTS="$(cd -- "$(dirname -- "$0")" && pwd)"

# shellcheck disable=SC1091
. "$D_TM_SCRIPTS/utils.sh"

# safety check to ensure it is defined
[ -z "$TMUX_BIN" ] && echo "ERROR: move_menu.sh - TMUX_BIN is not defined!"

action="$1"
param_1="$2"
param_2="$3"

if [ -z "$action" ]; then
    error_msg "move_menu.sh was called without action param" 1
fi

#  It will be created with defaults if not present
read_config

if [ "$action" = "C" ]; then
    location_x="C"
    location_y="C"
elif [ "$action" = "R" ]; then
    location_x="R"
elif [ "$action" = "P" ]; then
    location_x="P"
    location_y="P"
elif [ "$action" = "W" ]; then
    location_x="W"
    location_y="S"
elif [ "$action" = "coord" ]; then
    location_x="$param_1"
    location_y="$param_2"
fi

write_config
