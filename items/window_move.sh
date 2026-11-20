#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Move Window
#

dynamic_content() {

    ${b_all_helpers_sourced:-false} || source_all_helpers "window_move:dynamic_content()"

    if tmux_vers_check 3.0; then
        follow_win="-d"
    else
        # The man page suggests -d should be used for this, regardless of version,
        # but pre-3.0 tmux produces the desired result only when -d is omitted.
        follow_win=""
    fi
    tmux_error_handler_assign this_win_id display-message -p '#W'
    # shellcheck disable=SC2154# this_win_id defined by tmux_error_handler_assign
    set -- \
        0.0 S \
        0.0 C p "Move window Left" "swap-window $follow_win -s $this_win_id -t :- \
                $runshell_mnu_reload" \
        0.0 C n "Move window Right" "swap-window $follow_win -s $this_win_id -t :+ \
                $runshell_mnu_reload"
    # marking a pane is an ancient feature, but pane_marked came at 3.0
    tmux_vers_check 3.0 && {
        tmux_error_handler_assign pane_marked_status \
            list-panes -a -F '#{pane_marked} #W'
        # shellcheck disable=SC2154# pane_marked_status defined by tmux_error_handler_assign
        s_found="$(echo "$pane_marked_status" | grep '1 ' | grep -v "$this_win_id")"
        [ -n "$s_found" ] && {
            set -- "$@" \
                3.0 T "Swap current window with window" \
                3.0 C s " containing marked pane" swap-window
        }
    }
    menu_generate_part 3 "$@"
}

static_content() {
    set -- \
        0.0 M Left "Back to Previous  $nav_prev" windows.sh \
        0.0 M Home "Main Menu         $nav_home" "$cfg_main_menu" \
        0.0 M H "Help,  Move/Link  $nav_next" "$cfg_d_menus/help/h_window_move.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2 # give this its own menu part idx

    tmux_vers_check 1.8 && {
        set -- \
            1.8 S \
            1.8 T "Move before selected window" \
            1.8 E m "  (including in other sessions)" \
            "$d_scripts/act_choose_tree.sh w m" \
            1.8 S \
            1.8 E l "Link to other session" "$d_scripts/act_choose_tree.sh w l"

        # Limit to same vers as act_choose-tree.sh, even if this is not vers dependent.
        # Showing help about a disabled feature would be confusing

        ${cfg_use_hint_overlays:-false} && ${cfg_show_key_hints:-false} && {
            set -- "$@" \
                0.0 M K "Key hints - Move/Link      $nav_next" "$d_hints/choose-tree.sh $0"
        }
        set -- "$@" \
            1.8 C u "${cfg_danger_zone}Unlink from current session" "unlink-window"
    }
    menu_generate_part 4 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Move Window"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
