#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.5 2022-06-07
#
#   Split display
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Split view"
req_win_width=28
req_win_height=15


this_menu="$CURRENT_DIR/split_view.sh"
reload="; run-shell \"$this_menu\""
open_menu="run-shell '$CURRENT_DIR"


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                           \
    -T "#[align=centre] $menu_name "                                        \
    -x "$menu_location_x" -y "$menu_location_y"                             \
                                                                            \
    "Back to Main menu"  Left  "$open_menu/main.sh'"                        \
    "-#[align=centre,nodim]----  Split Pane  ----" "" ""                    \
    "    Left"    l  "split-window -hb  -c '#{pane_current_path}' $reload"  \
    "<P> Right"   %  "split-window -h   -c '#{pane_current_path}' $reload"  \
    "    Above"   a  "split-window -vb  -c '#{pane_current_path}' $reload"  \
    "<P> Below"  \"  "split-window -v   -c '#{pane_current_path}' $reload"  \
    "-#[align=centre,nodim]---  Split Window  ---" "" ""                    \
    "    Left"    L  "split-window -fhb -c '#{pane_current_path}' $reload"  \
    "    Right"   R  "split-window -fh  -c '#{pane_current_path}' $reload"  \
    "    Above"   A  "split-window -fvb -c '#{pane_current_path}' $reload"  \
    "    Below"   B  "split-window -fv  -c '#{pane_current_path}' $reload"  \
    ""                                                                      \
    "Help  -->"   H  "$open_menu/help_split.sh $this_menu'"

ensure_menu_fits_on_screen
