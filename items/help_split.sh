#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.1 2021-12-04
#
#   This is the help menu, in case you havent guessed :)
#
#   There are three types of menu item lines:
#   1) An item leading to an action
#       "Description" "in menu shortcut key" " action taken when it is triggered"
#   2) Just a line of text
#       "Some text to display" "" ""
#   3) Separator line
#       ""
#   All but the last line in the menu, needs to end with a continuation \
#   Whitespace after thhis \ will fail the menu!
#    

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

source "$SCRIPT_DIR/utils.sh"

previous_menu="$1"

if [ -z "$previous_menu" ]; then
    tmux display-message "ERROR: tmux-menus:help was called without notice of what called it"
fi


tmux display-menu  \
     -T "#[align=centre] Help splitting display "  \
     -x $menu_location_x -y $menu_location_y \
     \
     "Back to pevious menu"  Left  "run-shell $previous_menu"  \
     "" \
     "Creating a new pane by splitting" "" "" \
     "curent pane or Window."   "" "" \
     "Window refers to the entire display"       "" ""

