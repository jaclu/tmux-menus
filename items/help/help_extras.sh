#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "-#[nodim]Extras are menus manipulating" \
        0.0 T "-#[nodim]other software." \
        0.0 T "-#[nodim]If a specific app is not found," \
        0.0 T "-#[nodim]that entry is grayed out."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -n "$1" ] && prev_menu="$(realpath "$1")"
menu_name="Help Extras"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/../.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
