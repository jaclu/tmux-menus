#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-02-03
#
#   Updates global prefix, if prefix param is given
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
. "$CURRENT_DIR/utils.sh"

prefix_char="$1"

if [ -z "$prefix_char" ]; then
    error_msg "change_prefix.sh No prefix given!" 1
fi


prefix="C-${prefix_char}"

tmux set-option -g prefix "$prefix"

tmux display "Be aware <prefix> is now: $prefix"
