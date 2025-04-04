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
        ₺ | ₴ | ₽ | ₹)
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

    tmux_vers_check 2.0 || error_msg_safe "needs tmux 2.0"

    set -- \
        0.0 M Left "Back to Missing Keys  $nav_prev" missing_keys.sh \
        0.0 M Home "Back to Main menu     $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S

    # how to print?
    # ₿ (bitcoin)

    set -- "$@" \
        0.0 E b "$(show_label ฿ baht)" "$0 ฿" \
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
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers_minimal.sh
. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

if [ -n "$1" ]; then
    "$d_scripts"/act_display_char.sh "$1"
    # handle_char "$1"
elif $cfg_use_whiptail; then
    #
    #  As long as this menu is restarted with a char param
    #  it is added to the paste buffer if whiptail is used,
    #  as soon as it is called without a param this buffer is reset
    #
    $TMUX_BIN set-option -gqu "$wt_pasting" 2>/dev/null # ignore error if not set
fi

# shellcheck source=scripts/dialog_handling.sh
. "$d_scripts"/dialog_handling.sh
