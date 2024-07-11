#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about move and link window
#

dynamic_content() {
    # Things that change dependent on various states

    menu_name="Help, Move/Link Window"

    if [ -z "$prev_menu" ]; then
        error_msg "help_split.sh was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu <--" "$prev_menu"

    menu_generate_part 1 "$@"
}

static_content() {

    set -- \
        0.0 S \
        0.0 T "-#[nodim]Displays a navigation tree" \
        0.0 T "-#[nodim]1 - Chose a session." \
        0.0 T "-#[nodim] Current window will be put as" \
        0.0 T "-#[nodim] the last window in that session." \
        0.0 T "-#[nodim]2 - Choose a window in a session." \
        0.0 T "-#[nodim] Current window will be inserted" \
        0.0 T "-#[nodim] on that location, pushing other" \
        0.0 T "-#[nodim] windows one step to the right." \
        0.0 T "-#[nodim]3 - If you choose a pane," \
        0.0 T "-#[nodim] the pane part of the selection" \
        0.0 T "-#[nodim] is ignored."

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
