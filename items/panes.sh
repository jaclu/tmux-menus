#!/usr/bin/env bash
#
#   Copyright (c) 2021,2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-01-19
#
#   menu dealing with panes
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
     -T "#[align=centre] Pane manipulation "  \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to main-menu"  Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "    Move to other window or session"  m  "choose-tree -Gw 'run-shell \"$SCRIPT_DIR/relocate_pane.sh M %%\"'" \
     "#{?pane_marked_set,,-}    Swap current pane with marked"  p  swap-pane  \
     "<P> Swap pane with prev"        \{  "swap-pane -U" \
     "<P> Swap pane with next"        \}  "swap-pane -D" \
     "" \
     "<P> Move pane to a new window"   !  break-pane \
     "" \
     "    Rename pane"                 P  "command-prompt -I \"#T\"  -p \"New pane name: \"  \"select-pane -T '%%'\""  \
     "<P> Display pane numbers"        q  display-panes \
     "" \
     "    Choose a tmux paste buffer" "" ""                   \
     "<P> (Enter pastes Esq aborts) "  =  "choose-buffer -Z"  \
     "" \
     "    #{?pane_synchronized,Disable,Activate} synchronized panes"  S  "set -g synchronize-panes"  \
     "    Display Pane size" s "display-message \"Pane: #P size: #{pane_width}x#{pane_height}\"" \
     "    Save pane history to file"   H  "command-prompt -p 'Save current-pane history to filename:' -I '~/tmux.history' 'capture-pane -S - -E - ; save-buffer %1 ; delete-buffer'" \
     "<P> Kill current pane"           x  "confirm-before -p \"kill-pane #P? (y/n)\" kill-pane"      \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/panes.sh\""
