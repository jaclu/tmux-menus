#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.2 2022-06-07
#
#   Help about splitting the view
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Help, Split view"
req_win_width=32
req_win_height=10


previous_menu="$1"

if [ -z "$previous_menu" ]; then
    error_msg "help_split.sh was called without notice of what called it"
fi


t_start="$(date +'%s')"

#
#  TODO: For odd reasons this title needs multiple right padding spaces,
#        in order to actually print one, figure out what's going on
#
# shellcheck disable=SC2154
tmux display-menu                                               \
    -T "#[align=centre] $menu_name   "                          \
    -x "$menu_location_x" -y "$menu_location_y"                 \
                                                                \
    "Back to Previous menu"  Left  "run-shell $previous_menu"   \
    ""                                                          \
    "-Creating a new pane by"                           "" ""   \
    "-splitting current Pane or"                        "" ""   \
    "-Window."                                          "" ""   \
    "- " "" ""                                                  \
    "-Window refers to the entire"                      "" ""   \
    "-display."                                         "" ""

ensure_menu_fits_on_screen
