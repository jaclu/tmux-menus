#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling modal panes (3.8+)
#

static_content() {
    set -- \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 M H "Help              $nav_next" \
        "$d_help/h_modal_panes.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    rsrm="$runshell_sleep_reload_mnu"
    set -- \
        0.0 S \
        3.8 C e "Modal editor" "new-pane -O -c \"#{pane_current_path}\" $rsrm" \
        3.8 C d "Modal dialog (close on click)" \
        "new-pane -O -C -c \"#{pane_current_path}\" $rsrm" \
        3.8 C a "Modal (pass all keys)" \
        "new-pane -O -K -c \"#{pane_current_path}\" $rsrm" \
        3.8 C c "Modal (custom command)" \
        "command-prompt -p 'Command: ' 'new-pane -O %%' $rsrm" \
        0.0 S \
        3.8 C t "Set title" \
        "command-prompt -I 'Modal' -p 'Title: ' 'new-pane -O -T \"%%\" $rsrm'" \
        0.0 S \
        1.8 C x "${cfg_danger_zone}Kill current" "confirm-before -p \
            'kill-pane #T (#P)? (y/n)' kill-pane $rsrm"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Modal Panes"
menu_min_vers=3.8

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
