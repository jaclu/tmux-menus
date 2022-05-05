#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.8 2022-04-21
#
#   Handling Window
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
#      This is a proper graphical separator line, without any label.
#          ""
#
#   4) Labeled separator line
#      Not perfect, since you will have at least one space on each side of
#      the labeled separator line, but using something like this and carefully
#      increase the dashes until you are just below forcing the menu to just
#      grow wider, seems to be as close as it gets.
#          "#[align=centre]-----  Other stuff  -----" "" ""
#
#
#   All but the last line in the menu, needs to end with a continuation \
#   White space after this \ will cause the menu to fail!
#   For any field containing no spaces, quotes are optional.
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"


# shellcheck disable=SC2154
tmux display-menu  \
     -T "#[align=centre] Handling Window   "  \
     -x "$menu_location_x" -y "$menu_location_y" \
     \
     "Main menu    -->"  Left  "run-shell $CURRENT_DIR/main.sh" \
     "Move window  -->"  M     "run-shell \"$CURRENT_DIR/window_move.sh\"" \
     "" \
     "<P> Rename window"             ,  "command-prompt -I \"#W\"  -p \"New window name: \"  \"rename-window '%%'\""  \
     "    New window after current"  a  "command-prompt -p \"Name of new window: \" \"new-window -a -n '%%'"  \
     "<P> New window at the end"     c  "command-prompt -p \"Name of new window: \" \"new-window -n '%%'"     \
     "    Display Window size"       s  "display-message \"Window size: #{window_width}x#{window_height}\""           \
     "" \
     "<P> Last selected window"        l  "last-window ; run-shell \"$CURRENT_DIR/windows.sh\"" \
     "<P> Previous window (in order)"  p  "previous-window ; run-shell \"$CURRENT_DIR/windows.sh\"" \
     "<P> Next     window (in order)"  n  "next-window ; run-shell \"$CURRENT_DIR/windows.sh\"" \
     "" \
     "Previous window with an alert" P "previous-window -a ; run-shell \"$CURRENT_DIR/windows.sh\"" \
     "Next window with an alert" N "next-window -a ; run-shell \"$CURRENT_DIR/windows.sh\"" \
     "" \
     "<P> Kill current window"    \&  "confirm-before -p \"kill-window #W? (y/n)\" kill-window"  \
     "    Kill all other windows"  o  "confirm-before -p \"Are you sure you want to kill all other windows? (y/n)\" \"run \"${SCRIPT_DIR}/kill_other_windows.sh\" \" "  \
     "" \
     "Help  -->"  H  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/windows.sh\""
