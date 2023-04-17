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

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

#
#  Since this is a critical param, make extra sure we have valid input
#
prefix_char="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
if [ -z "$prefix_char" ]; then
    error_msg "change_prefix.sh No prefix given!" 1
elif [ "$(printf '%s' "$prefix_char" | wc -m)" -ne 1 ]; then
    error_msg "Must be exactly one char! Was:[$prefix_char]" 1
fi

prefix="C-${prefix_char}"

$TMUX_BIN set-option -g prefix "$prefix"

$TMUX_BIN display-message "Be aware <prefix> is now: $prefix"
