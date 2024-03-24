#!/bin/sh
#  shellcheck disable=SC2034,SC2154
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Move Window
#

dynamic_content() {
    # Things that change dependent on various states

    other_pane_is_marked="$($TMUX_BIN display -p '#{?pane_marked_set, ,}')"

    if [ -n "$other_pane_is_marked" ]; then
        set -- \
            0.0 T "-#[nodim]Swap current window with window" \
            0.0 C s " containing marked pane" swap-window
    fi

    menu_generate_part 2 "$@"
}

static_content() {
    menu_name="Move Window"
    req_win_width=40
    req_win_height=17

    select_location="choose-tree -Gw 'run-shell \"$D_TM_SCRIPTS/relocate_window.sh"

    set -- \
        0.0 M Home "Back to Main menu       <==" main.sh \
        0.0 M Left "Back to Handling Window <--" windows.sh \
        0.0 S

    menu_generate_part 1 "$@"

    set -- \
        2.0 C m "Move window to other location" "$select_location W M %%\"'" \
        0.0 C "\<" "Swap window Left" "swap-window -dt:-1 $menu_reload" \
        0.0 C "\>" "Swap window Right" "swap-window -dt:+1 $menu_reload" \
        0.0 S \
        2.0 C l "Link window to other session" "$select_location W L %%\"'" \
        0.0 C u "Unlink window from this session" "unlink-window" \
        0.0 S \
        0.0 M H "Help, explaining move & link -->" "$D_TM_ITEMS/help_window_move.sh $current_script"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH=$(dirname "$(dirname -- "$(readlink -f -- "$0")")")

#  Generate and display the menu
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
