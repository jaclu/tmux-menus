#!/bin/sh
#
#  Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Offering all diacritic variants of one letter.
#

static_content() {
    set -- \
        0.0 M Left "Back to Diacritics  $nav_home" "$d_odd_chars"/diacritics.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E 1 "Send ď" "$0  ď" \
        0.0 E a "Send Ď" "$0  Ď" \
        0.0 E 2 "Send ð" "$0  ð" \
        0.0 E b "Send Ð" "$0  Ð"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - d D"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

if [ -n "$1" ]; then
    "$d_scripts"/act_display_char.sh "$1"
elif $cfg_use_whiptail; then
    #
    #  wt_pasting is a hint that the current paste buffer is used to store
    #  one or more keys for late pasting
    #
    tmux_error_handler set-option -gqu "$wt_pasting"
fi

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
