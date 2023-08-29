#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Kill all other windows
#
# Global check exclude, ignoring: is referenced but not assigned
# shellcheck disable=SC2154

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

# safety check to ensure it is defined
[ -z "$TMUX_BIN" ] && echo "ERROR: kill_other_windows.sh - TMUX_BIN is not defined!"

window_list="$(IFS=" " $TMUX_BIN list-windows -F '#{window_id}')"
current_window="$($TMUX_BIN display-message -p '#{window_id}')"

for w in $window_list; do
    if [ "$w" != "$current_window" ]; then
        $TMUX_BIN kill-window -t "$w"
    fi
done
