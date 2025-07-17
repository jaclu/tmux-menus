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
        0.0 E 1 "Send à" "$0  à" \
        0.0 E a "Send À" "$0  À" \
        0.0 E 2 "Send á" "$0  á" \
        0.0 E b "Send Á" "$0  Á" \
        0.0 E 3 "Send â" "$0  â" \
        0.0 E c "Send Â" "$0  Â" \
        0.0 E 4 "Send ä" "$0  ä" \
        0.0 E d "Send Ä" "$0  Ä" \
        0.0 E 5 "Send ǎ" "$0  ǎ" \
        0.0 E e "Send Ǎ" "$0  Ǎ" \
        0.0 E 6 "Send æ" "$0  æ" \
        0.0 E f "Send Æ" "$0  Æ" \
        0.0 E 7 "Send ã" "$0  ã" \
        0.0 E g "Send Ã" "$0  Ã" \
        0.0 E 8 "Send å" "$0  å" \
        0.0 E h "Send Å" "$0  Å" \
        0.0 E 9 "Send ā" "$0  ā" \
        0.0 E i "Send Ā" "$0  Ā"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - a A"

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
