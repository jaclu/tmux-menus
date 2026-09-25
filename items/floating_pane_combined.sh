#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling floating panes
#

dynamic_content() {
    # Could have been in floating_pane_helpers.sh, but left it here
    # to make it obvious this menu has dynamic_content
    menu_section_dynamic combined
}

static_content() {
    menu_section_base combined
    #
    # This can be cached statically, greatly improving responsiveness.
    # Item 8 depends on item 7, so when there are no floating panes and
    # item 7 is omitted, item 8 and on are skipped automatically.
    # Thus can be cached statically for added performance
    #
    menu_section_move 8
    menu_section_resize 9
    menu_section_placement 10
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Floating Panes (C)"
menu_min_vers=3.7

no_auto_menu_handling=1

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/floating_pane_helpers.sh
floating_pane_focus

[ "$menu_handling_sourced" != 1 ] && {
    # Only source if not done
    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
}

# If caching is disabled, play it safe and always use split menus, since it can't be toggled
if [ -f "$f_max_25_line_menus" ]; then # Use split menus if hint is found
    # Switch to the not as tall split menus, fitting inside 25 rows
    "$TMUX_MENUS_LOCATION"/items/floating_pane.sh
    exit 0
fi

do_menu_handling
