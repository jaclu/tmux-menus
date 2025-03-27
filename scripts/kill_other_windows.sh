#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Kill all other windows
#
# Global check exclude, ignoring: is referenced but not assigned

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

_this="kill_other_windows.sh" # error prone if script name is changed :(
[ "$bn_current_script" != "$_this" ] && error_msg "$_this should NOT be sourced"

# linter helpers
window_list=""
current_window=""

tmux_error_handler_assign window_list list-windows -F '#{window_id}' || {
    error_msg "Failed to list windows"
}
tmux_error_handler_assign current_window display-message -p '#{window_id}' || {
    error_msg "Failed to get current window_id"
}

[ "$window_list" = "$current_window" ] && {
    tmux_error_handler display-message "No other windows to kill!"
}

for w in $window_list; do
    if [ "$w" != "$current_window" ]; then
        tmux_error_handler kill-window -t "$w"
    fi
done
