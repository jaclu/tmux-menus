#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Main menu, the one popping up when you hit the trigger
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Main menu"

set -- \
    0.0 M P "Handling Pane     -->" panes.sh \
    0.0 M W "Handling Window   -->" windows.sh \
    0.0 M S "Handling Sessions -->" sessions.sh \
    0.0 M L "Layouts           -->" layouts.sh \
    0.0 M V "Split view        -->" split_view.sh \
    1.0 M E "Extras            -->" extras.sh \
    0.0 M A "Advanced Options  -->" advanced.sh \
    0.0 S \
    0.0 C l "toggle status Line" "set status" \
    0.0 E i "public IP" "$SCRIPT_DIR/public_ip.sh" \
    0.0 E p "Plugins inventory" "$SCRIPT_DIR/plugins.sh" \
    0.0 S \
    1.6 C n 'Navigate & select ses/win/pane' 'choose-tree -Z' \
    1.6 T 'Search in all sessions & windows' \
    1.6 C s ' ignores case, only visible part' \
    "command-prompt -p 'Search for:' 'find-window -CNTiZ -- \"%%\"'" \
    0.0 S \
    0.0 E r '    Reload configuration file' "$SCRIPT_DIR/reload_conf.sh" \
    0.0 S \
    1.6 C d '<P> Detach from tmux' detach-client \
    0.0 S \
    0.0 M H 'Help       -->' "$CURRENT_DIR/help.sh $current_script"

# tmux 3.2+ crops text to make dialogs fit in tighter spaces
req_win_width=40
req_win_height=22

parse_menu "$@"
