#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 0.0.1 2022-05-09
#
#   Main menu, the one popping up when you hit the trigger
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

read_cache

menu_name="Configuration"
req_win_width=40
req_win_height=17


this_menu="$CURRENT_DIR/config.sh"
reload="; run-shell '$this_menu'"


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu \
     -T "#[align=centre] $menu_name "             \
     -x "$cached_location_x" -y "$cached_location_y"  \
     \
     "-#[align=centre,nodim]----  Move menu  ----" "" "" \
     "Up"     u run-shell "$SCRIPT_DIR/move_menu up $reload" \
     "Down"   d run-shell "$SCRIPT_DIR/move_menu up $reload" \
     "Left"   l run-shell "$SCRIPT_DIR/move_menu up $reload" \
     "Right"  r run-shell "$SCRIPT_DIR/move_menu up $reload"


ensure_menu_fits_on_screen
