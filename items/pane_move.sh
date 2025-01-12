#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Move a pane
#

dynamic_content() {
    # Things that change dependent on various states

    if tmux_error_handler display-message -p '#{pane_marked_set}' | grep -q '1'; then
        set -- \
            2.1 C m "Swap current pane with marked" "swap-pane $menu_reload"
    else
        set --
    fi
    menu_generate_part 2 "$@"
}

static_content() {
    choose_tree="choose-tree"
    if tmux_vers_check 2.7; then
        #  zooms the pane
        choose_tree="$choose_tree -Gw"
        # -G includes all sessions in any session groups
        # -w with windows collapsed
    fi
    select_location="$choose_tree 'run-shell \"$d_scripts/relocate_pane.sh P M %%\"'"

    set -- \
        0.0 M Left "Back to Handling Pane $nav_prev" panes.sh \
        0.0 M Home "Back to Main menu     $nav_home" main.sh \
        0.0 S \
        2.7 C o "Move to other win/ses" "$select_location"

    menu_generate_part 1 "$@"

    set -- \
        1.7 C p "Swap pane with prev" "swap-pane -U $menu_reload" \
        1.7 C n "Swap pane with next" "swap-pane -D $menu_reload" \
        0.0 S \
        2.4 E w "Break pane to a new window" "$d_scripts/break_pane.sh" \
        1.7 S \
        1.7 M O "Key hints - Move to other $nav_next" \
        "$d_items/hints/choose-tree.sh $f_current_script" \
        0.0 M H "Help, explaining move     $nav_next" \
        "$d_items/help_pane_move.sh $f_current_script"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Move Pane"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
