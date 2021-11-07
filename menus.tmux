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
#
#   If you want to experiment on changing the menus, I would recomend
#   to first clone/copy this repo to a different location on your system.
#
#   Then by just running ./menus.tmix in that location your trigger key
#   will bind to this alternate menu set. So next time you request the menus
#   you will get this in-development menu tree.
#
#   Each menu is run as a script, so you can edit a menu and once it is saved
#   the new content will be displayed next time you trigger the menus.
#
#   So quick turn arround debugging!
#
#   When done, you can either copy/commit your changes to the normal location,
#   and thus make it the new default, or just leave it for now and reactivate
#   your regular menus as per below.
#
#   Next time you start tmux it will start to use the original instance.
#
#   If you don't want to restart, just cd to where the normal location is
#   and do ./menus.tmux again this way your regular menus are again
#   bound to the trigger key.
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

menus_dir="$CURRENT_DIR/items"


source "$CURRENT_DIR/scripts/utils.sh"

trigger_key=$(get_tmux_option "@menus_trigger" "\\")

tmux bind "$trigger_key" run-shell $menus_dir/main.sh
