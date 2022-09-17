#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.5 2022-09-17
#
#   Directly control Spotify
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Spotify"
req_win_width=28
req_win_height=13


this_menu="$CURRENT_DIR/spotify.sh"
open_menu="run-shell '$ITEMS_DIR"

prefix="run-shell 'spotify "
suffix=" > /dev/null' ; run-shell '$this_menu'"


if [ -z "$(command -v spotify)" ]; then
    $TMUX_BIN display "spotify bin not found!"
    exit 1
fi


t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu                                                   \
    -T "#[align=centre] $menu_name "                                \
    -x "$menu_location_x" -y "$menu_location_y"                     \
                                                                    \
    "Back to Main menu"  Home  "$open_menu/main.sh'"                \
    "Back to Extras"     Left  "$open_menu/extras.sh'"              \
    ""                                                              \
    "Pause/Resume"       " "   "$prefix pause     $suffix"          \
    "Prev"               p     "$prefix prev      $suffix"          \
    "Next"               n     "$prefix next      $suffix"          \
    "Replay"             r     "$prefix replay    $suffix"          \
    "vol Up"             u     "$prefix vol up    $suffix"          \
    "vol Down"           d     "$prefix vol down  $suffix"          \
    ""                                                              \
    "Help  -->"  H  "$open_menu/help.sh $CURRENT_DIR/spotify.sh'"


ensure_menu_fits_on_screen
