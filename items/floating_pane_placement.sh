#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Place floating pane to pre-determined locations of window
#
#   Placement keys (q,w,e,a,s,d,z,x,c) centered on s, left-hand keyboard cluster.
#   Avoids numpad 5-centered logic which fails for keyboards without numpad.
#

# 1,3,4 menu_section_base
#   1 - move back
#   3 - Display Commands
#   4 - New floating pane
# 2,5 menu_section_help_nav
#   2 - help displayed if current pane is floating, otherwise dummy
#   5 - nav displayed if more than one floating pane, prevents rest if no floating
# 6   menu_section_placement
# 7   menu_section_kill
#
dynamic_content() {
    # Could have been in helpers_floating_pane.sh, but left it here
    # to make it obvious this menu has dynamic_content
    menu_section_help_nav
}

static_content() {
    menu_section_base
    menu_section_placement 8
    menu_section_kill 9
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
. "$TMUX_MENUS_LOCATION"/scripts/helpers_floating_pane.sh
floating_pane_focus

if [ "$current_pane_is_floating" = 1 ]; then
    do_menu_handling
else
    # Jump back to floating pane overview menu, it can handle the case of no
    # visible floating panes
    "$TMUX_MENUS_LOCATION"/items/floating_pane.sh
fi
