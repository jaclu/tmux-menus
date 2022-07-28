#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.1 2022-07-28
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
req_win_width=38
req_win_height=23


this_menu="$CURRENT_DIR/extras.sh"
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


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                       \
    -T "#[align=centre] Extras "                                        \
    -x "$menu_location_x" -y "$menu_location_y"                         \
    "Back to Main menu"  Left  "$open_menu/main.sh'"                    \
    ""                                                                  \
    "$(is_avalable spotify Spotify)  -->"        S                      \
            "$open_extra/spotify.sh"                                    \
    "$(is_avalable mullvad "Mullvad VPN")  -->"  M                      \
            "$open_extra/mullvad.sh"                                    \
    ""                                                                  \
    "Help  -->"  H  "$open_menu/help_extras.sh $this_menu'"


ensure_menu_fits_on_screen
