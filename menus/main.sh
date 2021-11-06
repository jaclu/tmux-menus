#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0 2021-11-06-
#       Initial release
#
menu_name="$0"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. utils.sh

menu_title="Main menu"

show_help=0

items=(
    "    Handling Panes"    p  "run-shell $CURRENT_DIR/panes.sh"
    "    Handling Windows"  w  "run-shell $CURRENT_DIR/windows.sh"
    "    Handling Sessions" s  "run-shell $CURRENT_DIR/sessions.sh"
    "    Advanced Options"  a  "run-shell $CURRENT_DIR/advanced.sh"
    ""
    "    #{?pane_marked,Unmark,Mark} current pane - used by" "" ""
    "<P>   Pane and  Windows menu"  m  "select-pane -m"
    ""
    "<P> Detach from tmux"  d  detach-client
    "    Kill server - all your" "" ""
    "    sesssions on this host" "" ""
    "    are terminated"  k  'confirm-before -p \"kill tmux server on #H ? (y/n)\" kill-server'
)

eval $(render_menu)

exit 0
