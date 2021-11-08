#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0 2021-11-07
#       Initial release
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
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"


tmux display-menu  \
     -T "#[align=centre] Sessions "  \
     -x C -y C  \
     \
     "Back to main-menu"  Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Rename this session"   $  "command-prompt -I \"#S\" \"rename-session -- '%%'\""  \
     "    New session"           n  "command-prompt -p \"Name of new session: \" \"new-session -s '%%'\""  \
     "    Kill current session"  k  "confirm-before -p \"Are you sure you want to kill this session ? (y/n)\" \"run \"${SCRIPT_DIR}/kill_current_session.sh\"\" "  \
     "" \
     "    Choose session, use arrows" ""  ""  \
     "<P>         to navigate & zoom"   s   "choose-tree -Zs"  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/sessions.sh\""
