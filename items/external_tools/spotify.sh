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
    # shellcheck source=scripts/helpers.sh
    . "$D_TM_BASE_PATH"/scripts/helpers.sh

    spotify status >/dev/null 2>&1

    track="$(spotify status track)"
    artist="$(spotify status artist)"
    album="$(spotify status album)"

    tmux_error_handler display-message "$track - Artist: $artist - Album: $album"
    exit 0
}

static_content() {

    # reload_no_output=" >/dev/null ; $0"

    [ -z "$(command -v spotify)" ] && error_msg "spotify bin not found!"

    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E t "Title - currently playing track" "$0 -t ; $0" \
        0.0 S \
        0.0 E Space "Pause/Resume" "spotify pause   ; $0" \
        0.0 E n "Next" "spotify             next  ; $0" \
        0.0 E p "Prev" "spotify             prev  ; $0" \
        0.0 E r "Replay" "spotify           replay  ; $0" \
        0.0 E s "Shuffle - toggle" "spotify toggle shuffle  ; $0" \
        0.0 E R "Repeat  - toggle" "spotify toggle repeat  ; $0" \
        0.0 E u "vol Up" "spotify           vol up  ; $0" \
        0.0 E d "vol Down" "spotify         vol down  ; $0" \
        0.0 E i "Copy URI to clipboard" "spotify share uri  ; $0" \
        0.0 E l "Copy URL to clipboard" "spotify share url  ; $0"
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
