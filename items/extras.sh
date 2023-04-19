#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

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

menu_name="Extras"

#  shellcheck disable=SC2154
set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 S \
    0.0 M A "$(is_aok_fs)iSH with AOK FS  -->" "$CURRENT_DIR"/extras/aok.sh \
    0.0 M D "$(is_avalable dropbox)Dropbox  -->" "$CURRENT_DIR"/extras/dropbox.sh \
    0.0 M S "$(is_avalable spotify)Spotify  -->" "$CURRENT_DIR"/extras/spotify.sh \
    0.0 M M "$(is_avalable mullvad)Mullvad VPN  -->" "$CURRENT_DIR"/extras/mullvad.sh \
    0.0 S \
    0.0 M H 'Help       -->' "$CURRENT_DIR/help_extras.sh $current_script"

req_win_width=33
req_win_height=10

menu_parse "$@"
