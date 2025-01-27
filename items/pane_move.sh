#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Move a pane
#

dynamic_content() {
    # clear params content
    set --
    tmux_vers_check 3.0 && {
        # marking a pane is an ancient feature, but pane_marked came at 3.0
        $TMUX_BIN display-message -p '#{&&:#{pane_marked_set},#{!=:#{pane_marked},1}}' | grep -q 1 && {
            set -- \
                3.0 C m "Swap current pane with marked" "swap-pane $menu_reload"
        }
    }
    menu_generate_part 2 "$@"
}

static_content() {
    menu_segment=1

    set -- \
        0.0 M Left "Back to Handling Pane $nav_prev" panes.sh \
        0.0 M Home "Back to Main menu     $nav_home" main.sh \
        1.7 S

    menu_generate_part "$menu_segment" "$@"
    menu_segment=$((menu_segment + 2)) # increment past dynamic segment

    set -- \
        1.7 C p "Swap pane with prev" "swap-pane -U $menu_reload" \
        1.7 C n "Swap pane with next" "swap-pane -D $menu_reload" \
        1.7 E o "Move to other win/ses" "$d_scripts/act_choose_tree.sh P M" \
        0.0 S \
        2.4 E w "Break pane to a new window" "$d_scripts/break_pane.sh" \
        1.7 S

    menu_generate_part "$menu_segment" "$@"
    menu_segment=$((menu_segment + 1))

    $cfg_show_key_hints && {
        set -- \
            1.7 M O "Key hints - Move to other $nav_next" \
            "$d_hints/choose-tree.sh $f_current_script"

        menu_generate_part "$menu_segment" "$@"
        menu_segment=$((menu_segment + 1))
    }

    set -- \
        1.7 M H "Help, explaining move     $nav_next" \
        "$d_help/help_pane_move.sh $f_current_script"

    menu_generate_part "$menu_segment" "$@"
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
