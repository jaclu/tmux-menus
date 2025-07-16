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
        0.0 E 1 "Send ì" "$0  ì" \
        0.0 E a "Send Ì" "$0  Ì" \
        0.0 E 2 "Send í" "$0  í" \
        0.0 E b "Send Í" "$0  Í" \
        0.0 E 3 "Send î" "$0  î" \
        0.0 E c "Send Î" "$0  Î" \
        0.0 E 4 "Send ï" "$0  ï" \
        0.0 E d "Send Ï" "$0  Ï" \
        0.0 E 5 "Send ǐ" "$0  ǐ" \
        0.0 E e "Send Ǐ" "$0  Ǐ" \
        0.0 E 6 "Send ĩ" "$0  ĩ" \
        0.0 E f "Send Ĩ" "$0  Ĩ" \
        0.0 E 7 "Send ī" "$0  ī" \
        0.0 E g "Send Ī" "$0  Ī" \
        0.0 E 8 "Send ı" "$0  ı" \
        0.0 E h "Send İ" "$0  İ" \
        0.0 E 9 "Send į" "$0  į" \
        0.0 E i "Send Į" "$0  Į"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - i I"

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
