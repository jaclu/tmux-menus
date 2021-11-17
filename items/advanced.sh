#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1 2021-11-11
#
#   This is the advanced menu, wit more archaic tasks
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
     "    Toggle mouse to: $new_mouse_status"   "m"  "set-option -g mouse $new_mouse_status"  \
     "    Change prefix <$current_prefix>"  p  "command-prompt -1 -p prefix 'run \"$SCRIPT_DIR/change_prefix.sh %%\"'"  \
     "" \
     "<P> Show messages"        \~     show-messages        \
     "<P> Customize options"     C     "customize-mode -Z"  \
     "<P> Describe key binding"  /     "command-prompt -k -p key \"list-keys -1N \\"%%%\\"\""  \
     "<P> Prompt for a command"  :     command-prompt  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/advanced.sh\""
