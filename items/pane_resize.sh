#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.4  2022-06-07
#
#   Resize a pane
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Resize Pane"
req_win_width=33
req_win_height=18


this_menu="$CURRENT_DIR/pane_resize.sh"
reload="; run-shell '$this_menu'"

set_size="command-prompt -p 'Pane width,Pane height' 'resize-pane -x %1 -y %2'"
open_menu="run-shell '$CURRENT_DIR"


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                   \
    -T "#[align=centre] $menu_name "                                \
    -x "$menu_location_x" -y "$menu_location_y"                     \
                                                                    \
    "Back to Main menu"      Home  "$open_menu/main.sh'"            \
    "Back to Handling Pane"  Left  "$open_menu/panes.sh'"           \
    ""                                                              \
    "Specify width & height"  s  "$set_size"                        \
    "-#[align=centre,nodim]-------  resize by 1  ------" "" ""      \
    "up     "                 u  "resize-pane -U $reload"           \
    "down   "                 d  "resize-pane -D $reload"           \
    "left   "                 l  "resize-pane -L $reload"           \
    "right  "                 r  "resize-pane -R $reload"           \
    "-#[align=centre,nodim]-------  resize by 5  ------" "" ""      \
    "up     "                 U  "resize-pane -U 5 $reload"         \
    "down   "                 D  "resize-pane -D 5 $reload"         \
    "left   "                 L  "resize-pane -L 5 $reload"         \
    "right  "                 R  "resize-pane -R 5 $reload"         \
    ""                                                              \
    "Help  -->"               H  "$open_menu/help.sh $this_menu'"

ensure_menu_fits_on_screen
