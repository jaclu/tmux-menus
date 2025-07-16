#!/bin/sh
#
#  Copyright (c) 2025-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Sending currency symbolsx that might not always be accessible,
#  depending on keyboards or their mappings.
#

show_label() {
    # Some Currency symbols can't be printed in whiptail
    if $cfg_use_whiptail; then
        case "$1" in
        ₺ | ₴ | ₽ | ₹ | ₿)
            echo "Send   ($2) - not printable in whiptail"
            ;;
        *)
            echo "Send $1 ($2)"
            ;;
        esac
    else
        echo "Send $1 ($2)"
    fi
}

static_content() {

    tmux_vers_check 2.0 || error_msg "needs tmux 2.0"

    set -- \
        0.0 M Left "Back to Missing Keys  $nav_prev" "$d_odd_chars"/missing_keys.sh \
        0.0 M Home "Back to Main menu     $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E b "$(show_label ฿ baht)" "$0 ฿" \
        0.0 E B "$(show_label ₿ bitcoin)" "$0 \u20BF" \
        0.0 E c "$(show_label ¢ Cent)" "$0 ¢" \
        0.0 E e "$(show_label € euro)" "$0 €" \
        0.0 E h "$(show_label ₴ hryvnia)" "$0 ₴" \
        0.0 E l "$(show_label ₺ lira)" "$0 ₺" \
        0.0 E p "$(show_label £ pound)" "$0 £" \
        0.0 E i "$(show_label ៛ riel)" "$0 ៛" \
        0.0 E r "$(show_label ₽ rubel)" "$0 ₽" \
        0.0 E R "$(show_label ₹ rupee)" "$0 ₹" \
        0.0 E s "$(show_label ₪ shekel)" "$0 ₪" \
        0.0 E w "$(show_label ₩ won)" "$0 ₩" \
        0.0 E y "$(show_label ¥ yen/yuan)" "$0 ¥" \
        0.0 E z "$(show_label zł zloty)" "$0 zł" \
        0.0 S \
        0.0 M H "Help                  $nav_next" "$d_help/help_currencies.sh $0"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Currency symbols"
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
