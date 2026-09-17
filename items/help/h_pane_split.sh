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
        0.0 T "'Floating pane' - Creates a floating pane," \
        0.0 T "after unzooming the current pane," \
        0.0 T "if it was zoomed." \
        3.8 T "(the default behaviour)." \
        3.8 S \
        3.8 T "'Float (keep zoomed)' - If created above" \
        3.8 T " a zoomed pane, it remains zoomed."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help, Split Pane"
menu_min_vers=3.7

prev_menu="$1"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
