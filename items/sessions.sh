#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.2 2021-11-13
#
#   Menu dealing with sessions
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


#
#  Please note that I use revrse logic for prev / next.
#  This is due to that the tmux default logic seems reversed,
#  this notion of prev / next just makes more sense to me.
#
tmux display-menu  \
     -T "#[align=centre] Sessions "  \
     -x $menu_location_x -y $menu_location_y \
     \
     "Back to main-menu"  Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Rename this session"   \$  "command-prompt -I \"#S\" \"rename-session -- '%%'\""  \
     "<P> Previous session"      \(  "switch-client -p" \
     "<P> Next session"          \)  "switch-client -n" \
     "    New session"           N  "command-prompt -p \"Name of new session: \" \"new-session -s '%%'\""  \
     "    Kill current session"  k  "confirm-before -p \"Are you sure you want to kill this session? (y/n)\" \"run \"${SCRIPT_DIR}/kill_current_session.sh\"\" "  \
     "    Kill all other sessions"  K  "confirm-before -p \"Are you sure you want to kill all other sessions? (y/n)\" \"kill-session -a\""  \
     "" \
     "    Choose session, use arrows" ""  ""  \
     "<P>         to navigate & zoom"   s   "choose-tree -Zs"  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/sessions.sh\""
