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

rename="command-prompt -I '#S' 'rename-session -- \"%%\"'"
new_ses="command-prompt -p 'Name of new session: ' 'new-session -s \"%%\"'"

a="confirm-before -p 'Are you sure you want to kill this session? (y/n)' 'set -s detach-on-destroy"
if tmux_vers_compare 3.2; then
    # added param for compatible versions
    a="$a no-detached"
fi
kill_current="$a ; kill-session'"

kill_other="confirm-before -p 'Are you sure you want to kill all other sessions? (y/n)' 'kill-session -a'"

menu_name="Handling Sessions"

#  shellcheck disable=SC2154
set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 S \
    1.7 C "\$" "<P> Rename this session" "$rename" \
    1.7 C n "    New session" "$new_ses" \
    0.0 S \
    1.7 C L "<P> Last selected session" "switch-client -l $menu_reload" \
    1.7 C "\(" "<P> Previous session (in order)" "switch-client -p $menu_reload" \
    1.7 C "\)" "<P> Next     session (in order)" "switch-client -n $menu_reload" \
    0.0 S \
    1.8 C x "Kill current session" "$kill_current" \
    1.7 C o "Kill all other sessions" "$kill_other" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=39
req_win_height=15

parse_menu "$@"
