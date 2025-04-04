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
    if [ -z "$cmd" ]; then
        error_msg_safe "extras.is_available - no param!"
    fi
    if [ -z "$(command -v "$cmd")" ]; then
	# shellcheck disable=SC2039
        echo "-"
        # echo "$(tput setaf 7)"
    fi
}

dynamic_content() {
    d_extras="$d_items"/external_tools

    set -- \
        0.0 M Left "Back to Main menu  $nav_prev" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 M D "$(is_avalable dropbox)Dropbox      $nav_next" "$d_extras"/dropbox.sh \
        0.0 M S "$(is_avalable spotify)Spotify      $nav_next" "$d_extras"/spotify.sh \
        0.0 M M "$(is_avalable mullvad)Mullvad VPN  $nav_next" "$d_extras"/mullvad.sh \
        0.0 S \
        0.0 E i "public IP" public_ip.sh \
        0.0 M H "Help  $nav_next" "$d_help/help_extras.sh $0"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Extras"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
