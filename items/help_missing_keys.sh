#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

static_content() {

    set -- \
        0.0 M Left "Back to Previous menu <--" "$prev_menu" \
        0.0 S \
        0.0 T "-#[nodim]Use this to send keys that might" \
        0.0 T "-#[nodim]not be available with the current" \
        0.0 T "-#[nodim]keyboard settings."
 
    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        set -- "$@" \
            0.0 T " " \
            0.0 T "When using whiptail it is not possible" \
            0.0 T "to paste directly into the pane." \
            0.0 T "Instead a tmux buffer is used." \
            0.0 T " " \
            0.0 T "Plese note that this buffer might become" \
            0.0 T "invalid if another menu is selected" \
            0.0 T "before pasting!" \
            0.0 T " " \
            0.0 T "Once you have selected one or more keys," \
            0.0 T "cancel this menu. Once back in your pane," \
            0.0 T "use <prefix> ] to paste the key(-s)."
    fi

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

prev_menu="$1"
menu_name="Help Missing Keys"

if [ -z "$prev_menu" ]; then
    error_msg "help_split.sh was called without notice of what called it"
fi

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
