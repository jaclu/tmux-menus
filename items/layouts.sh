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

static_content() {
    menu_name="Layouts"
    req_win_width=32
    req_win_height=12

    # make it global so it changes all windows in all sessions
    setw_cmd="setw -g"

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
        3.2 C "h" "heavy" "$setw_cmd  pane-border-lines  heavy   $menu_reload" \
        3.2 C "S" "simple" "$setw_cmd pane-border-lines  simple  $menu_reload" \
        3.2 C "n" "number" "$setw_cmd pane-border-lines  number  $menu_reload" \
        0.0 S \
        0.0 M H "Help -->" "$D_TM_ITEMS/help.sh $current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

#  Source dialog handling script
# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
