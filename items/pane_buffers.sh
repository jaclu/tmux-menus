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
    2.0 M Home "Back to Main menu      <==" main.sh \
    2.0 M Left "Back to Handling Pane  <--" panes.sh \
    2.0 T "-#[align=centre,nodim]-----------   Commands   -----------" \
    2.0 T "-#[nodim]This assumes at least one tmux buffer is assigned!" \
    2.0 T "-#[nodim] " \
    2.0 T "-#[nodim]Enter - Paste selected buffer" \
    2.0 T "-#[nodim]Up    - Select previous buffer" \
    2.0 T "-#[nodim]Down  - Select next buffer" \
    2.0 T "-#[nodim]C-s   - Search by name or content" \
    2.0 T "-#[nodim]n     Repeat last search" \
    2.0 T "-#[nodim]t     Toggle if buffer is tagged" \
    2.0 T "-#[nodim]T     Tag no buffers" \
    2.0 T "-#[nodim]C-t   Tag all buffers" \
    2.0 T "-#[nodim]p     Paste selected buffer" \
    2.0 T "-#[nodim]P     Paste tagged buffers" \
    2.0 T "-#[nodim]d     Delete selected buffer" \
    2.0 T "-#[nodim]D     Delete tagged buffers" \
    2.0 T "-#[nodim]e     Open the buffer in an editor" \
    2.0 T "-#[nodim]f     Enter a format to filter items" \
    2.0 T "-#[nodim]O     Change sort field" \
    2.0 T "-#[nodim]r     Reverse sort order" \
    2.0 T "-#[nodim]v     Toggle preview" \
    2.0 T "-#[nodim]q     Exit mode" \
    2.0 T "-#[nodim] " \
    1.9 C = "<P>" "choose-buffer" \
    2.0 S \
    2.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=41
req_win_height=27

menu_parse "$@"
