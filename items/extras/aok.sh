#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control iSH-AOK
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="iSH-AOK"
req_win_width=33
req_win_height=13

this_menu="$CURRENT_DIR/spotify.sh"
open_menu="run-shell '$ITEMS_DIR"

prefix="run-shell 'spotify "
suffix=" > /dev/null' ; run-shell '$this_menu'"

if [ -z "$(command -v spotify)" ]; then
    $TMUX_BIN display "spotify bin not found!"
    exit 1
fi

title_label="Title - now playing"
title_key="t"
if [ "$(uname)" != "Darwin" ]; then
    # Title check is a MacOS script
    title_label="-$title_label"
    title_key=""
fi

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu \
    -T "#[align=centre] $menu_name " \
    -x "$menu_location_x" -y "$menu_location_y" \
    \
    "Back to Main menu  <==" Home "$open_menu/main.sh'" \
    "Back to Extras     <--" Left "$open_menu/extras.sh'" \
    "Login mode         -->" L "$open_menu/extras/aok-login.sh" \
    "" \
    "toggle Multicore" "m" "$prefix pause           $suffix" \
    "toggle Extra locking" "e" "$prefix next            $suffix" \
    "" \
    "Help  -->" H "$open_menu/help.sh $CURRENT_DIR/spotify.sh'"

ensure_menu_fits_on_screen
