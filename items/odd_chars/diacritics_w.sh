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
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E 1 "Send ŵ" "$0  ŵ" \
        0.0 E a "Send Ŵ" "$0  Ŵ"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics - w W"

no_auto_menu_handling=1 # delay processing of dialog, only source it for now

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh

if [ -n "$1" ]; then
    "$TMUX_MENUS_LOCATION"/scripts/act_display_char.sh "$1"
elif [ -n "$alt_menu_handler" ]; then
    ${b_all_helpers_sourced:-false} || source_all_helpers "diacritics_w.sh"
    tmux_error_handler set-option -gqu "$wt_pasting"
fi

# manually trigger dialog handling
do_menu_handling
