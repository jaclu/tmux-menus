#!/usr/bin/env bash
#
#   Copyright (c) 2021,2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.0 2022-01-31
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MENUS_DIR="$CURRENT_DIR/items"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

source "$SCRIPTS_DIR/utils.sh"


#
#  In shell script, backslash needs to be doubled also inside quotes.
#
default_key="\\"



#
#  Only one of menus_trigger or menus_root_trigger can be set.
#  If both are set an error message is displayed, and tmux-menus will not be
#  activated. Obviously, if it was bound to a key in a previous init, that bind
#  is still active.
#
#  In case you do not wan't to restart tmux, you need to unset the variable you
#  no longer want to have assigned:
#     tmux set -ug @menus_trigger
#     tmux set -ug @menus_root_trigger
#
#  To unbind a previously bound key, use something like:
#     tmux unbind-key '\'
#


trigger_key=$(get_tmux_option "@menus_trigger")
root_key=$(get_tmux_option "@menus_root_trigger")


if [ -n "$trigger_key" ] && [ -n "$root_key" ]; then 
    tmux display 'ERROR: both "@menus_trigger" and "@menus_root_trigger" are set, only one can be used!'
    exit 0  # Exit 0 wont throw a tmux error
fi

if [ -n "$root_key" ]; then
    tmux bind -n "$root_key" run-shell $MENUS_DIR/main.sh
else
    # Use defaullt key, if not assigned
    "${trigger_key:=$default_key}"
    
    tmux bind  "$trigger_key" run-shell $MENUS_DIR/main.sh
fi
