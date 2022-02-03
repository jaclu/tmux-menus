#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-02-03
#
#   Moving current pane within same session or to other session.
#

CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

. $CURRENT_DIR/relocate_param_check.sh

param_check P "$1" "$2"


tmux move-pane -t "${dest_ses}:${dest_win_idx}.${dest_pane_idx}"

if [ "$cur_ses" != "$dest_ses" ]; then
    #
    #  When Window / Pane is moved to another session, focus does not 
    #  auto-switch, so this manually sets focus.
    #
    tmux switch-client -t "$dest_ses"  # switch focus to new location    
fi
