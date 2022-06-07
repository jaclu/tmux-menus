#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.4  2022-06-07
#
#   Help about move and link window
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Help, Move/Link Window"
req_win_width=38
req_win_height=15


previous_menu="$1"

if [ -z "$previous_menu" ]; then
    error_msg "help.sh was called without notice of what called it"
fi


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                               \
    -T "#[align=centre] $menu_name "                            \
    -x "$menu_location_x" -y "$menu_location_y"                 \
                                                                \
    "Back to Previous menu"  Left  "run-shell $previous_menu"   \
    ""                                                          \
    "-Displays a navigation tree"                       "" ""   \
    "-1 - Chose a session."                             "" ""   \
    "- Current window will be put as"                   "" ""   \
    "- the last window in that session."                "" ""   \
    "-2 - Choose a window in a session."                "" ""   \
    "- Current window will be inserted"                 "" ""   \
    "- on that location, pushing other"                 "" ""   \
    "- windows one step to the right."                  "" ""   \
    "-3 - If you choose a pane,"                        "" ""   \
    "- the pane part of the selection"                  "" ""   \
    "- is ignored."                                     "" ""

ensure_menu_fits_on_screen
