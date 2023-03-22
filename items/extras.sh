#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Handling Pane"
full_path_this="$CURRENT_DIR/$(basename $0)"
req_win_width=33
req_win_height=9


reload="; run-shell '$this_menu'"
open_menu="run-shell '$CURRENT_DIR"
open_extra="run-shell '$CURRENT_DIR/extras"


is_avalable() {
    cmd="$1"
    label=${2:-$cmd}
    if [ -z "$cmd" ]; then
        error_msg "extras.is_available - no param!"
    fi
    if [ -n "$(command -v "$cmd")" ]; then
        echo "$label"
    else
        echo "-$label"
    fi

}

is_aok_fs() {
    if [ ! -d /opt/AOK ] || [ ! -d /proc/ish ]; then
        echo "-"
    fi
}

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu                                                  \
    -T "#[align=centre] Extras "                                        \
    -x "$menu_location_x" -y "$menu_location_y"                         \
    "Back to Main menu  <--"  Left  "$open_menu/main.sh'"               \
    ""                                                                  \
    "$(is_aok_fs)iSH with AOK FS  -->"          A                       \
            "$open_extra/aok.sh'"                                       \
    "$(is_avalable dropbox Dropbox)  -->"       D                       \
            "$open_extra/dropbox.sh'"                                   \
    "$(is_avalable spotify Spotify)  -->"       S                       \
            "$open_extra/spotify.sh'"                                   \
    "$(is_avalable mullvad "Mullvad VPN")  -->" M                       \
            "$open_extra/mullvad.sh'"                                   \
    ""                                                                  \
    "Help  -->"  H  "$open_menu/help_extras.sh $full_path_this'"


ensure_menu_fits_on_screen
