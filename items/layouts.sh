#!/bin/sh
#  shellcheck disable=SC2034
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

ITEMS_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

#
# Odd, initially setw -g failed on my macbook, but now it seems
# to work, probably due to pushing this change ? :)
#
#if [ "$(uname)" = "Linux" ]; then
    setw_cmd="setw -g"
#else
#    setw_cmd="setw"
#fi
#echo "><> setwcmd [$setw_cmd]"

menu_name="Layouts"

#  shellcheck disable=SC2154
set -- \
    0.0 M Left "Back to Main menu <--" main.sh \
    0.0 S \
    0.0 C M-1 "<P> Even horizontal" "select-layout even-horizontal $menu_reload" \
    0.0 C M-2 "<P> Even vertical" "select-layout even-vertical   $menu_reload" \
    0.0 C M-3 "<P> Main horizontal" "select-layout main-horizontal $menu_reload" \
    0.0 C M-4 "<P> Main vertical" "select-layout main-vertical   $menu_reload" \
    0.0 C M-5 "<P> Tiled" "select-layout tiled           $menu_reload" \
    0.0 C E "<P> Spread evenly" "select-layout -E  $menu_reload" \
    3.2 S \
    3.2 T "-#[align=centre,nodim]Border lines" \
    3.2 C "s" "single" "$setw_cmd pane-border-lines  single  $menu_reload" \
    3.2 C "d" "double" "$setw_cmd pane-border-lines  double  $menu_reload" \
    3.2 C "h" "heavy" "$setw_cmd pane-border-lines  heavy   $menu_reload" \
    3.2 C "S" "simple" "$setw_cmd pane-border-lines  simple  $menu_reload" \
    3.2 C "n" "number" "$setw_cmd pane-border-lines  number  $menu_reload" \
    0.0 S \
    0.0 M H "Help -->" "$ITEMS_DIR/help.sh $current_script"

req_win_width=32
req_win_height=12

menu_parse "$@"
