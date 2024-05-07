#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  THIS DOES NOT WORK RIGHT NOW!
#
#  I havent had time to update it to use dynamic menus...
#
#   Live configuration. So far only menu location is available
#
#   THIS IS NOT USED ATM!
#

static_content() {

    error_msg "THIS IS NOT USED ATM!"

    menu_name="Configure Menu Location"

    change_location="run-shell '$d_scripts/move_menu.sh"

    #
    #  The -p sequence will get wrecked by lnie breaks,
    #  so left as one annoyingly long line
    #
    # prompt1="horizontal pos (max: #{window_width}):"
    # prompt2="vertical pos (max: #{window_height}):"

    # set -- "command-prompt" \
    #     "-I \"$location_x\",\"$location_y\"" \
    #     "-p \"$prompt1\",\"$prompt2\"" \
    #     "\"$change_location coord %1 %2 $reload_in_runshell'\""
    # set_coordinates="$*"

    set -- "$@" \
        0.0 M Left "Back to Previous menu <--" advanced.sh \
        0.0 S \
        0.0 C c "Center" "$change_location  C  $reload_in_runshell'"
    # 0.0 E r "win Right edge" "$change_location  R  $reload_in_runshell'" \
    # 0.0 E p "Pane bottom left" "$change_location  P  $reload_in_runshell'" \
    # 0.0 E w "Win pos status line" "$change_location  W  $reload_in_runshell'" \
    # 0.0 S \
    # 0.0 C s "set coordinates" "$set_coordinates" \
    # 0.0 S \
    # 0.0 T "-When using coordinates" \
    # 0.0 T "-lower left corner is set!"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "><> $current_script exiting [$e]"
fi
