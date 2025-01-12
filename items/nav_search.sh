#!/bin/sh
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
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
    if $cfg_use_whiptail; then
        # The help overlay can't be displayed using whiptail
        navigate_cmd="$TMUX_BIN $choose_tree"
    else
        navigate_cmd="$TMUX_BIN $choose_tree & $d_hints/choose-tree.sh"
    fi

    fw_span="Windows"
    tmux_vers_check 2.6 && fw_span="Sessions & $fw_span"
    fw_lbl_line2="Only visible part"
    if tmux_vers_check 3.2; then
        #  adds ignore case, and zooms the pane
        fw_lbl_line2="$fw_lbl_line2, ignores case"
        fw_flags="-Zi"
    elif tmux_vers_check 2.9; then
        #  zooms the pane
        fw_flags="-Z"
    else
        fw_flags=""
    fi
    fw_cmd="command-prompt -p 'Search for:' 'find-window $fw_flags %%'"

    # static - 1
    # hints_nav_select.sh
    set -- \
        0.0 M Left "Back to Main menu $nav_home" main.sh \
        0.0 S \
        1.7 E n "Navigate & select ses/win/pane" "$navigate_cmd" \
        1.7 S \
        1.8 T "-#[nodim]Search in all $fw_span" \
        1.8 C s "$fw_lbl_line2" "$fw_cmd" \
        1.7 S \
        1.7 M N "Key hints - Navigate & select  $nav_next" "$d_hints/choose-tree.sh $f_current_script"

    menu_generate_part 1 "$@"
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
