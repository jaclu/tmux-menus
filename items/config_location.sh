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

menu_name="Configure Menu Location"
req_win_width=32
req_win_height=24


open_menu="run-shell $CURRENT_DIR"
this_menu="$CURRENT_DIR/config_location.sh"
reload="; $this_menu"
move_menu="run-shell '$SCRIPT_DIR/move_menu.sh $req_win_width $req_win_height"
t_start="$(date +'%s')"  #  if the menu closed in < 1s assume it didnt fit

# shellcheck disable=SC2154
tmux display-menu \
     -T "#[align=centre] $menu_name "             \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to Main menu"      Home  "$open_menu/main.sh"    \
     "Back to Configuration"  Left  "$open_menu/config.sh"  \
     "" \
     "Center"          C  "$move_menu C $reload'"      \
     "Right side"      R  "$move_menu R $reload'"      \
     "Pane bot left"   P  "$move_menu P $reload'"      \
     "Win pos status"  W  "$move_menu W $reload'"      \
     "By status line"  S  "$move_menu S $reload'"      \
     "coordinates"     c  "
     "decrese"  Y  "$move_menu  y-decr  $reload'"  \
     "" \
     "-Bottom left corner defines" "" "" \
     "-menu location!" "" ""

ensure_menu_fits_on_screen
