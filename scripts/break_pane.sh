#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Breaks pane to new window as long as there was more than one pane in current
#
# Global check exclude, ignoring: is referenced but not assigned

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

_this="break_pane.sh" # error prone if script name is changed :(
[ "$bn_current_script" != "$_this" ] && error_msg_safe "$_this should NOT be sourced"

tmux_error_handler_assign pane_list list-panes
if [ -n "$pane_list" ] && [ "$(echo "$pane_list" | wc -l)" -lt 2 ]; then
    tmux_error_handler display-message "Only one pane!"
else
    tmux_error_handler command-prompt -I '#W' -p "New window name: " "break-pane -n '%%'"
fi
