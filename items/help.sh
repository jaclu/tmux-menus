#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.3 2022-06-07
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

menu_name="Help summary"
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
    "- -->  Indicates this will open a"                 "" ""   \
    "-      new menu."                                  "" ""   \
    ""                                                          \
    "-<P> Indicates this key is a default"              "" ""   \
    "-    key, so unless it has been"                   "" ""   \
    "-    changed, it should be possible"               "" ""   \
    "-    to use with <prefix> directly."               "" ""   \
    ""                                                          \
    "-Shortcut keys are upper case for"                 "" ""   \
    "-menus menus, and lower case for"                  "" ""   \
    "-actions."                                         "" ""   \
    "-With the exception of defaults."                  "" ""

ensure_menu_fits_on_screen
