#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.2 2021-12-21
#
#   This is the advanced menu, wit more archaic tasks
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

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

source "$SCRIPT_DIR/utils.sh"


current_mouse_status="$(tmux show-option -g mouse | cut -d' ' -f2)"
if [ "$current_mouse_status" = "on" ]; then
    new_mouse_status="off"
else
    new_mouse_status="on"
fi


current_prefix="$(tmux show-option -g prefix | cut -d' ' -f2 | cut -d'-' -f2)"


tmux display-menu \
     -T "#[align=centre] Advanced options "  \
     -x $menu_location_x -y $menu_location_y \
     \
     "Back to main-menu"  Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Show messages"        \~     show-messages        \
     "<P> Customize options"     C     "customize-mode -Z"  \
     "<P> Describe key binding"  /     "command-prompt -k -p key \"list-keys -1N \\"%%%\\"\""  \
     "<P> Prompt for a command"  :     command-prompt  \
     "" \
     "    Toggle mouse to: $new_mouse_status"   "m"  "set-option -g mouse $new_mouse_status"  \
     "    Change prefix <$current_prefix>"  p  "command-prompt -1 -p prefix 'run \"$SCRIPT_DIR/change_prefix.sh %%\"'"  \
     "" \
     "Kill server - all your sessions" "" ""  \
     "on this host are terminated    "  K  "confirm-before -p \"kill tmux server on #H ? (y/n)\" kill-server"  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/advanced.sh\""
