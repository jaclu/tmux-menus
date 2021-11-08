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

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

menus_dir="$CURRENT_DIR/items"


source "$CURRENT_DIR/scripts/utils.sh"

trigger_key=$(get_tmux_option "@menus_trigger" "\\")

tmux bind -N "Displays tmux-menus"  "$trigger_key" run-shell $menus_dir/main.sh
