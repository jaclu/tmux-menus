#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about splitting the view
#

dynamic_content() {
    # Things that change dependent on various states

    if [ -n "$prev_menu" ]; then
        set -- \
            0.0 M Left "Back to Previous  $nav_prev" "$prev_menu" \
            0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu"
    else
        set -- \
            0.0 T "Press Esc or q to close this keyboard hint overlay"
    fi
    menu_generate_part 1 "$@"
}

static_content() {
    if tmux_vers_check "3.1"; then
        # Description was changed
        o_lbl="Change sort field"
    else
        o_lbl="Change sort order"
    fi

    set -- \
        0.0 S \
        0.0 T "Enter  Choose selected client" \
        0.0 T "Up     Select previous client" \
        0.0 T "Down   Select next client" \
        0.0 T "C-s    Search by name" \
        0.0 T "n      Repeat last search forwards" \
        3.5 T "N      Repeat last search backwards" \
        0.0 T "t      Toggle if client is tagged" \
        0.0 T "T      Tag no clients" \
        0.0 T "C-t    Tag all clients" \
        0.0 T "d      Detach selected client" \
        0.0 T "D      Detach tagged clients" \
        0.0 T "x      Detach and HUP selected client" \
        0.0 T "X      Detach and HUP tagged clients" \
        0.0 T "z      Suspend selected client" \
        0.0 T "Z      Suspend tagged clients" \
        0.0 T "f      Enter a format to filter items" \
        0.0 T "O      $o_lbl" \
        3.1 T "r      Reverse sort order" \
        0.0 T "v      Toggle preview" \
        0.0 T "Esc/q  Exit mode"
    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Keys for choose-client"

if [ -n "$1" ]; then
    prev_menu="$(realpath "$1")"
fi

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/../.." && pwd)

no_auto_menu_handling=1 # delay processing of dialog, only source it for now

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh

# manually trigger dialog handling
do_menu_handling
