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

    current_sync_state=$($TMUX_BIN show-options -wv synchronize-panes)
    if [ "$current_sync_state" = "on" ]; then
        sync_state_change="Disable"
    else
        # current_sync_state is "" before first toggle in current window
        sync_state_change="Activate"
    fi
    set -- \
        1.5 S \
        1.5 T "$sync_state_change synchronization" \
        1.5 C s "of all panes on this window" "set-option -w synchronize-panes \
                $runshell_mnu_reload"

    # only latter mthd works as per 261120
    # tmux_error_handler_assign _p_disabled display-message -p '#{pane_input_off}'
    _p_disabled=$($TMUX_BIN display -p '#{pane_input_off}')

    # shellcheck disable=SC2154 # p_disabled assigned by tmux_error_handler_assign
    if [ "$_p_disabled" = 0 ]; then
        input_lbl="disable"
        input_toggle="-d"
    else
        input_lbl="enable"
        input_toggle="-e"
    fi
    set -- "$@" \
        2.0 S \
        2.0 C i "Input $input_lbl" "select-pane $input_toggle $runshell_mnu_reload"
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
        1.8 C z "Zoom" "resize-pane -Z $runshell_mnu_reload" \
        2.1 C m "Mark" "select-pane -m $runshell_mnu_reload"
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
