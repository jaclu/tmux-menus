#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
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
    set -- \
        0.0 M Left "Back to Previous  $nav_prev" "$prev_menu" \
        0.0 M Home "Main Menu         $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "Extras are menus manipulating" \
        0.0 T "other software." \
        0.0 T "If a specific app is not found," \
        0.0 T "that entry is grayed out."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help Extras"

prev_menu="$1"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
