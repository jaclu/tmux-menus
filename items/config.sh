#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.8  2022-06-08
#
#   Live configuration. So far only menu location is available
#

#  shellcheck disable=SC2034,SC2154
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Configure Menu Location"
req_win_width=32
req_win_height=13


this_menu="$CURRENT_DIR/config.sh"
reload="; $this_menu"
change_location="run-shell '$SCRIPT_DIR/move_menu.sh"
open_menu="run-shell '$CURRENT_DIR"

#
#  The -p sequence will get wrecked by lnie breaks,
#  so left as one annoyingly long line
#
prompt1="horizontal pos (max: #{window_width}):"
prompt2="vertical pos (max: #{window_height}):"

set --  "command-prompt"                             \
        "-I \"$location_x\",\"$location_y\""         \
        "-p \"$prompt1\",\"$prompt2\""               \
        "\"$change_location coord %1 %2 $reload'\""
set_coordinates="$*"


t_start="$(date +'%s')"  #  if the menu closed in < 1s assume it didnt fit

# shellcheck disable=SC2154
tmux display-menu                                                   \
    -T "#[align=centre] $menu_name "                                \
    -x "$menu_location_x" -y "$menu_location_y"                     \
                                                                    \
    "Back to Previous menu"  Left  "$open_menu/advanced.sh'"        \
    ""                                                              \
    "Center"                 c     "$change_location  C  $reload'"  \
    "win Right edge"         r     "$change_location  R  $reload'"  \
    "Pane bottom left"       p     "$change_location  P  $reload'"  \
    "Win pos status line"    w     "$change_location  W  $reload'"  \
    ""                                                              \
    "set coordinates"        s     "$set_coordinates"               \
    ""                                                              \
    "-When using coordinates"      "" ""                            \
    "-lower left corner is set!"   "" ""

ensure_menu_fits_on_screen
