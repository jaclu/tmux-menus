#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Select and modify paste buffers
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Paste buffers"

#  shellcheck disable=SC2154
set -- \
    0.0 M Home "Back to Main menu      <==" main.sh \
    0.0 M Left "Back to Handling Pane  <--" panes.sh \
    0.0 T "#[align=centre,nodim]-----------   Commands   -----------" \
    0.0 T "This assumes at least one tmux buffer is assigned!" \
    0.0 T " " \
    0.0 T "Enter - Paste selected buffer" \
    0.0 T "Up    - Select previous buffer" \
    0.0 T "Down  - Select next buffer" \
    0.0 T "C-s   - Search by name or content" \
    0.0 T "n     Repeat last search" \
    0.0 T "t     Toggle if buffer is tagged" \
    0.0 T "T     Tag no buffers" \
    0.0 T "C-t   Tag all buffers" \
    0.0 T "p     Paste selected buffer" \
    0.0 T "P     Paste tagged buffers" \
    0.0 T "d     Delete selected buffer" \
    0.0 T "D     Delete tagged buffers" \
    0.0 T "e     Open the buffer in an editor" \
    0.0 T "f     Enter a format to filter items" \
    0.0 T "O     Change sort field" \
    0.0 T "r     Reverse sort order" \
    0.0 T "v     Toggle preview" \
    0.0 T "q     Exit mode" \
    0.0 T " " \
    1.9 C = "<P>" "choose-buffer" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=41
req_win_height=27

parse_menu "$@"
