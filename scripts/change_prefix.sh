#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Updates global prefix, if prefix param is given
#
# Global check exclude, ignoring: is referenced but not assigned

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/utils.sh
. "$D_TM_BASE_PATH"/scripts/utils.sh

_this="change_prefix.sh" # error prone if script name is changed :(
[ "$current_script" != "$_this" ] && error_msg "$_this should NOT be sourced"

#
#  Since this is a critical param, make extra sure we have valid input
#
prefix_char="$1"
if [ -z "$prefix_char" ]; then
    error_msg "change_prefix.sh No prefix given!" 0 true
elif [ "$(printf '%s' "$prefix_char" | wc -m)" -ne 1 ]; then
    error_msg "Must be exactly one char! Was:[$prefix_char]" 0 true
fi

prefix="C-${prefix_char}"

$TMUX_BIN set-option -g prefix "$prefix"

$TMUX_BIN display-message "Be aware <prefix> is now: $prefix"
