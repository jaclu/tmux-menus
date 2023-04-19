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
    2.7 T "#[align=centre,nodim]-----------   Commands   -----------" \
    2.7 T "Enter Choose selected client" \
    2.7 T "Up    Select previous client" \
    2.7 T "Down  Select next client" \
    2.7 T "C-s   Search by name" \
    2.7 T "n     Repeat last search" \
    2.7 T "t     Toggle if client is tagged" \
    2.7 T "T     Tag no clients". \
    2.7 T "C-t   Tag all clients" \
    2.7 T "d     Detach selected client" \
    2.7 T "D     Detach tagged clients" \
    2.7 T "x     Detach and HUP selected client" \
    2.7 T "X     Detach and HUP tagged clients" \
    2.7 T "z     Suspend selected client" \
    2.7 T "Z     Suspend tagged clients" \
    2.7 T "f     Enter a format to filter items" \
    2.7 T "O     Change sort field" \
    2.7 T "r     Reverse sort order" \
    2.7 T "v     Toggle preview" \
    2.7 T "q     Exit mode" \
    2.7 T " " \
    2.7 C D "<P>" "choose-client -Z" \
    2.7 S \
    2.7 M H "Help  -->" "$SCRIPT_DIR/help.sh $current_script'"

req_win_width=41
req_win_height=28

menu_parse "$@"
