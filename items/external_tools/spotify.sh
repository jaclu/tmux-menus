#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control Spotify
#

display_currently_playing_track() {
    # shellcheck source=scripts/helpers_minimal.sh
    . "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

    track="$(spotify status track)"
    artist="$(spotify status artist)"
    album="$(spotify status album)"
    tmux_error_handler display "$track - Artist: $artist - Album: $album"
    exit 0
}

static_content() {

    reload_no_output=" >/dev/null ; $0"

    [ -z "$(command -v spotify)" ] && error_msg_safe "spotify bin not found!"

    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E t "Title - currently playing track" \
        "$0 -t $reload_no_output" \
        0.0 S \
        0.0 E Space "Pause/Resume" "spotify pause    $reload_no_output" \
        0.0 E n "Next" "spotify             next     $reload_no_output" \
        0.0 E p "Prev" "spotify             prev     $reload_no_output" \
        0.0 E r "Replay" "spotify           replay   $reload_no_output" \
        0.0 E s "Shuffle - toggle" "spotify toggle shuffle $reload_no_output" \
        0.0 E R "Repeat  - toggle" "spotify toggle repeat  $reload_no_output" \
        0.0 E u "vol Up" "spotify           vol up   $reload_no_output" \
        0.0 E d "vol Down" "spotify         vol down $reload_no_output" \
        0.0 E i "Copy URI to clipboard" "spotify share uri $reload_no_output" \
        0.0 E l "Copy URL to clipboard" "spotify share url $reload_no_output"

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

case "$1" in
"-t") display_currently_playing_track ;;
*) ;;
esac

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
