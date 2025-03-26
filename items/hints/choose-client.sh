#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
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
            0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
            0.0 M Home "Back to Main menu      $nav_home" main.sh
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
        0.0 T "-#[nodim]Enter  Choose selected client" \
        0.0 T "-#[nodim]Up     Select previous client" \
        0.0 T "-#[nodim]Down   Select next client" \
        0.0 T "-#[nodim]C-s    Search by name" \
        0.0 T "-#[nodim]n      Repeat last search forwards" \
        3.5 T "-#[nodim]N      Repeat last search backwards" \
        0.0 T "-#[nodim]t      Toggle if client is tagged" \
        0.0 T "-#[nodim]T      Tag no clients" \
        0.0 T "-#[nodim]C-t    Tag all clients" \
        0.0 T "-#[nodim]d      Detach selected client" \
        0.0 T "-#[nodim]D      Detach tagged clients" \
        0.0 T "-#[nodim]x      Detach and HUP selected client" \
        0.0 T "-#[nodim]X      Detach and HUP tagged clients" \
        0.0 T "-#[nodim]z      Suspend selected client" \
        0.0 T "-#[nodim]Z      Suspend tagged clients" \
        0.0 T "-#[nodim]f      Enter a format to filter items" \
        0.0 T "-#[nodim]O      $o_lbl" \
        3.1 T "-#[nodim]r      Reverse sort order" \
        0.0 T "-#[nodim]v      Toggle preview" \
        0.0 T "-#[nodim]Esc/q  Exit mode"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Keys for choose-client"

if [ "$1" = "skip-oversized" ]; then
    # shellcheck disable=SC2034
    skip_oversized=1
elif [ -n "$1" ]; then
    prev_menu="$(realpath "$1")"
fi

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"

# shellcheck source=scripts/helpers_minimal.sh
. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

window_width=50
window_height=22
tmux_vers_check "3.1" && window_height=$((window_height + 1))
tmux_vers_check "3.5" && window_height=$((window_height + 1))
[ -n "$prev_menu" ] && window_height=$((window_height + 1))

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
