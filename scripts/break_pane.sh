#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.0 2022-04-21
#
#   Breaks pane to new window as long as there was more than one pane in current
#

if [ "$($TMUX_BIN list-panes | wc -l)" -lt 2 ]; then
    $TMUX_BIN display-message "Only one pane!"
else
    $TMUX_BIN command-prompt -I "#W"  -p "New window name: " "break-pane -n '%%'"
fi
