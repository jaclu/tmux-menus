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
    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Diacritics  $nav_home" "$d_odd_chars"/diacritics.sh \
        0.0 M Home "Back to Main menu  $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E 1 "Send ź" "$0  ź" \
        0.0 E a "Send Ź" "$0  Ź" \
        0.0 E 2 "Send ž" "$0  ž" \
        0.0 E b "Send Ž" "$0  Ž" \
        0.0 E 3 "Send ż" "$0  ż" \
        0.0 E c "Send Ż" "$0  Ż"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - z Z"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/../.." && pwd)

no_auto_dialog_handling=1 # delay processing of dialog, only source it for now
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

if [ -n "$1" ]; then
    "$D_TM_BASE_PATH"/scripts/act_display_char.sh "$1"
elif $cfg_use_whiptail; then
    tmux_error_handler set-option -gqu "$wt_pasting"
fi

# manually trigger dialog handling
do_dialog_handling
