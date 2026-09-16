#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling floating pane
#
#   Move / resize panes with this diamond:
#
#        t
#      f   g
#        v
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
# 8   menu_section_kill
#

dynamic_content() {
    # Could have been in helpers_floating_pane.sh, but left it here
    # to make it obvious this menu has dynamic_content
    menu_section_help_nav
}

static_content() {
    # shorter variablenames to avoid too long lines
    _vert_step="$cfg_floating_pane_incr_vertical"
    _hori_step="$cfg_floating_pane_incr_horizontal"
    _rrm="$runshell_reload_mnu"

    menu_section_base split

    menu_section_move 6
    menu_section_resize 7
    menu_section_kill 8
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Floating Panes"
menu_min_vers=3.7

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/helpers_floating_pane.sh
floating_pane_focus

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
