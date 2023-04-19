#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about move and link window
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

previous_menu="$1"

if [ -z "$previous_menu" ]; then
    error_msg "help.sh was called without notice of what called it"
fi

menu_name="Help, Move/Link Window"

set -- \
    0.0 M Left "Back to Previous menu  <--" "$previous_menu" \
    0.0 S \
    0.0 T "-#[nodim]Displays a navigation tree" \
    0.0 T "-#[nodim]1 - Chose a session." \
    0.0 T "-#[nodim] Current window will be put as" \
    0.0 T "-#[nodim] the last window in that session." \
    0.0 T "-#[nodim]2 - Choose a window in a session." \
    0.0 T "-#[nodim] Current window will be inserted" \
    0.0 T "-#[nodim] on that location, pushing other" \
    0.0 T "-#[nodim] windows one step to the right." \
    0.0 T "-#[nodim]3 - If you choose a pane," \
    0.0 T "-#[nodim] the pane part of the selection" \
    0.0 T "-#[nodim] is ignored."

req_win_width=38
req_win_height=15

menu_parse "$@"
