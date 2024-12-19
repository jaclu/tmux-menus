#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

dynamic_content() {
    # Things that change dependent on various states

    if [ -z "$prev_menu" ]; then
        error_msg "$current_script was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu     $nav_home" main.sh

    menu_generate_part 1 "$@"
}

static_content() {
    set -- \
        0.0 S \
        0.0 T "-#[nodim] $nav_next#[default]  #[nodim]Open a new menu." \
        0.0 T "-#[nodim] $nav_prev#[default]  #[nodim]Back to previous menu." \
        0.0 T "-#[nodim] $nav_home#[default]  #[nodim]Back to start menu." \
        0.0 S \
        0.0 T "-#[nodim]Shortcut keys are usually upper case" \
        0.0 T "-#[nodim]for menus, and lower case for actions."

    ! $cfg_use_whiptail && {
        set -- "$@" \
            0.0 T "-#[nodim]Exit menus with ESC or Ctrl-C"
    }

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

prev_menu="$(realpath -- "$1")"
menu_name="Help summary"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
