#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.3 2022-09-17
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
req_win_width=28
req_win_height=9


this_menu="$CURRENT_DIR/dropbox.sh"
reload="; run-shell '$this_menu'"
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
$TMUX_BIN display-menu                                                   \
    -T "#[align=centre] $menu_name "                                \
    -x "$menu_location_x" -y "$menu_location_y"                     \
                                                                    \
    "Back to Main menu"  Home  "$open_menu/main.sh'"                \
    "Back to Extras"     Left  "$open_menu/extras.sh'"              \
    ""                                                              \
    "Status"     s  "display \"$(dropbox status)\" $reload"         \
    "$tgl_lbl"   t  "run-shell \"$CURRENT_DIR/_dropbox_toggle.sh\"  \
                      $reload"                                      \
    ""                                                              \
    "Help  -->"  H  "$open_menu/help.sh $CURRENT_DIR/dropbox.sh'"


ensure_menu_fits_on_screen
