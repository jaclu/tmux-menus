#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help for display settings
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous       $nav_prev" "$prev_menu" \
        0.0 M Home "Main Menu              $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "Theme Options:" \
        0.0 T "" \
        0.0 T "Auto (detect)  - Automatically detect your terminal's" \
        0.0 T "                 theme (light or dark) and apply" \
        0.0 T "                 matching colors" \
        0.0 T "" \
        0.0 T "Light theme    - Force light theme colors (good for" \
        0.0 T "                 light terminal backgrounds)" \
        0.0 T "" \
        0.0 T "Dark theme     - Force dark theme colors (good for" \
        0.0 T "                 dark terminal backgrounds)" \
        0.0 T "" \
        0.0 T "ANSI colors    - Use terminal's default colors"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Display Settings - Help"

prev_menu="$1"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
