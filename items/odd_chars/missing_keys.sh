#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Sending keys that might not always be accessible, depending on
#  keyboards or their mappings.
#
#  Especially when using tablets with keyboards, the number row might
#  be mapped to function keys, thus blocking several keys.
#  For some, me included. It is often quicker to use a menu to generate
#  missing keys, vs fiddling with cut and paste from some other source
#  for such keys.
#

static_content() {
    #
    #  It doesn't seem possible to reliably display an actual backtick in menus...
    #  on some platforms it works, on others it breaks this menu
    #
    set -- \
        0.0 M Left "Back to Main menu  $nav_home" main.sh \
        2.0 M C "Currencies         $nav_next" "$d_odd_chars"/currencies.sh \
        0.0 M D "Diacritics         $nav_next" "$d_odd_chars"/diacritics.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E e "Send Escape" "$0  0x1b" \
        0.0 E b "Send back-tick" "$0  0x60" \
        0.0 E t "Send ~ (tilde)" "$0  0x7e" \
        0.0 E a "Send @ (at)" "$0 @" \
        0.0 E p "Send § (paragraph)" "$0 §" \
        0.0 E h "Send # (hash)" "$0 0x23" \
        0.0 S \
        0.0 M H "Help               $nav_next" "$d_help/help_missing_keys.sh $0"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Missing Keys"
menu_min_vers=2.0

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
