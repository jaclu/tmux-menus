#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1 2021-11-11
#
#   menu dealing with panes
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
     -T "#[align=centre] Pane manipulation "  \
     -x $menu_location_x -y $menu_location_y \
     \
     "Back to main-menu"       Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Rename pane"         P     "command-prompt -I \"#T\"  -p \"New pane name: \"  \"select-pane -T '%%'\""  \
     "<P> Swap pane to prev"  \{     "swap-pane -U"       \
     "<P> Swap pane to next"  \}     "swap-pane -D"       \
     "#{?pane_marked_set,,-}<P> Swap current pane with marked"      p  swap-pane  \
     "<P> Move pane to a new window"  !  break-pane   \
     "    #{?pane_synchronized,Disable,Activate} synchronized panes"  s  "set -g synchronize-panes"  \
     "    Display Pane size" S "display-message \"Pane: #P size: #{pane_width}x#{pane_height}\"" \
     "" \
     "    Choose a tmux paste buffer" "" ""                     \
     "<P>  (Enter pastes Esq aborts)"  =  "choose-buffer -Z"  \
     "<P> Display pane numbers"        q  display-panes       \
     "<P> Kill current pane"           x  "confirm-before -p \"kill-pane #P? (y/n)\" kill-pane"  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/panes.sh\""
