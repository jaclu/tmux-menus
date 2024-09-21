#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling Sessions
#

static_content() {

    if tmux_vers_check 3.2; then
        _s="no-detached"
    else
        _s="off"
    fi
    cli_dtch_mode="set -s detach-on-destroy $_s"

    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 S \
        0.0 C r "Rename this session" "command-prompt -I '#S' \
            'rename-session -- \"%%\"'" \
        0.0 C \+ "New session" "command-prompt -p \
            'Name of new session: ' \
            'new-session -d -s \"%1\" ; switch-client -t \"%1\"'" \
        0.0 S \
        0.0 C l "Last selected session" "switch-client -l $menu_reload" \
        0.0 C p "Previous session [in order]" "switch-client -p $menu_reload" \
        0.0 C n "Next     session [in order]" "switch-client -n $menu_reload" \
        0.0 S \
        1.8 C x "Kill current session" \
        "confirm-before -p \
        'Are you sure you want to kill this session? (y/n)' \
        '$cli_dtch_mode ; kill-session'" \
        1.8 C o "Kill all other sessions" "confirm-before -p \
        'Are you sure you want to kill all other sessions? (y/n)' \
        'kill-session -a'" \
        0.0 S \
        0.0 M H "Help -->" "$d_items/help.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Session"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
