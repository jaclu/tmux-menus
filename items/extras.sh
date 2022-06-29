#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.8 2022-06-08
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


this_menu="$CURRENT_DIR/panes.sh"
reload="; run-shell '$this_menu'"
open_menu="run-shell '$CURRENT_DIR"
open_extra="run-shell '$CURRENT_DIR/conditionals"


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                           \
    -T "#[align=centre] Handling Pane "                                     \
    -x "$menu_location_x" -y "$menu_location_y"                             \
    "Back to Main menu"   Left  "$open_menu/main.sh'"                       \
    "Spotify        -->"  S     "$open_extra/spotify.sh"                    \
    ""                                                                      \
    "Help  -->"  H  "$open_menu/help_panes.sh $this_menu'"


ensure_menu_fits_on_screen
