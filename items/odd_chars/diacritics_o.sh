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
        0.0 E 1 "Send ò" "$0  ò" \
        0.0 E a "Send Ò" "$0  Ò" \
        0.0 E 2 "Send ó" "$0  ó" \
        0.0 E b "Send Ó" "$0  Ó" \
        0.0 E 3 "Send ô" "$0  ô" \
        0.0 E c "Send Ô" "$0  Ô" \
        0.0 E 4 "Send ö" "$0  ö" \
        0.0 E d "Send Ö" "$0  Ö" \
        0.0 E 5 "Send ǒ" "$0  ǒ" \
        0.0 E e "Send Ǒ" "$0  Ǒ" \
        0.0 E 6 "Send œ" "$0  œ" \
        0.0 E f "Send Œ" "$0  Œ" \
        0.0 E 7 "Send ø" "$0  ø" \
        0.0 E g "Send Ø" "$0  Ø" \
        0.0 E 8 "Send õ" "$0  õ" \
        0.0 E h "Send Õ" "$0  Õ" \
        0.0 E 9 "Send ō" "$0  ō" \
        0.0 E i "Send Ō" "$0  Ō"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - o O"

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
