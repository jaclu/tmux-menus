#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run in the current pane, so job control is available
#  Displays main menu
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

# Run the main script
"$D_TM_BASE_PATH"/items/main.sh

#
#  If a process was suspended, bring it back into fore-ground
#
pgrep -P "$PPID" | grep -qv "$$" && $TMUX_BIN send-keys fg Enter
