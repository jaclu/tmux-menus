#!/bin/sh
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Unlink a window, and jump to one of its other instances
#   Not complete, so not used anywhere yet
#

tmux_select_and_attach() {
    #   local target_session
    target_session=$(
        $TMUX_BIN list-windows -F "#{session_name}:#{window_index} #{window_id}" |
            awk -v id="$1" '$2 == id {print $1}'
    )
    if [ -n "$target_session" ]; then
        $TMUX_BIN switch-client -t "$target_session" && $TMUX_BIN select-window -t "$1"
    else
        error_msg_safe "No target session found"
    fi
}

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers_minimal.sh
. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

win_name="$($TMUX_BIN display-message -p '#W')"

# tmux list-windows -a -F "#{session_name}:#{window_index} #{window_id} #{window_name}"

# instances="$($TMUX_BIN list-windows -a -F "#{session_name}:#{window_id}" |
#     grep "$win_name" | wc -l)"

# [ "$instances" -lt 2 ] && {
#     error_msg_safe "This window is
# }

$TMUX_BIN unlink-window 2>/dev/null || {
    error_msg_safe "Failed to unlink a single instance"
}

tmux_select_and_attach "$win_name"

# # jump to a random other instance of the window
# $TMUX_BIN select-window -t "$win_name" || {
#     error_msg_safe "Failed to attach to other instance"
# }
