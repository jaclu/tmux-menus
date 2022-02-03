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


#
#  Please note that I use revrse logic for prev / next.
#  This is due to that the tmux default logic seems reversed,
#  this notion of prev / next just makes more sense to me.
#
tmux display-menu  \
     -T "#[align=centre] Sessions "  \
     -x $menu_location_x -y $menu_location_y \
     \
     "Back to Main menu"  Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Rename this session"     \$  "command-prompt -I \"#S\" \"rename-session -- '%%'\""  \
     "    List sessions"            l   "list-sessions" \
     "<P> Previous session"        \(  "switch-client -p" \
     "<P> Next session"            \)  "switch-client -n" \
     "    New session"              n  "command-prompt -p \"Name of new session: \" \"new-session -s '%%'\""  \
     "    Kill current session"     k  "confirm-before -p \"Are you sure you want to kill this session? (y/n)\" \"run \"${SCRIPT_DIR}/kill_current_session.sh\"\" "  \
     "    Kill all other sessions"  o  "confirm-before -p \"Are you sure you want to kill all other sessions? (y/n)\" \"kill-session -a\""  \
     "" \
     "Help  -->"  H  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/sessions.sh\""
