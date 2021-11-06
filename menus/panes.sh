#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0 2021-11-06-
#       Initial release
#

menu_name="$0"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. utils.sh


menu_title="Pane manipulation"

items=(
    "Back to main-menu"       Left  "run-shell $CURRENT_DIR/main.sh"
     ""
     "<P> Rename pane"         P     'command-prompt -I \"#T\"  -p \"New pane name: \"  \"select-pane -T '%%'\"' 
     "<P> Swap pane to prev"  \{     "swap-pane -U"
     "<P> Swap pane to next"  \}     "swap-pane -D"
     "#{?pane_marked_set,,-}<P> Swap current pane with marked"      p  swap-pane
     "<P> Move pane to a new window"  !  break-pane
     "    #{?pane_synchronized,Disable,Activate} synchronized panes"  s  "set -g synchronize-panes"
     ""
     "    Choose a tmux paste buffer" "" ""
     "<P>  (Enter pastes Esq aborts)"  =  "choose-buffer -Z"
     "<P> Display pane numbers"         q  display-panes
     "<P> Kill current pane"            x  'confirm-before -p \"kill-pane #P? (y/n)\" kill-pane'
)

show_help=0

eval $(render_menu)

exit 0
