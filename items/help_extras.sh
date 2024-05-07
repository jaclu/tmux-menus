#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

dynamic_content() {
    # Things that change dependent on various states

    menu_name="Help Extras"

    if [ -z "$prev_menu" ]; then
        error_msg "help.sh was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu <--" "$prev_menu"

    menu_generate_part 1 "$@"
}

static_content() {
    set -- \
        0.0 S \
        0.0 T "-#[nodim]Extras are menus manipulating" \
        0.0 T "-#[nodim]other software." \
        0.0 T "-#[nodim]If a specific app is not found," \
        0.0 T "-#[nodim]that entry is grayed out."

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

prev_menu="$1"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "><> $current_script exiting [$e]"
fi
