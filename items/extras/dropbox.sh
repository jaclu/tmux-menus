#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control DropBox
#

# Global check exclude
# shellcheck disable=SC1091,SC2034,SC2154

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

. "$SCRIPT_DIR"/dialog_handling.sh
. "$SCRIPT_DIR"/dropbox_tools.sh

[ -z "$(command -v dropbox)" ] && error_msg "dropbox bin not found!" 1

if is_dropbox_running; then
    tgl_lbl="sTop"
else
    tgl_lbl="sTart"
fi

menu_name="Dropbox"

set -- \
    0.0 M Home "Back to Main menu  <==" "$ITEMS_DIR/main.sh" \
    0.0 M Left "Back to Extras     <--" "$ITEMS_DIR/extras.sh" \
    0.0 S \
    0.0 C s "Status" "display \"$(dropbox status)\" $menu_reload" \
    0.0 E t "$tgl_lbl" "$CURRENT_DIR/_dropbox_toggle.sh $menu_reload" \
    0.0 S \
    0.0 M H "Help  -->" "$ITEMS_DIR/help.sh $current_script'"

req_win_width=33
req_win_height=9

menu_parse "$@"
