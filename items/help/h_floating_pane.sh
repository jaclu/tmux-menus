#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about floating_pane menu
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "Move / Resize - diamond pattern:" \
        0.0 T "" \
        0.0 T "           t (up)" \
        0.0 T " f (left)            g (right)" \
        0.0 T "           v (down)" \
        0.0 T "" \
        0.0 T "lowercase:  move" \
        0.0 T "UPPERCASE:  resize" \
        0.0 T "" \
        0.0 T "The menu closes and reopens on" \
        0.0 T "every key. Press one key, wait" \
        0.0 T "for it to redraw, then the next —" \
        0.0 T "anything typed in between goes" \
        0.0 T "straight into the pane."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help, Floating Pane"

[ -n "$1" ] && prev_menu="$(realpath "$1")"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/../.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
