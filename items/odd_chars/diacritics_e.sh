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
        0.0 E 1 "Send è" "$0  è" \
        0.0 E a "Send È" "$0  È" \
        0.0 E 2 "Send é" "$0  é" \
        0.0 E b "Send É" "$0  É" \
        0.0 E 3 "Send ê" "$0  ê" \
        0.0 E c "Send Ê" "$0  Ê" \
        0.0 E 4 "Send ë" "$0  ë" \
        0.0 E d "Send Ë" "$0  Ë" \
        0.0 E 5 "Send ě" "$0  ě" \
        0.0 E e "Send Ě" "$0  Ě" \
        0.0 E 6 "Send ẽ" "$0  ẽ" \
        0.0 E f "Send Ẽ" "$0  Ẽ" \
        0.0 E 7 "Send ē" "$0  ē" \
        0.0 E g "Send Ē" "$0  Ē" \
        0.0 E 8 "Send ė" "$0  ė" \
        0.0 E h "Send Ė" "$0  Ė" \
        0.0 E 9 "Send ę" "$0  ę" \
        0.0 E i "Send Ę" "$0  Ę"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - e E"

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
