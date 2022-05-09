#!/bin/sh
#  shellcheck disable=SC2154
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.2 2022-03-29
#
#   Moving current pane within same session or to other session.
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
. "$CURRENT_DIR/utils.sh"

direction="$1"

if [ -z "$direction" ]; then
    error_msg "move_menu.sh was called without direction param" 1
fi


modify_variable() {
    var="$1"
    mod="$2"
    log_it "modify_variable($var, $mod)"
    result="$(echo "$var + $mod" | bc)"
    echo "$result"
}

if [ "$direction" = "up" ]; then
    cached_location_x="$(modify_variable $cached_location_x -1)"
elif [ "$direction" = "down" ]; then
    cached_location_x="$(modify_variable $cached_location_x 1)"
elif[ "$direction" = "left" ]; then
    cached_location_y="$(modify_variable $cached_location_y -1)"
elif[ "$direction" = "right" ]; then
    cached_location_y="$(modify_variable $cached_location_y 1)"
fi

write_cache
