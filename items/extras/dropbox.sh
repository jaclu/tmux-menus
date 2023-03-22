#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control DropBox
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Dropbox"
full_path_this="$CURRENT_DIR/$(basename $0)"
req_win_width=33
req_win_height=9

reload="; run-shell '$full_path_this'"
open_menu="run-shell '$ITEMS_DIR"

if [ -z "$(command -v dropbox)" ]; then
    $TMUX_BIN display "dropbox bin not found!"
    exit 1
fi

if is_dropbox_running; then
    tgl_lbl="sTop"
else
    tgl_lbl="sTart"
fi

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu \
    -T "#[align=centre] $menu_name " \
    -x "$menu_location_x" -y "$menu_location_y" \
    \
    "Back to Main menu  <==" Home "$open_menu/main.sh'" \
    "Back to Extras     <--" Left "$open_menu/extras.sh'" \
    "" \
    "Status" s "display \"$(dropbox status)\" $reload" \
    "$tgl_lbl" t "run-shell \"$CURRENT_DIR/_dropbox_toggle.sh\"  \
                      $reload" \
    "" \
    "Help  -->" H "$open_menu/help.sh $full_path_this'"

ensure_menu_fits_on_screen
