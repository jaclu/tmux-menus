#!/bin/sh
#
#   Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Running whiptail from a tmux shortcut
#

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")/items"

#  shellcheck disable=SC1091
. "$CURRENT_DIR/utils.sh"

#  shellcheck disable=SC2154
"$TMUX_BIN" send-keys C-z "$ITEMS_DIR/main.sh ; fg" Enter
