#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
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

menu_name="Help summary"

set -- \
    0.0 M Left "Back to Previous menu  <--" "$previous_menu" \
    0.0 S \
    0.0 T "-#[nodim]'-->'  Indicates this will open a" \
    0.0 T "-#[nodim]'<--'  new menu." \
    0.0 S \
    0.0 T "-#[nodim]<P> Indicates this key is a default" \
    0.0 T "-#[nodim]    key, so unless it has been" \
    0.0 T "-#[nodim]    changed, it should be possible" \
    0.0 T "-#[nodim]    to use with <prefix> directly." \
    0.0 S \
    0.0 T "-#[nodim]Shortcut keys are usually upper case" \
    0.0 T "-#[nodim]for menus, and lower case for actions." \
    0.0 T "-#[nodim]Exit menus with ESC or q"

req_win_width=43
req_win_height=15

menu_parse "$@"
