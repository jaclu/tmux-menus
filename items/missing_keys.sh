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
        0.0 M C "Currencies         $nav_next" currencies.sh
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
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
