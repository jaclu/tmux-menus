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
    # marking a pane is an ancient feature, but pane_marked came at 3.0
    tmux_vers_check 3.0 || return

    $all_helpers_sourced || source_all_helpers "pane_move:dynamic_content()"

    tmux_error_handler_assign other_pane_marked display-message \
        -p '#{&&:#{pane_marked_set},#{!=:#{pane_marked},1}}'

    # SC2154: variable assigned dynamically by tmux_error_handler_assign using eval
    # shellcheck disable=SC2154
    if [ "$other_pane_marked" = 1 ]; then
        set -- \
            3.0 C s "Swap current pane with marked" "swap-pane $runshell_reload_mnu"
    else
        set -- # clear params
    fi

    # Needs to be generated even if empty, in order to clear this item if it had
    # content last time this menu was displayed
    menu_generate_part 4 "$@"
}

static_content() {
    set -- \
        0.0 M Left "Back to Handling Pane  $nav_prev" panes.sh \
        0.0 M Home "Back to Main menu      $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    #
    # In principle, if this was moved into segment 1 there would be one less
    # cache part to handle, so would be more efficient. However this minuscule speed
    # gain would cause the command toggle to be displayed outside the first menu segment
    # and thus create an inconsistent look. So in practical terms its just not
    # worth it. But I do agree that it looks pretty silly to have a separate
    # cache file that only contains: ""
    #
    set -- \
        0.0 S \
        0.0 C p "swap pane with Prev" "swap-pane -U $runshell_reload_mnu" \
        0.0 C n "swap pane with Next" "swap-pane -D $runshell_reload_mnu"
    menu_generate_part 3 "$@"

    set -- \
        0.0 S \
        2.4 E b "Break pane off to a new window" "$d_scripts/break_pane.sh ; $0" \
        1.8 E m "Move to other win/ses" "$d_scripts/act_choose_tree.sh p m"

    tmux_vers_check 1.8 && {
        # Limit to same vers as act_choose-tree.sh, even if this is not vers dependent.
        # Showing help about a disabled feature would be confusing
        $cfg_use_hint_overlays && $cfg_show_key_hints && {
            set -- "$@" \
                0.0 M K "Key hints - Move to other $nav_next" \
                "$d_hints/choose-tree.sh $0"
        }
        set -- "$@" \
            0.0 S \
            0.0 M H "Help, Move to other    $nav_next" \
            "$d_help/help_pane_move.sh $0"
    }
    menu_generate_part 5 "$@"
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
