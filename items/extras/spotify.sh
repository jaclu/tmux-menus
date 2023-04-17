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

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

reload=" > /dev/null' ; $current_script"

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

# song_title="$($SCRIPT_DIR/spotify-now-playing | sed "s/'/*/g" | sed 's/"/*/g')"
song_title="Ay - Arema Arega - Gilles Peterson Presents: Havana Cultura the Search Continues"
# song_title="Ay - Arema Arega - Gilles Peterson Presents"

menu_name="Spotify"

set -- \
    0.0 M Home "Back to Main menu  <==" "$ITEMS_DIR/main.sh" \
    0.0 M Left "Back to Extras     <--" "$ITEMS_DIR/extras.sh" \
    0.0 S \
    0.0 C t "$title_label" "display '$song_title' $menu_reload" \
    0.0 S
# 0.0 E Space "Pause/Resume" "spotify pause  $reload" \
# 0.0 E n "Next" "spotify             next   $reload" \
# 0.0 E p "Prev" "spotify             prev   $reload" \
# 0.0 E r "Replay" "spotify           replay $reload" \
# 0.0 E i "Copy URI to clipboard" "spotify share uri $reload" \
# 0.0 E l "Copy URL to clipboard" "spotify share url $reload" \
# 0.0 E s "Shuffle - toggle" "spotify toggle shuffle $reload" \
# 0.0 E R "Repeat  - toggle" "spotify toggle repeat  $reload" \
# 0.0 E u "vol Up" "spotify           vol up         $reload" \
# 0.0 E d "vol Down" "spotify         vol down       $reload" \
# 0.0 S \
# 0.0 M H 'Help       -->' "$ITEMS_DIR/help.sh $current_script"

req_win_width=33
req_win_height=13

parse_menu "$@"
