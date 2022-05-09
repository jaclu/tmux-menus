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
req_win_width=52
req_win_height=15


open_menu="run-shell $CURRENT_DIR"
this_menu="$CURRENT_DIR/config_location.sh"
reload="; $this_menu"

t_start="$(date +'%s')"  #  if the menu closed in < 1s assume it didnt fit

# shellcheck disable=SC2154
tmux display-menu \
     -T "#[align=centre] $menu_name "             \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to Main menu"      Home  "$open_menu/main.sh"    \
     "Back to Configuration"  Left  "$open_menu/config.sh"  \
     "" \
     "Center"   C  "run-shell '$SCRIPT_DIR/move_menu.sh C $reload'"      \
     "The right side of the terminal (-x)" \
                R  "run-shell '$SCRIPT_DIR/move_menu.sh R $reload'"      \
     "Bottom left of pane" \
                P  "run-shell '$SCRIPT_DIR/move_menu.sh P $reload'"      \
     "The window position on the status line" \
                W  "run-shell '$SCRIPT_DIR/move_menu.sh W $reload'"      \
     "The line above or below the status line (-y)" \
                S  "run-shell '$SCRIPT_DIR/move_menu.sh S $reload'"      \
     "" \
     "Up"       u  "run-shell '$SCRIPT_DIR/move_menu.sh up    $reload'"  \
     "Down"     d  "run-shell '$SCRIPT_DIR/move_menu.sh down  $reload'"  \
     "Left"     l  "run-shell '$SCRIPT_DIR/move_menu.sh left  $reload'"  \
     "Right"    r  "run-shell '$SCRIPT_DIR/move_menu.sh right $reload'"  \
     "-#[align=centre,nodim]------  x increment :$cached_inc_x  ------" "" ""  \
     "increase" x  "run-shell '$SCRIPT_DIR/move_menu.sh x-incr  $reload'"  \
     "decrese"  X  "run-shell '$SCRIPT_DIR/move_menu.sh x-decr  $reload'"  \
     "-#[align=centre,nodim]------  y increment :$cached_inc_y  ------" "" ""  \
     "increase" y  "run-shell '$SCRIPT_DIR/move_menu.sh y-incr  $reload'"  \
     "decrese"  Y  "run-shell '$SCRIPT_DIR/move_menu.sh y-decr  $reload'"  \
                                                     "" \
     "-Bottom left corner defines" "" "" \
     "-menu location!" "" ""

ensure_menu_fits_on_screen
