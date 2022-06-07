#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.5 2022-06-08
#
#   Move a pane
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Move Pane"
req_win_width=41
req_win_height=13


this_menu="$CURRENT_DIR/pane_move.sh"
reload="; run-shell '$this_menu'"

set --  "choose-tree -Gw 'run-shell \"$SCRIPT_DIR/relocate_pane.sh"  \
        "P M %%\"'"
mv_2_other="$*"

break_2_other="run-shell $SCRIPT_DIR/break_pane.sh"
open_menu="run-shell '$CURRENT_DIR"


t_start="$(date +'%s')"

#
#  Added spacing for move to other in order for Swap current label
#  not to expand into the shortcuts if no pane is marked
#
# shellcheck disable=SC2154
tmux display-menu                                                       \
    -T "#[align=centre] $menu_name "                                    \
    -x "$menu_location_x" -y "$menu_location_y"                         \
                                                                        \
    "Back to Main menu"      Home  "$open_menu/main.sh'"                \
    "Back to Handling Pane"  Left  "$open_menu/panes.sh'"               \
    ""                                                                  \
    "    Move to other win/ses        "  m  "$mv_2_other"               \
    "#{?pane_marked_set,,-}    Swap current pane with marked"           \
                                      s  "swap-pane $reload"            \
    "<P> Swap pane with prev"           \{  "swap-pane -U $reload"      \
    "<P> Swap pane with next"           \}  "swap-pane -D $reload"      \
    ""                                                                  \
    "<P> Break pane to a new window"     !  "$break_2_other"            \
    ""                                                                  \
    "Help  -->"  H  "$open_menu/help.sh $this_menu'"

ensure_menu_fits_on_screen
