#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help regarding panes menu
#

dynamic_content() {
    # Things that change dependent on various states

    menu_name="Help Panes"

    if [ -z "$prev_menu" ]; then
        error_msg "help_panes.sh was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu <--" "$prev_menu"

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

prev_menu="$1"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
