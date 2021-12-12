#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.1 2021-11-11
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MENUS_DIR="$CURRENT_DIR/items"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

source "$SCRIPTS_DIR/utils.sh"

trigger_key=$(get_tmux_option "@menus_trigger" "\\")

#
# If you run tmux > 3.0 you can add the param -N "Displays tmux-menus"
# right after bind. This will display the key binding when you do <prefix> ?
#
tmux bind  "$trigger_key" run-shell $MENUS_DIR/main.sh
