#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control Spotify
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Spotify"
full_path_this="$CURRENT_DIR/$(basename $0)"
req_win_width=33
req_win_height=13

open_menu="run-shell '$ITEMS_DIR"

prefix="run-shell 'spotify "
suffix=" > /dev/null' ; run-shell '$full_path_this'"

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
    "" \
    "$title_label" "$title_key" \
    \
    "display \"$("$SCRIPT_DIR"/spotify-now-playing)\" ;             \
        run-shell \"$full_path_this\"" \
    \
    "Pause/Resume" " " "$prefix pause           $suffix" \
    "Next" n "$prefix next            $suffix" \
    "Prev" p "$prefix prev            $suffix" \
    "Replay" r "$prefix replay          $suffix" \
    "Copy URI to clipboard" i "$prefix share uri       $suffix" \
    "Copy URL to clipboard" l "$prefix share url       $suffix" \
    "Shuffle - toggle" s "$prefix toggle shuffle  $suffix" \
    "Repeat  - toggle" R "$prefix toggle repeat   $suffix" \
    "vol Up" u "$prefix vol up          $suffix" \
    "vol Down" d "$prefix vol down        $suffix" \
    "" \
    "Help  -->" H "$open_menu/help.sh $full_path_this'"

ensure_menu_fits_on_screen
