#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about combined floating pane menu
#

static_content() {
    help_section_base
    help_section_move_resize 2
    help_section_placement 3
    help_section_be_aware 4
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help, Floating Pane (C)"

prev_menu="$1"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/helpers_floating_pane.sh

do_menu_handling
