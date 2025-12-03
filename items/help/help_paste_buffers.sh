#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help regarding panes menu
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "-#[nodim]Tmux has its own clipboard system," \
        0.0 T "-#[nodim]shared between all sessions/windows/panes." \
        0.0 T "- " \
        0.0 T "-#[nodim]To integrate this clipboard with that" \
        0.0 T "-#[nodim]of the OS, this might need configuration" \
        0.0 T "-#[nodim]in tmux.conf depending on what OS" \
        0.0 T "-#[nodim]and terminal is being used." \
        0.0 S \
        0.0 T "-#[nodim]If nothing has been copied to a tmux buffer" \
        0.0 T "-#[nodim]actions will return immeditally."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -n "$1" ] && prev_menu="$(realpath "$1")"
menu_name="Help Paste buffers"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/../.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
