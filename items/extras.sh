#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

is_avalable() {
    cmd="$1"
    label="$2"

    if [ -z "$cmd" ]; then
        error_msg "extras.is_available() - no parameters given"
    fi
    if [ -n "$(command -v "$cmd")" ]; then
        echo "$label  $nav_next"
    else
        echo "-$label"
    fi
}

dynamic_content() {
    # Need to check for pesence of the external tools on each update, in case
    # something has been installed / removed
    d_extras="$d_items"/external_tools

    set -- \
        0.0 S \
        0.0 M D "$(is_avalable dropbox "Dropbox    ")" "$d_extras"/dropbox.sh \
        0.0 M S "$(is_avalable spotify "Spotify    ")" "$d_extras"/spotify.sh \
        0.0 M M "$(is_avalable mullvad "Mullvad VPN")" "$d_extras"/mullvad.sh
    menu_generate_part 3 "$@"
}

static_content() {
    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Main menu  $nav_prev" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E i "public IP" "$D_TM_BASE_PATH"/tools/public_ip.sh \
        0.0 M H "Help  $nav_next" "$d_help/help_extras.sh $0"
    menu_generate_part 4 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Extras"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
