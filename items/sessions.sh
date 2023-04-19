#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling Sessions
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

if ! tmux_vers_compare 2.0; then
    error_msg "This menu needs at least tmux 2.0" 1
fi

menu_name="Handling Sessions"

#  shellcheck disable=SC2154
set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 S \
    2.0 C "\$" "<P> Rename this session" "command-prompt -I '#S' \
        'rename-session -- \"%%\"'" \
    2.0 C n "    New session" "command-prompt -p \
        'Name of new session: ' \
        'new-session -d -s \"%1\" ; switch-client -t \"%1\"'" \
    0.0 S \
    2.0 C L "<P> Last selected session" "switch-client -l $menu_reload" \
    2.0 C "\(" "<P> Previous session (in order)" "switch-client -p $menu_reload" \
    2.0 C "\)" "<P> Next     session (in order)" "switch-client -n $menu_reload" \
    0.0 S \
    2.0 C x "Kill current session" "confirm-before -p \
        'Are you sure you want to kill this session? (y/n)' \
        'set -s detach-on-destroy"

if tmux_vers_compare 3.2; then
    #  added param for compatible versions
    #  shellcheck disable=SC2145
    set -- "$@ no-detached"
fi

#  shellcheck disable=SC2145,SC2154
set -- "$@ ; kill-session'" \
    2.0 C o "Kill all other sessions" "confirm-before -p \
        'Are you sure you want to kill all other sessions? (y/n)' \
        'kill-session -a'" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=39
req_win_height=15

menu_parse "$@"
