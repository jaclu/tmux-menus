#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about floating_placement menu
#
#   Use S for centered on screen, and the 8 surrounding chars for the respective
#   edges of the screen
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "-#[nodim]Use 's' for centering on the screen" \
        0.0 T "-" \
        0.0 T "-#[nodim]And the surrounding chars for the" \
        0.0 T "-#[nodim]respective edges of the screen"
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -n "$1" ] && prev_menu="$(realpath "$1")"
menu_name="Help, Floating Pane"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/../.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
