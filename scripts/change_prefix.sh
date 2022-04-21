#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.2 2022-04-21
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

tmux display-message "Be aware <prefix> is now: $prefix"
