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
     -T "#[align=centre] Move Window "  \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to Main menu"       Home  "run-shell $CURRENT_DIR/main.sh"  \
     "Back to Handling Window"  Left  "run-shell $CURRENT_DIR/windows.sh" \
     "" \
"    Move window to other location"    m  "choose-tree -Gw 'run-shell \"$SCRIPT_DIR/relocate_window.sh M %%\"'" \
     "    Swap window Left"                \<  "swap-window -dt:-1"  \
     "    Swap window Right"               \>  "swap-window -dt:+1"  \
     "" \
     "    Link window to other session"     l  "choose-tree -Gw 'run-shell \"$SCRIPT_DIR/relocate_window.sh L %%\"'" \
     "    Unlink window from this session"  u  "unlink-window" \
     "#{?pane_marked_set,,-}    Swap current window with window" "" ""  \
     "#{?pane_marked_set,,-}    containing marked pane         "  w  swap-window  \
     "" \
     "Help, explaining move & link  -->"         H  "run-shell \"$CURRENT_DIR/help_window_move.sh\""
