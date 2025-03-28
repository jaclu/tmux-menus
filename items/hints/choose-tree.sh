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
        0.0 T "-#[nodim]Enter  Choose selected item" \
        0.0 T "-#[nodim]Up     Select previous item" \
        0.0 T "-#[nodim]Down   Select next item" \
        3.2 T "-#[nodim]+      Expand selected item" \
        3.2 T "-#[nodim]-      Collapse selected item" \
        3.2 T "-#[nodim]M-+    Expand all items" \
        3.2 T "-#[nodim]M--    Collapse all items" \
        2.8 T "-#[nodim]x      Kill selected item" \
        2.8 T "-#[nodim]X      Kill tagged items" \
        2.6 T "-#[nodim]<      Scroll list of previews left" \
        2.6 T "-#[nodim]>      Scroll list of previews right" \
        2.6 T "-#[nodim]C-s    Search by name" \
        3.2 T "-#[nodim]m      Set the marked pane" \
        3.2 T "-#[nodim]M      Clear the marked pane" \
        2.6 T "-#[nodim]n      Repeat last search forwards" \
        3.5 T "-#[nodim]N      Repeat last search backwards" \
        2.6 T "-#[nodim]t      Toggle if item is tagged" \
        2.6 T "-#[nodim]T      Tag no items" \
        2.6 T "-#[nodim]C-t    Tag all items" \
        2.6 T "-#[nodim]:      Run a command for each tagged item" \
        2.6 T "-#[nodim]f      Enter a format to filter items" \
        3.2 T "-#[nodim]H      Jump to the starting pane" \
        2.6 T "-#[nodim]O      $o_lbl" \
        3.1 T "-#[nodim]r      Reverse sort order" \
        2.6 T "-#[nodim]v      Toggle preview" \
        0.0 T "-#[nodim]Esc/q  Exit mode"

    # 3.0  O
    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Keys for choose-tree"

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
window_height=21
tmux_vers_check "3.1" && window_height=$((window_height + 1))
tmux_vers_check "3.2" && window_height=$((window_height + 7))
tmux_vers_check "3.5" && window_height=$((window_height + 1))
[ -n "$prev_menu" ] && window_height=$((window_height + 1))

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
