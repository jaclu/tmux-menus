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

prev_menu="$1"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/floating_pane_helpers.sh

do_menu_handling
