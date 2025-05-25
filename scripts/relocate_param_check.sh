#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Common stuff for relocate_pane.sh & relocate_windows.sh
#   Validates parameters
#
# Global check exclude, ignoring: is referenced but not assigned

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

# Should be sourced
_this="relocate_param_check.sh" # error prone if script name is changed :(
[ "$bn_current_script" = "$_this" ] && error_msg_safe "$_this SHOULD be sourced"

item_type="$1"

case "$item_type" in
"w" | "p") : ;; # Valid parameters
*)
    # NEEDS TESTING
    error_msg_safe "param_check($1) First param must be W or P!"
    ;;
esac

action="$2"

case "$action" in
"m") : ;; # Valid parameters
"l")
    if [ "$item_type" = "p" ]; then
        # NEEDS TESTING
        error_msg_safe "param_check() Panes can not be linked!"
    fi
    ;;
*)
    # NEEDS TESTING
    set -- "param_check($1,$2) 2nd param must be l or m" \
        "Indicating move or link action"
    error_msg_safe "$*"
    ;;
esac

#
#  inputs:
#    with pane idx:      =main:1.%13
#    with window idx:    =main:3.
#    without window idx: =main:
#
raw_dest="$3"

if [ -z "$raw_dest" ]; then
    # NEEDS TESTING
    error_msg_safe "param_check() - no destination param (\$3) given!"
fi

tmux_error_handler_assign cur_ses display-message -p '#S'

dest="${raw_dest#*=}" # skipping initial =
win_pane="${dest#*:}" # after first colon
# shellcheck disable=SC2034 # used in relocate_pane.sh & relocate_window.sh
{
    dest_ses="${dest%%:*}"         # up to first colon excluding it
    dest_win_idx="${win_pane%%.*}" # up to first dot excluding it
    dest_pane_idx="${win_pane#*.}"
}
