#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling floating pane
#

# 1,3,4 menu_section_base
#   1 - move back
#   3 - Display Commands
#   4 - New floating pane
# 2,5 menu_section_help_nav
#   2 - help displayed if current pane is floating, otherwise dummy
#   5 - nav displayed if more than one floating pane, prevents rest if no floating
# 6   menu_section_move
# 7   menu_section_resize
# 8   menu_section_placement
# 9   menu_section_kill
#

dynamic_content() {
    # Could have been in helpers_floating_pane.sh, but left it here
    # to make it obvious this menu has dynamic_content
    menu_section_help_nav
}

static_content() {
    menu_section_base combined

    #
    # This can be cached statically, greatly improving responsiveness.
    # Item 8 depends on item 7, so when there are no floating panes and
    # item 7 is omitted, item 8 and on are skipped automatically.
    #

    menu_section_move 8
    menu_section_resize 9
    menu_section_placement 10
    menu_section_kill 11
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
. "$TMUX_MENUS_LOCATION"/scripts/helpers_floating_pane.sh
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
