#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about move and link window
#

dynamic_content() {
    # Things that change dependent on various states

    if [ -z "$prev_menu" ]; then
        error_msg_safe "$bn_current_script was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" main.sh

    menu_generate_part 1 "$@"
}

static_content() {

    set -- \
        0.0 S \
        0.0 T "-#[nodim]Displays a navigation tree" \
        0.0 T "-#[nodim]Escape/q aborts" \
        0.0 T "-#[nodim]" \
        0.0 T "-#[nodim]1 - If a session is selected" \
        0.0 T "-#[nodim] Current pane will be put in" \
        0.0 T "-#[nodim] the last window in that session" \
        0.0 T "-#[nodim]2 - If a window is selected" \
        0.0 T "-#[nodim] Current pane will be added" \
        0.0 T "-#[nodim] as the last pane in that window" \
        0.0 T "-#[nodim]3 - If a pane is selected," \
        0.0 T "-#[nodim] current pane will be inserted" \
        0.0 T "-#[nodim] after selected pane"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -n "$1" ] && prev_menu="$(realpath "$1")"
menu_name="Help, Move Pane"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
