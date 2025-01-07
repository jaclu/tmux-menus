#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
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
                '$("$d_scripts"/spotify-now-playing | sed "s/'/*/g" | sed 's/"/*/g')' \
                $menu_reload" \
            0.0 S
        menu_generate_part 2 "$@"
    fi
}

static_content() {

    reload_no_output=" > /dev/null ; $f_current_script"

    [ -z "$(command -v spotify)" ] && error_msg "spotify bin not found!"

    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh \
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
        0.0 E d "vol Down" "spotify         vol down       $reload_no_output"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Spotify"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
