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
            0.0 T "Press Esc or q to close this help overlay"
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
        0.0 T "-#[nodim]Enter  Paste selected buffer" \
        0.0 T "-#[nodim]Up     Select previous buffer" \
        0.0 T "-#[nodim]Down   Select next buffer" \
        2.6 T "-#[nodim]C-s    Search by name or content" \
        2.6 T "-#[nodim]n      Repeat last search forwards" \
        3.5 T "-#[nodim]N      Repeat last search backwards" \
        2.6 T "-#[nodim]t      Toggle if buffer is tagged" \
        2.6 T "-#[nodim]T      Tag no buffers" \
        2.6 T "-#[nodim]C-t    Tag all buffers" \
        2.7 T "-#[nodim]p      Paste selected buffer" \
        2.7 T "-#[nodim]P      Paste tagged buffers" \
        2.6 T "-#[nodim]d      Delete selected buffer" \
        2.6 T "-#[nodim]D      Delete tagged buffers" \
        3.2 T "-#[nodim]e      Open the buffer in an editor" \
        2.6 T "-#[nodim]f      Enter a format to filter items" \
        2.6 T "-#[nodim]O      $o_lbl" \
        3.1 T "-#[nodim]r      Reverse sort order" \
        2.6 T "-#[nodim]v      Toggle preview" \
        0.0 T "-#[nodim]Esc/q  Exit mode"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Keys for choose-buffer"

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
window_height=20
tmux_vers_check "3.1" && window_height=$((window_height + 1))
tmux_vers_check "3.2" && window_height=$((window_height + 1))
tmux_vers_check "3.5" && window_height=$((window_height + 1))
[ -n "$prev_menu" ] && window_height=$((window_height + 1))

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
