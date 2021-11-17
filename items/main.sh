#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1 2021-11-11
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
     "    #{?pane_marked,Unmark,Mark} current pane" "" ""  \
     "<P>  (used by Pane and Windows menu)"  m  "select-pane -m"  \
     "" \
     "<P> Detach from tmux"  d  detach-client     \
     "    Kill server - all your sessions" "" ""  \
     "        on this host are terminated"  k  "confirm-before -p \"kill tmux server on #H ? (y/n)\" kill-server"  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/main.sh\""
