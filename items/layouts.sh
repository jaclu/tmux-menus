#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.6 2022-06-07
#
#   Choose layout
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Layouts"
req_win_width=31
req_win_height=16


this_menu="$CURRENT_DIR/layouts.sh"
reload=" ; run-shell \"$this_menu\""
open_menu="run-shell '$CURRENT_DIR"


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                       \
    -T "#[align=centre] $menu_name "                    \
    -x "$menu_location_x" -y "$menu_location_y"         \
                                                        \
    "Back to Main menu"  Left  "$open_menu/main.sh'"    \
    ""                                                  \
    "Most of these defaults" "" ""                      \
    "can't be used in menus." "" ""                     \
    "They are just listed" "" ""                        \
    " " "" ""                                           \
    "#[fg=red]<P> M-1#[default] Even horizontal"   1    \
        "select-layout even-horizontal $reload"         \
    "#[fg=red]<P> M-2#[default] Even vertical"     2    \
        "select-layout even-vertical   $reload"         \
    "#[fg=red]<P> M-3#[default] Main horizontal"   3    \
        "select-layout main-horizontal $reload"         \
    "#[fg=red]<P> M-4#[default] Main vertical"     4    \
        "select-layout main-vertical   $reload"         \
    "#[fg=red]<P> M-5#[default] Tiled"             5    \
        "select-layout tiled           $reload"         \
    "<P> Spread evenly"                            E    \
        "select-layout -E              $reload"         \
    ""                                                  \
    "Help  -->"  H  "$open_menu/help.sh $this_menu'"


ensure_menu_fits_on_screen
