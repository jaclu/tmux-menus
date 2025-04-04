#!/bin/sh
#
#   Copyright (c) 2025-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Navigate & Search
#

static_content() {
    choose_tree="choose-tree"
    if tmux_vers_check 2.7; then
        #  zooms the pane
        choose_tree="$choose_tree -Z"
    fi

    navigate_cmd="$TMUX_BIN $choose_tree"
    if $cfg_use_hint_overlays && ! $cfg_use_whiptail; then
        # The help overlay can't be displayed using whiptail
        navigate_cmd="$navigate_cmd & $d_hints/choose-tree.sh skip-oversized"
    fi

    fw_span="Windows"
    tmux_vers_check 2.6 && fw_span="Sessions & $fw_span"
    fw_lbl_line2="Ignores history"
    if tmux_vers_check 3.2; then
        #  adds ignore case, and zooms the pane
        fw_lbl_line2="$fw_lbl_line2, case insensitive"
        fw_flags="-Zi"
    elif tmux_vers_check 2.9; then
        #  zooms the pane
        fw_flags="-Z"
    else
        fw_flags=""
    fi
    fw_cmd="command-prompt -p 'Search for:' 'find-window $fw_flags %%'"

    set -- \
        0.0 M Left "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        1.7 E n "Navigate & select ses/win/pane" "$navigate_cmd"

    $cfg_use_hint_overlays && $cfg_show_key_hints && {
        set -- "$@" \
            1.7 M K "Key hints - Navigate & select  $nav_next" \
            "$d_hints/choose-tree.sh $0"
    }

    set -- "$@" \
        1.8 S \
        1.8 T "-#[nodim]Search in all $fw_span" \
        1.8 C s "$fw_lbl_line2" "$fw_cmd"
    menu_generate_part 3 "$@"

    # set -- \
    #     0.0 C 1 "doing: split-window" "split-window -h" \
    #     0.0 C 2 "doing: list-buffers" list-buffers \
    #     0.0 C 3 "doing: split-window" split-window \
    #     0.0 C 3 "doing: command-prompt -I " 'command-prompt -I "#S" { rename-session "%%" }' \
    #     0.0 C 4 "doing: split-window -h" "split-window -h" \
    #     0.0 C 5 "doing: command-prompt -T window-target" "command-prompt -T window-target" \
    #     0.0 C 6 "doing: last-pane" last-pane \
    #     0.0 C 7 "doing: swap-pane -U" "swap-pane -U" \
    #     0.0 C 8 "doing: swap-pane -D" "swap-pane -D" \
    #     0.0 C 9 "doing: show-messages" show-messages
    # menu_generate_part 4 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Navigate - Search"
menu_min_vers=1.8

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
