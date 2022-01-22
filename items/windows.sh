#!/usr/bin/env bash
#
#   Copyright (c) 2021,2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-01-19
#
#   Menu dealing with windows handling
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

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

source "$SCRIPT_DIR/utils.sh"



tmux display-menu  \
     -T "#[align=centre] Windows manipulation "  \
     -x "$menu_location_x" -y "$menu_location_y" \
     \
     "Back to main-menu"  Left  "run-shell $CURRENT_DIR/main.sh" \
     "" \
     "    Move window to other location"    m  "choose-tree -Gw 'run-shell \"$SCRIPT_DIR/relocate_window.sh M %%\"'" \
     "    Link window to other session"     l  "choose-tree -Gw 'run-shell \"$SCRIPT_DIR/relocate_window.sh L %%\"'" \
     "    Unlink window from this session"  u  "unlink-window" \
     "#{?pane_marked_set,,-}    Swap current window with window" "" ""  \
     "#{?pane_marked_set,,-}    containing marked pane         "  w  swap-window  \
     "    Move window Left"                \<  "swap-window -dt:-1"  \
     "    Move window Right"               \>  "swap-window -dt:+1"  \
     "" \
     "    New window after current"         n  "command-prompt -p \"Name of new window: \" \"new-window -a -n '%%'"  \
     "<P> New window at the end"            c  "command-prompt -p \"Name of new window: \" \"new-window -n '%%'"     \
     "" \
     "<P> Rename window"                    ,  "command-prompt -I \"#W\"  -p \"New window name: \"  \"rename-window '%%'\""  \
     "    Display Window size"              s  "display-message \"Window size: #{window_width}x#{window_height}\""           \
     "" \
     "<P> Kill current window"             \&  "confirm-before -p \"kill-window #W? (y/n)\" kill-window"  \
     "    Kill all other windows"           K  "confirm-before -p \"Are you sure you want to kill all other windows? (y/n)\" \"run \"${SCRIPT_DIR}/kill_other_windows.sh\" \" "  \
     "" \
     "Help, explaining move & link"         h  "run-shell \"$CURRENT_DIR/help_windows.sh\""
