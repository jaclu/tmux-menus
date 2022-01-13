#!/usr/bin/env bash
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.0 2022-01-13
#
#   This is the help menu, in case you havent guessed :)
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
#   Argh, the display-menu handling is soo primitive,
#   since menus do not care about window size, and can't be dynamically resized.
#   If it is to large to fit, it will just fail to display.
#
#   This one is on the large side at 43x15, but should be visible on an iPhone
#   with font size 12. Could be problems on a mini if the touch keyboard eats to
#   much vertical space. If you experience that,
#   please let me know what you get from:
#
#   tmux display -p "Window size: #{window_width}x#{window_height}" 
#
#   And I will adjust it to fit within those limits.
#   

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

source "$SCRIPT_DIR/utils.sh"


tmux display-menu  \
     -T "#[align=centre] Windows Help"      \
     -x "$menu_location_x" -y "$menu_location_y" \
     \
     "Back to windows menu"  Left  "run-shell $CURRENT_DIR/windows.sh" \
     "" \
     "==  Move & Link window navigatom  ==" "" "" \
     "Displays a navigation tree, options:" "" "" \
     "1 - Chose a session." "" "" \
     "    Current window will be put as" "" "" \
     "    the last window in that session." "" "" \
     "2 - Choose a window in a session." "" "" \
     "    Current window will be inserted" "" "" \
     "    on that location, pushing remaining" "" "" \
     "    windows one step to the right." "" "" \
     "If you choose a pane, the pane part" "" "" \
     "of the selection will be ignored." "" ""
