#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Place floating panes to pre-determined locations of window
#   25x80 split menu version
#

dynamic_content() {
    # Could have been in floating_pane_helpers.sh, but left it here
    # to make it obvious this menu has dynamic_content
    menu_section_help_nav
}

static_content() {
    menu_section_base
    #
    # This can be cached statically, greatly improving responsiveness.
    # Item 9 depends on item 8, so when there are no floating panes and
    # item 8 is omitted, item 9 and on are skipped automatically.
    #
    menu_section_placement 9
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Floating Panes - Placement"
menu_min_vers=3.8

no_auto_menu_handling=1

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/floating_pane_helpers.sh
floating_pane_focus

if [ "$current_pane_is_floating" = 1 ]; then
    do_menu_handling
else
    # Jump back to floating pane overview menu, it can handle the case of no
    # visible floating panes
    "$TMUX_MENUS_LOCATION"/items/floating_pane.sh
fi
