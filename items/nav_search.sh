#!/bin/sh
#
#   Copyright (c) 2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Navigate & Search
#

static_content() {
    choose_tree_cmd="choose-tree"
    if tmux_vers_check 2.7; then
        #  zooms the pane
        choose_tree_cmd="$choose_tree_cmd -Z"
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
    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 S \
        1.8 C n "Navigate & select ses/win/pane" "$choose_tree_cmd" \
	0.0 S \
        1.8 T "-#[nodim]Search in all $fw_span" \
        1.8 C s "$fw_lbl_line2" "$fw_cmd" \
        0.0 S \
        0.0 M H 'Help -->' "$d_items/help.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"
menu_name="Navigate & Search"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
