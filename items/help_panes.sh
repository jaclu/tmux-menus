#!/bin/sh
#  shellcheck disable=SC2034
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help regarding panes menu
#

dynamic_content() {
    # Things that change dependent on various states

    menu_name="Help Panes"
    req_win_width=39
    req_win_height=10

    if [ -z "$menu_param" ]; then
        error_msg "help_panes.sh was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu <--" "$menu_param"

    menu_generate_part 1 "$@"
}

static_content() {

    set -- \
        0.0 S \
        0.0 T "-#[nodim]When saving history with escapes" \
        0.0 T "-#[nodim]less/most will not be able" \
        0.0 T "-#[nodim]to display the content." \
        0.0 S \
        0.0 T "-#[nodim]You would have to use tools like" \
        0.0 T "-#[nodim]cat/bat in order to see the colors"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

menu_param="$1"

#  Source dialog handling script
# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
