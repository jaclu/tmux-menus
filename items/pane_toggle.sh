#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

dynamic_content() {
    tmux_error_handler_assign _p_disabled display-message -p '#{pane_input_off}'
    # _p_disabled=$($TMUX_BIN display -p '#{pane_input_off}')

    # shellcheck disable=SC2154 # p_disabled assigned by tmux_error_handler_assign
    if [ "$_p_disabled" = 0 ]; then
        marker_enable="-"
        marker_disable=""
    else
        marker_enable=""
        marker_disable="-"
        set --
    fi
    set -- \
        0.0 S \
        2.0 C e "${marker_enable}Enable input" "select-pane -e $runshell_mnu_reload" \
        2.0 C d "${marker_disable}Disable input" "select-pane -d $runshell_mnu_reload"
    menu_generate_part 4 "$@"
}

static_content() {
    set -- \
        0.0 M Left "Back to Panes    $nav_prev" panes.sh \
        0.0 M Home "Main Menu        $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S \
        1.8 C z "zoom" "resize-pane -Z $runshell_mnu_reload" \
        2.1 C m "mark" "select-pane -m $runshell_mnu_reload" \
        1.5 C s "synchronization" "set-option -w synchronize-panes \
                $runshell_mnu_reload"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Toggle Pane State"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
