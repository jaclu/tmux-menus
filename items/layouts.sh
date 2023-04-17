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
    0.0 T "-Most of these defaults" \
    0.0 T "-can't be used in menus." \
    0.0 T "-They are just listed" \
    0.0 T "-" \
    0.0 C 1 "#[fg=red]<P> M-1#[default] Even horizontal" "select-layout even-horizontal $menu_reload" \
    0.0 C 2 "#[fg=red]<P> M-2#[default] Even vertical" "select-layout even-vertical   $menu_reload" \
    0.0 C 3 "#[fg=red]<P> M-3#[default] Main horizontal" "select-layout main-horizontal $menu_reload" \
    0.0 C 4 "#[fg=red]<P> M-4#[default] Main vertical" "select-layout main-vertical   $menu_reload" \
    0.0 C 5 "#[fg=red]<P> M-5#[default] Tiled" "select-layout tiled           $menu_reload" \
    0.0 C E "<P> Spread evenly" "select-layout -E  $menu_reload" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=33
req_win_height=16

parse_menu "$@"
