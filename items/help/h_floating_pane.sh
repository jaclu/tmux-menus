#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about floating_pane menu
#
#   For basic move & resize use this diamond, lower-case move, upper-case resize
#
#       T
#      F G
#       V
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "-#[nodim]Movement diamond: " \
        0.0 T "-#[nodim]        T(up)" \
        0.0 T "-#[nodim]F(left)         G(right) " \
        0.0 T "-#[nodim]        V(down)" \
        0.0 T "-" \
        0.0 T "-#[nodim]Use lowercase to move" \
        0.0 T "-#[nodim]Use uppercase to resize"
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
