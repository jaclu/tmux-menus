#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Move Window
#

dynamic_content() {
    # Things that change dependent on various states

    other_pane_is_marked="$(tmux_error_handler display -p '#{?pane_marked_set,yes,}')"

    if [ -n "$other_pane_is_marked" ]; then
        set -- \
            0.0 T "-#[nodim]Swap current window with window" \
            0.0 C s " containing marked pane" swap-window
    fi

    menu_generate_part 2 "$@"
}

static_content() {
    choose_tree="choose-tree"
    if tmux_vers_check 2.7; then
        choose_tree="$choose_tree -GwZ"
    fi
    select_location="$choose_tree 'run-shell \"$d_scripts/relocate_window.sh"

    set -- \
        0.0 M Left "Back to Handling Window $nav_prev" windows.sh \
        0.0 M Home "Back to Main menu       $nav_home" main.sh \
        0.0 S

    menu_generate_part 1 "$@"

    set -- \
        1.7 C m "Move window to other location" "$select_location W M %%\"'" \
        0.0 C "\<" "Swap window Left" "swap-window -dt:-1 $menu_reload" \
        0.0 C "\>" "Swap window Right" "swap-window -dt:+1 $menu_reload" \
        0.0 S \
        1.7 C l "Link window to other session" "$select_location W L %%\"'" \
        0.0 C u "Unlink window from this session" "unlink-window" \
        1.7 S \
        1.7 M K "Key hints - move/link      $nav_next" "$d_hints/choose-tree.sh $f_current_script" \
        1.7 M H "Help, explaining move/link $nav_next" "$d_help/help_window_move.sh $f_current_script"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Move Window"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
