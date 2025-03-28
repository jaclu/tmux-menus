#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Updates global prefix, if prefix param is given
#
# Global check exclude, ignoring: is referenced but not assigned

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

_this="change_prefix.sh" # error prone if script name is changed :(
[ "$bn_current_script" != "$_this" ] && error_msg_safe "$_this should NOT be sourced"

#
#  Since this is a critical param, make extra sure we have valid input
#
prefix_char="$1"
if [ -z "$prefix_char" ]; then
    error_msg_safe "change_prefix.sh No prefix given!"
elif [ "$(printf '%s' "$prefix_char" | wc -m)" -ne 1 ]; then
    error_msg_safe "Must be exactly one char! Was:[$prefix_char]"
fi

prefix="C-$(lowercase_it "$prefix_char")"

tmux_error_handler set-option -g prefix "$prefix"

tmux_error_handler display-message "Be aware <prefix> is now: $prefix"
