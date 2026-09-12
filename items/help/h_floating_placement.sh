#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about floating_placement menu
#
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "The placement keys form a 3x3 grid" \
        0.0 T "that mirrors the window:" \
        0.0 T "" \
        0.0 T "          q   w   e" \
        0.0 T "          a   s   d" \
        0.0 T "          z   x   c" \
        0.0 T "" \
        0.0 T "Key position = pane position," \
        0.0 T "with s placing it in the centre."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help, Floating Pane - Placement"

[ -n "$1" ] && prev_menu="$(realpath "$1")"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/../.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
