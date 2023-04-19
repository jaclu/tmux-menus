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

reload_no_output=" > /dev/null ; $current_script"

if [ -z "$(command -v spotify)" ]; then
    $TMUX_BIN display "spotify bin not found!"
    exit 1
fi

menu_name="Spotify"

set -- \
    0.0 M Home "Back to Main menu  <==" "$ITEMS_DIR/main.sh" \
    0.0 M Left "Back to Extras     <--" "$ITEMS_DIR/extras.sh" \
    0.0 S

if [ "$(uname)" = "Darwin" ]; then
    # This title check is a MacOS script
    set -- "$@" \
        0.0 C t "Title - now playing" "display \
            '$("$SCRIPT_DIR"/spotify-now-playing | sed "s/'/*/g" | sed 's/"/*/g')' \
            $menu_reload" \
        0.0 S
fi

set -- "$@" \
    0.0 E Space "Pause/Resume" "spotify pause  $reload_no_output" \
    0.0 E n "Next" "spotify   next   $reload_no_output" \
    0.0 E p "Prev" "spotify   prev   $reload_no_output" \
    0.0 E r "Replay" "spotify replay $reload_no_output" \
    0.0 E i "Copy URI to clipboard" "spotify share uri $reload_no_output" \
    0.0 E l "Copy URL to clipboard" "spotify share url $reload_no_output" \
    0.0 E s "Shuffle - toggle" "spotify toggle shuffle $reload_no_output" \
    0.0 E R "Repeat  - toggle" "spotify toggle repeat  $reload_no_output" \
    0.0 E u "vol Up" "spotify           vol up         $reload_no_output" \
    0.0 E d "vol Down" "spotify         vol down       $reload_no_output" \
    0.0 S \
    0.0 M H 'Help       -->' "$ITEMS_DIR/help.sh $current_script"

req_win_width=33
req_win_height=13

menu_parse "$@"
