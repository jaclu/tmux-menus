#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about move and link window
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" main.sh \
        0.0 S \
        0.0 T "-#[nodim]Displays a navigation tree" \
        0.0 T "-#[nodim]Escape/q aborts" \
        0.0 T "-#[nodim]" \
        0.0 T "-#[nodim]1 - If a session is selected" \
        0.0 T "-#[nodim] Current window will be put as" \
        0.0 T "-#[nodim] the last window in that session" \
        0.0 T "-#[nodim]2 - If a window is selected" \
        0.0 T "-#[nodim] Current window will be inserted" \
        0.0 T "-#[nodim] on that location, pushing other" \
        0.0 T "-#[nodim] windows one step to the right" \
        0.0 T "-#[nodim]3 - If a pane is selected," \
        0.0 T "-#[nodim] the pane part of the selection" \
        0.0 T "-#[nodim] is ignored, the action will be" \
        0.0 T "-#[nodim] based on the containing window"
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -n "$1" ] && prev_menu="$(realpath "$1")"
menu_name="Help, Move or Link Window"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/../.." && pwd)

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
