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
        0.0 M Left "Back to Previous  $nav_home" odd_chars/diacritics.sh \
        0.0 M Home "Main Menu         $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

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

no_auto_menu_handling=1 # delay processing of dialog, only source it for now

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh

if [ -n "$1" ]; then
    "$TMUX_MENUS_LOCATION"/scripts/act_display_char.sh "$1"
elif [ -n "$alt_menu_handler" ]; then
    ${b_all_helpers_sourced:-false} || source_all_helpers "diacritics_z.sh"
    tmux_error_handler set-option -gqu "$wt_pasting"
fi

# manually trigger dialog handling
do_menu_handling
