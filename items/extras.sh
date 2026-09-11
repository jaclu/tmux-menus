#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
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
    if command -v "$cmd" >/dev/null; then
        echo "$label  $nav_next"
    else
        echo "-$label"
    fi
}

dynamic_content() {
    # Need to check for pesence of the external tools on each update, in case
    # something has been installed / removed
    d_extras="$d_items"/external_tools

    # Try to pad label with spaces so that navs line up with "Back to Main" and "Help"
    set -- \
        0.0 M D "$(is_avalable dropbox "Dropbox         ")" "$d_extras"/dropbox.sh \
        0.0 M S "$(is_avalable spotify "Spotify         ")" "$d_extras"/spotify.sh \
        0.0 M M "$(is_avalable mullvad "Mullvad VPN     ")" "$d_extras"/mullvad.sh
    menu_generate_part 2 "$@"
}

static_content() {
    set -- \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    set -- \
        0.0 M H "Help              $nav_next" "$d_help/h_extras.sh $0"
    menu_generate_part 3 "$@"
    display_commands_toggle 4

    set -- \
        0.0 S \
        0.0 E i "public IP" "$D_TM_BASE_PATH"/tools/public_ip.sh
    menu_generate_part 5 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Extras"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
