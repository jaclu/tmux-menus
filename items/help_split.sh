#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about splitting the view
#

dynamic_content() {
    # Things that change dependent on various states

    if [ -z "$prev_menu" ]; then
        error_msg "help_split.sh was called without notice of what called it"
    fi

    set -- \
        0.0 M Home "Back to Main menu     $nav_home" main.sh \
        0.0 M Left "Back to Previous menu $nav_prev" "$prev_menu"

    menu_generate_part 1 "$@"
}

static_content() {
    #
    #  TODO: For odd reasons this title needs multiple right padding spaces,
    #        in order to actually print one, figure out what's going on
    #

    set -- \
        0.0 S \
        0.0 T "-#[nodim]Creating a new pane by" \
        0.0 T "-#[nodim]splitting current Pane or" \
        0.0 T "-#[nodim]Window." \
        0.0 T "-#[nodim] " \
        0.0 T "-#[nodim]Window refers to the entire" \
        0.0 T "-#[nodim]display."

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

prev_menu="$1"
menu_name="Help, Split view"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
