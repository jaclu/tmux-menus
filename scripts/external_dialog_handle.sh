#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run in the current pane, so job control is available
#

#  Full path to tmux-menus plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

menu_name="$1"
[ -z "$menu_name" ] && menu_name="$f_main_menu"

$menu_name

if pgrep -P "$PPID" | grep -qv "$$"; then
    $TMUX_BIN send-keys fg Enter
fi
