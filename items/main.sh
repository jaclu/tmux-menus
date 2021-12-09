#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.2 2021-12-04
#
#   Main menu, the one popping up when you hit the trigger
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


tmux display-menu \
     -T "#[align=centre] Main menu " \
     -x $menu_location_x -y $menu_location_y \
     \
     "    Handling Panes"    p  "run-shell $CURRENT_DIR/panes.sh"     \
     "    Handling Windows"  w  "run-shell $CURRENT_DIR/windows.sh"   \
     "    Handling Sessions" s  "run-shell $CURRENT_DIR/sessions.sh"  \
     "    Advanced Options"  a  "run-shell $CURRENT_DIR/advanced.sh"  \
     "" \
     "    Navigate & zoom to ses/win/pane" ""  ""  \
     "<P> use arrows to navigate & zoom"   s   "choose-tree -Zs"  \
     "" \
     "    (Used by Pane and Windows menu)"  "" "" \
     "<P> #{?pane_marked,Unmark,Mark} current pane" m  "select-pane -m"  \
     "" \
     "<P> Detach from tmux"  d  detach-client     \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/main.sh\""

#  Help needs an additional param to tell it where to go back, resulting in the need for this run-shell instance's params to be enclosed 
#  in an addtional level of "" to make both params to be seen as the one expected param to run-shell
