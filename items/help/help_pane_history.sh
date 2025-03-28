#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help regarding panes menu
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
        0.0 T "-#[nodim]When viewing history with escapes," \
        0.0 T "-#[nodim]use: less -R" \
        0.0 T "-#[nodim] " \
        0.0 T "-#[nodim]Or a color handling pager, like:" \
        0.0 T "-#[nodim] w3m/bat/most" \
        0.0 T "-#[nodim]In order to not get garbled output"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -n "$1" ] && prev_menu="$(realpath "$1")"
menu_name="Help Pane History"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
