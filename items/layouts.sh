#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

static_content() {
    # make it global so it changes all windows in all sessions
    setw_cmd="setw -g"

    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 S \
        0.0 C 1 "Even horizontal" "select-layout even-horizontal $menu_reload" \
        0.0 C 2 "Even vertical" "select-layout even-vertical   $menu_reload" \
        0.0 C 3 "Main horizontal" "select-layout main-horizontal $menu_reload" \
        0.0 C 4 "Main vertical" "select-layout main-vertical   $menu_reload" \
        0.0 C 5 "Tiled" "select-layout tiled           $menu_reload" \
        0.0 C e "Spread evenly" "select-layout -E  $menu_reload" \
        3.2 S \
        3.2 T "-#[align=centre,nodim]Border lines" \
        3.2 C "s" "single" "$setw_cmd pane-border-lines  single  $menu_reload" \
        3.2 C "d" "double" "$setw_cmd pane-border-lines  double  $menu_reload" \
        3.2 C "h" "heavy" "$setw_cmd  pane-border-lines  heavy   $menu_reload" \
        3.2 C "S" "simple" "$setw_cmd pane-border-lines  simple  $menu_reload" \
        3.2 C "n" "number" "$setw_cmd pane-border-lines  number  $menu_reload" \
        0.0 S \
        0.0 M H "Help -->" "$d_items/help.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
