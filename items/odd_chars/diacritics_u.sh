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
        0.0 E 1 "Send ù" "$0  ù" \
        0.0 E a "Send Ù" "$0  Ù" \
        0.0 E 2 "Send ú" "$0  ú" \
        0.0 E b "Send Ú" "$0  Ú" \
        0.0 E 3 "Send û" "$0  û" \
        0.0 E c "Send Û" "$0  Û" \
        0.0 E 4 "Send ü" "$0  ü" \
        0.0 E d "Send Ü" "$0  Ü" \
        0.0 E 5 "Send ǔ" "$0  ǔ" \
        0.0 E e "Send Ǔ" "$0  Ǔ" \
        0.0 E 6 "Send ũ" "$0  ũ" \
        0.0 E f "Send Ũ" "$0  Ũ" \
        0.0 E 7 "Send ū" "$0  ū" \
        0.0 E g "Send Ū" "$0  Ū" \
        0.0 E 8 "Send ű" "$0  ű" \
        0.0 E h "Send Ű" "$0  Ű" \
        0.0 E 9 "Send ů" "$0  ů" \
        0.0 E i "Send Ů" "$0  Ů"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - u U"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

no_auto_dialog_handling=1 # delay processing of dialog, only source it for now
# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

if [ -n "$1" ]; then
    "$D_TM_BASE_PATH"/scripts/act_display_char.sh "$1"
elif $cfg_use_whiptail; then
    source_all_helpers "Clear missing_keys buffer: $wt_pasting"
    tmux_error_handler set-option -gqu "$wt_pasting"
fi

# manually trigger dialog handling
do_dialog_handling
