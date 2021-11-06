#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-mouse-swipe
#
#   Version: 1.1 2021-11-04
#       Added unbinding of the right click default popup
#     1.0  2021-10-07
#       Initial release
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

menus_dir="$CURRENT_DIR/menus"



bind \\ run-shell $menus_dir/main.sh

