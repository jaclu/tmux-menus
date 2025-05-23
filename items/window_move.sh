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
    # marking a pane is an ancient feature, but pane_marked came at 3.0
    tmux_vers_check 3.0 || return

    $all_helpers_sourced || source_all_helpers "window_move:dynamic_content()"

    tmux_error_handler_assign this_win_id display-message -p '#{window_id}'
    tmux_error_handler_assign pane_marked_status list-panes -a \
        -F '#{pane_marked} #{window_id}'
    # SC2154: variables assigned dynamically by tmux_error_handler_assign using eval
    # shellcheck disable=SC2154
    s_found="$(echo "$pane_marked_status" | grep '1 ' | grep -v "$this_win_id")"
    if [ -n "$s_found" ]; then
        set -- \
            3.0 T "-#[nodim]Swap current window with window" \
            3.0 C s " containing marked pane" swap-window
    else
        set --
    fi
    menu_generate_part 4 "$@"
}

static_content() {
    set -- \
        0.0 M Left "Back to Handling Window  $nav_prev" windows.sh \
        0.0 M Home "Back to Main menu        $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2 # give this its own menu part idx

    set -- \
        0.0 S
    menu_generate_part 3 "$@"

    set -- \
        0.0 C "\<" "Swap window Left" "swap-window -d -t :-1 $runshell_reload_mnu" \
        0.0 C "\>" "Swap window Right" "swap-window -d -t :+1 $runshell_reload_mnu" \
        0.0 S \
        1.7 E m "Move window to other location" "$d_scripts/act_choose_tree.sh w m" \
        1.7 E l "Link window to other session" "$d_scripts/act_choose_tree.sh w l"

    $cfg_use_hint_overlays && $cfg_show_key_hints && {
        set -- "$@" \
            1.7 M K "Key hints - Move/Link      $nav_next" "$d_hints/choose-tree.sh $0"
    }

    set -- "$@" \
        0.0 C u "Unlink window from this session" "unlink-window" \
        1.7 S \
        1.7 M H "Help, explaining Move/Link $nav_next" "$d_help/help_window_move.sh $0"

    menu_generate_part 5 "$@"
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
