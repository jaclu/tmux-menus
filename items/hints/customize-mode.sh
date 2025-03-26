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
    if tmux_vers_check "3.5"; then
        # Description was changed
        forwards_hint="forwards"
    fi
    set -- \
        3.2 S \
        3.2 T "-#[nodim]Enter  Set option value" \
        3.2 T "-#[nodim]Up     Select previous item" \
        3.2 T "-#[nodim]Down   Select next item" \
        3.2 T "-#[nodim]+      Expand selected item" \
        3.2 T "-#[nodim]-      Collapse selected item" \
        3.2 T "-#[nodim]M-+    Expand all items" \
        3.2 T "-#[nodim]M--    Collapse all items" \
        3.2 T "-#[nodim]s      Set option value or key attribute" \
        3.2 T "-#[nodim]S      Set global option value" \
        3.2 T "-#[nodim]w      Set window option value, for pane/window option" \
        3.2 T "-#[nodim]d      Set an option or key to the default" \
        3.2 T "-#[nodim]D      Set tagged options/keys to default" \
        3.2 T "-#[nodim]u      Unset an option or unbind a key" \
        3.2 T "-#[nodim]U      Unset tagged options and unbind tagged keys" \
        3.2 T "-#[nodim]C-s    Search by name" \
        3.2 T "-#[nodim]n      Repeat last search $forwards_hint" \
        3.5 T "-#[nodim]N      Repeat last search backwards" \
        3.2 T "-#[nodim]t      Toggle if item is tagged" \
        3.2 T "-#[nodim]T      Tag no items" \
        3.2 T "-#[nodim]C-t    Tag all items" \
        3.2 T "-#[nodim]f      Enter a format to filter items" \
        3.2 T "-#[nodim]v      Toggle option information" \
        3.2 T "-#[nodim]Esc/q  Exit mode"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Keys for customize-mode"
menu_min_vers=3.2

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
window_height=26
tmux_vers_check "3.5" && window_height=$((window_height + 1))
[ -n "$prev_menu" ] && window_height=$((window_height + 1))

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
