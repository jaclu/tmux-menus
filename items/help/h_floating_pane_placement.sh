#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about floating_pane_placement menu
#
#

static_content() {
    help_section_base
    help_section_placement 2
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help, Floating Pane - Placement"

[ -n "$1" ] && prev_menu="$(realpath "$1")"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/helpers_floating_pane.sh

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
