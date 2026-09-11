#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about move and link window
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "'Float' Creates a floating pane, after unzooming" \
        0.0 T "the current pane if it was zoomed." \
        0.0 T "(the default behaviour)." \
        0.0 T "" \
        0.0 T "'Float (keep zoomed)' means that if created above" \
        0.0 T " a zoomed pane, it remains zoomed."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help, Split Pane"

[ -n "$1" ] && prev_menu="$(realpath "$1")"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/../.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
