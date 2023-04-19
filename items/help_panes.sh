#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help regarding panes menu
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

previous_menu="$1"

if [ -z "$previous_menu" ]; then
    error_msg "help_panes.sh was called without notice of what called it"
fi

menu_name="Help Panes"

set -- \
    0.0 M Left "Back to Previous menu  <--" "$previous_menu" \
    0.0 S \
    0.0 T "-#[nodim]When saving history with escapes" \
    0.0 T "-#[nodim]less/most will not be able" \
    0.0 T "-#[nodim]to display the content." \
    0.0 S \
    0.0 T "-#[nodim]You would have to use tools like" \
    0.0 T "-#[nodim]cat/bat in order to see the colors"

req_win_width=39
req_win_height=10

menu_parse "$@"
