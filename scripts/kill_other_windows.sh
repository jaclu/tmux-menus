#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Kill all other windows
#
# Global check exclude, ignoring: is referenced but not assigned

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

_this="kill_other_windows.sh" # error prone if script name is changed :(
[ "$current_script" != "$_this" ] && error_msg "$_this should NOT be sourced"

window_list="$(IFS=" " tmux_error_handler list-windows -F '#{window_id}')"
current_window="$(tmux_error_handler display-message -p '#{window_id}')"

for w in $window_list; do
    if [ "$w" != "$current_window" ]; then
        tmux_error_handler kill-window -t "$w"
    fi
done
