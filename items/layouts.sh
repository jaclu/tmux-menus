#!/usr/bin/env bash
#
#   Copyright (c) 2021,2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.0 2022-01-12
#
#   menu dealing with panes
#
#   There are three types of menu item lines:
#   1) An item leading to an action
#       "Description" "in menu shortcut key" " action taken when it is triggered"
#       For any field containing no spaces quotes are optional
#   2) Just a line of text
#       "Some text to display" "" ""
#   3) Separator line
#       ""
#   All but the last line in the menu, needs to end with a continuation \
#   Whitespace after thhis \ will cause the menu to fail!
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

source "$SCRIPT_DIR/utils.sh"


tmux display-menu  \
     -T "#[align=centre] Layouts "            \
     -x $menu_location_x -y $menu_location_y  \
     \
     "Back to main-menu"           Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Even horizontal"          M-1  "select-layout even-horizontal"   \
     "<P> Even vertical"            M-2  "select-layout even-vertical"     \
     "<P> Main horizontal"          M-3  "select-layout main-horizontal"   \
     "<P> Main vertical"            M-4  "select-layout main-vertical"     \
     "<P> Tiled"                    M-5  "select-layout tiled"             \
     "<P> Spread panes out evenly."   E  "select-layout -E"                \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/layouts.sh\""
