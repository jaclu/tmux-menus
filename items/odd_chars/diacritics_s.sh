#!/bin/sh
#
#  Copyright (c) 2025-2026: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Offering all diacritic variants of one letter.
#

static_content() {
    set -- \
        0.0 M Left "Back to Previous  $nav_home" "$d_odd_chars"/diacritics.sh \
        0.0 M Home "Main Menu         $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E 1 "Send ß" "$0  ß" \
        0.0 E a "Send ẞ" "$0  ẞ" \
        0.0 E 2 "Send ş" "$0  ş" \
        0.0 E b "Send Ś" "$0  Ś" \
        0.0 E 3 "Send ș" "$0  ș" \
        0.0 E c "Send Š" "$0  Š" \
        0.0 E 4 "Send ś" "$0  ś" \
        0.0 E d "Send Ş" "$0  Ş" \
        0.0 E 5 "Send š" "$0  š" \
        0.0 E e "Send Ș" "$0  Ș"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - s S"

no_auto_menu_handling=1 # delay processing of dialog, only source it for now

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh

if [ -n "$1" ]; then
    "$TMUX_MENUS_LOCATION"/scripts/act_display_char.sh "$1"
elif [ -n "$alt_menu_handler" ]; then
    ${b_all_helpers_sourced:-false} || source_all_helpers "diacritics_s.sh"
    tmux_error_handler set-option -gqu "$wt_pasting"
fi

# manually trigger dialog handling
do_menu_handling
