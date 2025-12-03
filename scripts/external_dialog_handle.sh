#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run in the current pane, so job control is available
#

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

menu_name="$1"
[ -z "$menu_name" ] && menu_name="$cfg_main_menu"

$menu_name

if pgrep -P "$PPID" | grep -qv "$$"; then
    $TMUX_BIN send-keys fg Enter
fi
