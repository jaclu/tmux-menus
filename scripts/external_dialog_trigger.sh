#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run from tmux. In order to have access to job control, a second script
#  is simulated to be run in the active pane by using send-keys
#  Since this doesn't really need the normal env, do things directly without
#  any sourcing.
#

[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# Select next menu to display
menu="$1"
[ -z "$menu" ] && menu="$D_TM_BASE_PATH"/items/main.sh
export TMUX_MENUS_EXTERNAL_MENU="$menu"

$TMUX_BIN send-keys C-z
sleep 0.1 # give time for task to be suspended, and shell ready for input
$TMUX_BIN send-keys "$D_TM_BASE_PATH"/scripts/external_dialog_handle.sh Enter
