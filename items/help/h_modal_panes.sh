#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help for modal panes
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous  $nav_prev" "$prev_menu" \
        0.0 M Home "Main Menu         $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "Modal panes are floating panes (tmux 3.8+) that prevent interaction with" \
        0.0 T "other panes while active. They are useful for:" \
        0.0 T "" \
        0.0 T "• Creating modal editors for editing files or config" \
        0.0 T "• Creating dialog boxes that require user attention" \
        0.0 T "• Running commands in an isolated modal context" \
        0.0 T "" \
        0.0 T "Modal Pane Options:" \
        0.0 T "" \
        0.0 T "Modal editor    - Creates a modal in current directory" \
        0.0 T "Modal dialog    - Closes when clicked outside" \
        0.0 T "Modal (all keys)- Passes all keys including prefix" \
        0.0 T "Modal (custom)  - Creates modal with custom command" \
        0.0 T "Set title       - Sets the modal pane title" \
        0.0 T "" \
        0.0 T "Note: Only one modal pane can be active at a time."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Modal Panes - Help"

prev_menu="$1"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
