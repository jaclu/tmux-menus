#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
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
    cli_dtch_mode="set-option -s detach-on-destroy $_s"

    set -- \
        0.0 M Left "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 C r "Rename this session" "command-prompt -I '#{session_name}' \
            'rename-session -- \"%%\"' $runshell_reload_mnu" \
        0.0 C \+ "New session" "command-prompt -p \
            'Name of new session: ' \
            'new-session -d -s \"%1\" ; switch-client -t \"%1\"' $runshell_reload_mnu" \
        0.0 S \
        0.0 C l "Last selected session" "switch-client -l $runshell_reload_mnu" \
        0.0 C p "Previous session [in order]" "switch-client -p $runshell_reload_mnu" \
        0.0 C n "Next     session [in order]" "switch-client -n $runshell_reload_mnu" \
        0.0 S \
        1.8 C x "Kill current session" \
        "confirm-before -p \
        'Are you sure you want to kill this session: [#S] (y/n)' \
        \"$cli_dtch_mode ; kill-session\" $runshell_reload_mnu" \
        1.8 C o "Kill all other sessions" "confirm-before -p \
        'Are you sure you want to kill all other sessions? (y/n)' \
        \"kill-session -a\" $runshell_reload_mnu"
    menu_generate_part 3 "$@"
}


# menus: "switch-client -n  ; run-shell /Users/jaclu/git_repos/mine/tmux-menus/items/sessions.sh"
# whiptail:
# tmux_error_handler switch-client -n  \; run-shell '/Users/jaclu/git_repos/mine/tmux-menus/scripts/external_dialog_trigger.sh /Users/jaclu/git_repos/mine/tmux-menus/items/sessions.sh'

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Session"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
