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
        0.0 E 1 "Send ł" "$0  ł" \
        0.0 E a "Send Ł" "$0  Ł" \
        0.0 E 2 "Send ļ" "$0  ļ" \
        0.0 E b "Send Ļ" "$0  Ļ" \
        0.0 E 3 "Send ľ" "$0  ľ" \
        0.0 E c "Send Ľ" "$0  Ľ"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - l L"

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
