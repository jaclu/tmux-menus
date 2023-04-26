#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Layouts"

#  shellcheck disable=SC2154
set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 S \
    0.0 C M-1 "<P> Even horizontal" "select-layout even-horizontal $menu_reload" \
    0.0 C M-2 "<P> Even vertical" "select-layout even-vertical   $menu_reload" \
    0.0 C M-3 "<P> Main horizontal" "select-layout main-horizontal $menu_reload" \
    0.0 C M-4 "<P> Main vertical" "select-layout main-vertical   $menu_reload" \
    0.0 C M-5 "<P> Tiled" "select-layout tiled           $menu_reload" \
    0.0 C E "<P> Spread evenly" "select-layout -E  $menu_reload" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=33
req_win_height=16

menu_parse "$@"
