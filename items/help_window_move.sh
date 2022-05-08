#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.1  2022-05-08
#
#   Help about move and link window
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Help, Move Window"
req_win_width=44
req_win_height=15


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu  \
     -T "#[align=centre] $menu_name "            \
     -x "$menu_location_x" -y "$menu_location_y" \
     \
     "Back to Main menu"    Home  "run-shell $CURRENT_DIR/main.sh"         \
     "Back to Move Window"  Left  "run-shell $CURRENT_DIR/window_move.sh"  \
     "---  Move & Link window navigation  --"    "" "" \
     "-Displays a navigation tree, options:"     "" "" \
     "-1 - Chose a session."                     "" "" \
     "-    Current window will be put as"        "" "" \
     "-    the last window in that session."     "" "" \
     "-2 - Choose a window in a session."        "" "" \
     "-    Current window will be inserted"      "" "" \
     "-    on that location, pushing remaining"  "" "" \
     "-    windows one step to the right."       "" "" \
     "-If you choose a pane, the pane part"      "" "" \
     "-of the selection will be ignored."        "" ""


ensure_menu_fits_on_screen
