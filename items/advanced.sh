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
#  Gather some info in order to be able to show states
#
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
     "Back to Main menu"  Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Manage clients"                       D  "run-shell $SCRIPT_DIR/manage_clients.sh" \
     "    Toggle mouse to: $new_mouse_status"   m  "set-option -g mouse $new_mouse_status"  \
     "" \
     "<P> Show messages"                       \~  show-messages        \
     "<P> Customize options"                    C  "customize-mode -Z"  \
     "<P> Describe (prefix) key binding"        /  "command-prompt -k -p key \"list-keys -1N \\"%%%\\"\""  \
     "<P> Prompt for a command"                 :  command-prompt  \
     "    Change prefix <$current_prefix>"      p  "command-prompt -1 -p prefix 'run \"$SCRIPT_DIR/change_prefix.sh %%\"'"  \
     "" \
     "Kill server - all your sessions" "" ""  \
     "on this host are terminated    "          k  "confirm-before -p \"kill tmux server on #H ? (y/n)\" kill-server"  \
     "" \
     "Help  -->"  H  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/advanced.sh\""
