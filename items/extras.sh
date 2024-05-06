#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

is_aok_fs() {
    if [ ! -d /opt/AOK ] || [ ! -d /proc/ish ]; then
        echo "-"
        # echo "$(tput setaf 7)"
    fi
}

is_avalable() {
    cmd="$1"
    if [ -z "$cmd" ]; then
        error_msg "extras.is_available - no param!"
    fi
    if [ -z "$(command -v "$cmd")" ]; then
        echo "-"
        # echo "$(tput setaf 7)"
    fi
}

static_content() {
    menu_name="Extras"
    req_win_width=33
    req_win_height=11

    d_extras="$d_items"/extras

    set -- \
        0.0 M Left "Back to Main menu  <--" main.sh \
        0.0 M A "$(is_aok_fs)iSH with AOK FS        -->" "$d_extras"/aok.sh \
        0.0 M D "$(is_avalable dropbox)Dropbox      -->" "$d_extras"/dropbox.sh \
        0.0 M S "$(is_avalable spotify)Spotify      -->" "$d_extras"/spotify.sh \
        0.0 M M "$(is_avalable mullvad)Mullvad VPN  -->" "$d_extras"/mullvad.sh \
        0.0 S \
        0.0 E i "public IP" public_ip.sh \
        0.0 S \
        0.0 M H 'Help -->' "$d_items/help_extras.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

exit 0 # TODO: figure out what triggers exit 1
