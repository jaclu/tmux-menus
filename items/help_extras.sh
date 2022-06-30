#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.0 2022-06-30
#
#   General Help
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global


# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Help Extras"
req_win_width=40
req_win_height=16


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
    "-Extras are menus manipulating" "" ""                      \
    "-other software."     "" ""                                \
    "-If a specific app is not found," "" ""                    \
    "-that entry is gryed out." "" ""

ensure_menu_fits_on_screen
