#!/bin/sh
#  shellcheck disable=SC2034,SC2154
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control Spotify
#

dynamic_content() {
    if [ "$(uname)" = "Darwin" ]; then
        # This title check is a MacOS script
        set -- \
            0.0 C t "Title - now playing" "display \
                '$("$D_TM_SCRIPTS"/spotify-now-playing | sed "s/'/*/g" | sed 's/"/*/g')' \
                $menu_reload" \
            0.0 S
        menu_generate_part 2 "$@"
    fi
}

static_content() {
    menu_name="Spotify"
    req_win_width=33
    req_win_height=13

    reload_no_output=" > /dev/null ; $current_script"

    [ -z "$(command -v spotify)" ] && error_msg "spotify bin not found!"

    set -- \
        0.0 M Home "Back to Main menu  <==" "$D_TM_ITEMS/main.sh" \
        0.0 M Left "Back to Extras     <--" "$D_TM_ITEMS/extras.sh" \
        0.0 S

    menu_generate_part 1 "$@"

    set -- \
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
        0.0 M H 'Help       -->' "$D_TM_ITEMS/help.sh $current_script"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname "$(dirname -- "$0")")" && pwd)")"

#  Source dialog handling script
# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
