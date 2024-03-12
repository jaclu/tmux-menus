#!/bin/sh
#  shellcheck disable=SC2034
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about splitting the view
#

dynamic_content() {
    # Things that change dependent on various states

    menu_name="Help, Split view"
    req_win_width=36
    req_win_height=11

    if [ -z "$menu_param" ]; then
        error_msg "help_split.sh was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu <--" "$menu_param"

    menu_generate_part 1 "$@"
}

static_content() {
    #
    #  TODO: For odd reasons this title needs multiple right padding spaces,
    #        in order to actually print one, figure out what's going on
    #

    # shellcheck disable=SC2154
    set -- \
        0.0 M Left "Back to Previous menu <--" "$previous_menu" \
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

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

menu_param="$1"

#  Source dialog handling script
# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
