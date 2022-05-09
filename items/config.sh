#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.0  2022-05-09
#
#   Live configuration. So far only menu location is available
#

#  shellcheck disable=SC2034,SC2154
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Configure Menu Location"
req_win_width=30
req_win_height=14


open_menu="run-shell $CURRENT_DIR"
this_menu="$CURRENT_DIR/config.sh"
reload="; $this_menu"
move_menu="run-shell '$SCRIPT_DIR/move_menu.sh"

#
#  The -p sequence will get wrecked by lnie breaks,
#  so left as one annoyingly long line
#
set_coordinates="command-prompt \
    -I \"$location_x\",\"$location_y\" \
    -p \"horizontal pos (max: #{window_width}):\",\"vertical pos (max: #{window_height}):\" \
    \"$move_menu coord %1 %2 $reload'\""


t_start="$(date +'%s')"  #  if the menu closed in < 1s assume it didnt fit


# shellcheck disable=SC2154
tmux display-menu \
    -T "#[align=centre] $menu_name "             \
    -x "$menu_location_x" -y "$menu_location_y"  \
    \
    "Back to Main menu"  Left  "$open_menu/main.sh"  \
    "" \
    "Center"              c  "$move_menu C $reload'"    \
    "Right edge of pane"  r  "$move_menu R $reload'"    \
    "Pane bottom left"    p  "$move_menu P $reload'"    \
    "Win pos status"      w  "$move_menu W $reload'"    \
    "By status line"      l  "$move_menu S $reload'"    \
    "" \
    "set coordinates"     s  "$set_coordinates"         \
    "" \
    "-When using coordinates" "" "" \
    "-lower left corner is set!" "" ""


ensure_menu_fits_on_screen
