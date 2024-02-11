#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Updates global prefix, if prefix param is given
#
# Global check exclude, ignoring: is referenced but not assigned
# shellcheck disable=SC2154

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/utils.sh

_this="change_prefix.sh"
[ "$(basename "$0")" != "$_this" ] && error_msg "$_this should NOT be sourced"

#
#  Since this is a critical param, make extra sure we have valid input
#
prefix_char="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
if [ -z "$prefix_char" ]; then
    error_msg "change_prefix.sh No prefix given!"
elif [ "$(printf '%s' "$prefix_char" | wc -m)" -ne 1 ]; then
    error_msg "Must be exactly one char! Was:[$prefix_char]"
fi

prefix="C-${prefix_char}"

$TMUX_BIN set-option -g prefix "$prefix"

$TMUX_BIN display-message "Be aware <prefix> is now: $prefix"
