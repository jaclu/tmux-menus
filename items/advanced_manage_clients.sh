#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Modify Clients
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Client Management"

#  shellcheck disable=SC2154
set -- \
    2.7 M Home "Back to Main menu         <==" main.sh \
    2.7 M Left "Back to Advanced options  <--" advanced.sh \
    2.7 T "-#[align=centre,nodim]-----------   Commands   -----------" \
    2.7 T "-#[nodim]Enter Choose selected client" \
    2.7 T "-#[nodim]Up    Select previous client" \
    2.7 T "-#[nodim]Down  Select next client" \
    2.7 T "-#[nodim]C-s   Search by name" \
    2.7 T "-#[nodim]n     Repeat last search" \
    2.7 T "-#[nodim]t     Toggle if client is tagged" \
    2.7 T "-#[nodim]T     Tag no clients". \
    2.7 T "-#[nodim]C-t   Tag all clients" \
    2.7 T "-#[nodim]d     Detach selected client" \
    2.7 T "-#[nodim]D     Detach tagged clients" \
    2.7 T "-#[nodim]x     Detach and HUP selected client" \
    2.7 T "-#[nodim]X     Detach and HUP tagged clients" \
    2.7 T "-#[nodim]z     Suspend selected client" \
    2.7 T "-#[nodim]Z     Suspend tagged clients" \
    2.7 T "-#[nodim]f     Enter a format to filter items" \
    2.7 T "-#[nodim]O     Change sort field" \
    2.7 T "-#[nodim]r     Reverse sort order" \
    2.7 T "-#[nodim]v     Toggle preview" \
    2.7 T "-#[nodim]q     Exit mode" \
    2.7 T "-#[nodim] " \
    2.7 C D "<P>" "choose-client -Z" \
    2.7 S \
    2.7 M H "Help  -->" "$SCRIPT_DIR/help.sh $current_script'"

req_win_width=41
req_win_height=28

menu_parse "$@"
