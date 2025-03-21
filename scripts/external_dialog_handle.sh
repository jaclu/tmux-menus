#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run in the current pane, so job control is available
#  Displays main menu
#  Since this doesn't really need the normal env, do things directly without
#  any sourcing.
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# Run the main script
"$D_TM_BASE_PATH"/items/main.sh

#
#  If a process was suspended, bring it back into fore-ground
#
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"
pgrep -P "$PPID" | grep -qv "$$" && $TMUX_BIN send-keys fg Enter
