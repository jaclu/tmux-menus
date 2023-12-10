#!/bin/sh
#  shellcheck disable=SC2034
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Main menu, the one popping up when you hit the trigger
#

ITEMS_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Main menu"

set -- \
    0.0 M P "Handling Pane     -->" panes.sh \
    0.0 M W "Handling Window   -->" windows.sh \
    2.0 M S "Handling Sessions -->" sessions.sh \
    0.0 M L "Layouts           -->" layouts.sh \
    0.0 M V "Split view        -->" split_view.sh \
    0.0 M M "Missing Keys      -->" missing_keys.sh \
    0.0 M E "Extras            -->" extras.sh \
    0.0 M A "Advanced Options  -->" advanced.sh \
    0.0 S \
    0.0 C l "toggle status Line" "set status" \
    0.0 E i "public IP" "$SCRIPT_DIR/public_ip.sh" \
    0.0 E p "Plugins inventory" "$SCRIPT_DIR/plugins.sh" \
    0.0 S \
    0.0 C n "Navigate & select ses/win/pane" "choose-tree"

if tmux_vers_compare 2.7; then
    #  adds ignore case
    # shellcheck disable=SC2145
    set -- "$@ -Z"
fi

set -- "$@" \
    0.0 T "-#[nodim]Search in all sessions & windows" \
    0.0 C s "only visible part"

if tmux_vers_compare 3.2; then
    #  adds ignore case
    # shellcheck disable=SC2145
    set -- "$@, ignores case"
fi

set -- "$@" \
    "command-prompt -p 'Search for:' 'find-window"

if tmux_vers_compare 3.2; then
    #  adds ignore case, and zooms the pane
    # shellcheck disable=SC2145
    set -- "$@ -Zi"
fi

#  shellcheck disable=SC2145,SC2154
set -- "$@  -- \"%%\"'" \
    0.0 S \
    0.0 E r 'Reload configuration file' "$SCRIPT_DIR/reload_conf.sh" \
    0.0 S \
    0.0 C d '<P> Detach from tmux' detach-client \
    0.0 S \
    0.0 M H 'Help -->' "$ITEMS_DIR/help.sh $current_script"

req_win_width=39
req_win_height=23

menu_parse "$@"
