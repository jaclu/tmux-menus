#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Breaks pane to new window as long as there was more than one pane in current
#
# Global check exclude, ignoring: is referenced but not assigned
# shellcheck disable=SC2154

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

#  shellcheck disable=SC1091
. "$D_TM_BASE_PATH/scripts/utils.sh"

_this="break_pane.sh"
[ "$(basename "$0")" != "$_this" ] && error_msg "$_this should NOT be sourced"

if [ "$($TMUX_BIN list-panes | wc -l)" -lt 2 ]; then
    $TMUX_BIN display-message "Only one pane!"
else
    $TMUX_BIN command-prompt -I "#W" -p "New window name: " \
        "break-pane -n '%%'"
fi
