#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-02-03
#
#   Main menu, the one popping up when you hit the trigger
#
#   Types of menu item lines.
#
#   1) An item leading to an action
#          "Description" "In-menu key" "Action taken when it is triggered"
#
#   2) Just a line of text
#      You must supply two empty strings, in order for the
#      menu logic to interpret it as a full menu line item.
#          "Some text to display" "" ""
#
#   3) Separator line
#      This is a propper gaphical separator line, without any label.
#          ""
#
#   4) Labeled separator line
#      Not pefect, since you will have at least one space on each side of
#      the labeled separator line, but using something like this and carefully
#      increase the dashes until you are just below forcing the menu to just
#      grow wider, seems to be as close as it gets.
#          "#[align=centre]-----  Other stuff  -----" "" ""
#
#
#   All but the last line in the menu, needs to end with a continuation \
#   Whitespace after this \ will cause the menu to fail!
#   For any field containing no spaces, quotes are optional.
#

CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

. "$SCRIPT_DIR/utils.sh"


tmux display-menu  \
     -T "#[align=centre] Move Window Help"      \
     -x "$menu_location_x" -y "$menu_location_y" \
     \
     "Back to Main menu"    Home  "run-shell $CURRENT_DIR/main.sh"  \
     "Back to Move Window"  Left  "run-shell $CURRENT_DIR/window_move.sh" \
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
