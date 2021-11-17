#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.1 2021-11-14
#
#   Menu dealing with windows
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


tmux display-menu  \
     -T "#[align=centre] Windows manipulation "  \
     -x $menu_location_x -y $menu_location_y \
     \
     "Back to main-menu"     Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Rename window"      ,     "command-prompt -I \"#W\"  -p \"New window name: \"  \"rename-window '%%'\""  \
     "    Move window Left"   l     "swap-window -dt:-1"  \
     "    Move window Right"  r     "swap-window -dt:+1"  \
     "#{?pane_marked_set,,-}    Swap current window with window" "" ""  \
     "#{?pane_marked_set,,-}             containing marked pane"  w  swap-window  \
     "    Display Window size" S "display-message \"Window size: #{window_width}x#{window_height}\"" \
     "" \
     "    New window after current"   n  "command-prompt -p \"Name of new window: \" \"new-window -a -n '%%'"  \
     "<P> New window at the end"      c  "command-prompt -p \"Name of new window: \" \"new-window -n '%%'"  \
     "<P> Kill current window"       \&  "confirm-before -p \"kill-window #W? (y/n)\" kill-window"  \
     "    Kill all other windows"  K  "confirm-before -p \"Are you sure you want to kill all other windows? (y/n)\" \"run \"${SCRIPT_DIR}/kill_other_windows.sh\" \" "  \
     "" \
     "    Choose window, use arrows" ""  ""  \
     "<P>        to navigate & zoom"  W   "choose-tree -Zw"  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/windows.sh\""
