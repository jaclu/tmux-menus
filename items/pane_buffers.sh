#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Select and modify paste buffers
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Paste buffers"
full_path_this="$CURRENT_DIR/$(basename $0)"
req_win_width=41
req_win_height=27

open_menu="run-shell '$CURRENT_DIR"

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu \
    -T "#[align=centre] $menu_name " \
    -x "$menu_location_x" -y "$menu_location_y" \
    \
    "Back to Main menu      <==" Home "$open_menu/main.sh'" \
    "Back to Handling Pane  <--" Left "$open_menu/panes.sh'" \
    "-#[align=centre,nodim]-----------   Commands   -----------" "" "" \
    "-Enter Paste selected buffer" "" "" \
    "-Up    Select previous buffer" "" "" \
    "-Down  Select next buffer" "" "" \
    "-C-s   Search by name or content" "" "" \
    "-n     Repeat last search" "" "" \
    "-t     Toggle if buffer is tagged" "" "" \
    "-T     Tag no buffers" "" "" \
    "-C-t   Tag all buffers" "" "" \
    "-p     Paste selected buffer" "" "" \
    "-P     Paste tagged buffers" "" "" \
    "-d     Delete selected buffer" "" "" \
    "-D     Delete tagged buffers" "" "" \
    "-e     Open the buffer in an editor" "" "" \
    "-f     Enter a format to filter items" "" "" \
    "-O     Change sort field" "" "" \
    "-r     Reverse sort order" "" "" \
    "-v     Toggle preview" "" "" \
    "-q     Exit mode" "" "" \
    "-" "" "" \
    "<P>" = "choose-buffer -Z" \
    "" \
    "Help  -->" H "$open_menu/help.sh $full_path_this'"

ensure_menu_fits_on_screen
