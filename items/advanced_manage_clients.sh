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
    0.0 M Home "Back to Main menu         <==" main.sh \
    0.0 M Left "Back to Advanced options  <--" advanced.sh \
    0.0 T "-#[align=centre,nodim]-----------   Commands   -----------" \
    0.0 T "-Enter Choose selected client" \
    0.0 T "-Up    Select previous client" \
    0.0 T "-Down  Select next client" \
    0.0 T "-C-s   Search by name" \
    0.0 T "-n     Repeat last search" \
    0.0 T "-t     Toggle if client is tagged" \
    0.0 T "-T     Tag no clients". \
    0.0 T "-C-t   Tag all clients" \
    0.0 T "-d     Detach selected client" \
    0.0 T "-D     Detach tagged clients" \
    0.0 T "-x     Detach and HUP selected client" \
    0.0 T "-X     Detach and HUP tagged clients" \
    0.0 T "-z     Suspend selected client" \
    0.0 T "-Z     Suspend tagged clients" \
    0.0 T "-f     Enter a format to filter items" \
    0.0 T "-O     Change sort field" \
    0.0 T "-r     Reverse sort order" \
    0.0 T "-v     Toggle preview" \
    0.0 T "-q     Exit mode" \
    0.0 T "-" \
    0.0 C D "<P>" "choose-client -Z" \
    0.0 S \
    0.0 M H "Help  -->" "$SCRIPT_DIR/help.sh $current_script'"

req_win_width=41
req_win_height=28

parse_menu "$@"
