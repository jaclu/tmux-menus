#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0 2021-11-07
#       Initial release
#
#   Menu dealing with windows
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


tmux display-menu  \
     -T "#[align=centre] Windows manipulation "  \
     -x C -y C  \
     \
     "Back to main-menu"     Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Rename window"      ,     "command-prompt -I \"#W\"  -p \"New window name: \"  \"rename-window '%%'\""  \
     "    Move window Left"   l     "swap-window -dt:-1"  \
     "    Move window Right"  r     "swap-window -dt:+1"  \
     "#{?pane_marked_set,,-}    Swap current window with window" "" ""  \
     "#{?pane_marked_set,,-}             containing marked pane"  W  swap-window  \
     "" \
     "    New window after current"   n  "command-prompt -p \"Name of new window: \" \"new-window -a -n '%%'"  \
     "<P> New window at the end"      c  "command-prompt -p \"Name of new window: \" \"new-window -n '%%'"  \
     "<P> Kill current window"       \&  "confirm-before -p \"kill-window #W? (y/n)\" kill-window"  \
     "" \
     "    Choose window, use arrows" ""  ""  \
     "<P>        to navigate & zoom"  w   "choose-tree -Zw"  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/windows.sh\""
