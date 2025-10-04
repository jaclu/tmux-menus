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

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/helpers.sh

_this="break_pane.sh" # error prone if script name is changed :(
[ "$bn_current_script" != "$_this" ] && error_msg "$_this should NOT be sourced"

tmux_error_handler_assign pane_list list-panes
if [ -n "$pane_list" ] && [ "$(echo "$pane_list" | wc -l)" -lt 2 ]; then
    tmux_error_handler display-message "Only one pane!"
else
    tmux_error_handler command-prompt -I '#W' -p "New window name: " "break-pane -n '%%'"
fi
