#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
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
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 C r "Rename" "command-prompt -I '#{session_name}' \
            'rename-session -- \"%%\"' $runshell_reload_mnu" \
        0.0 C s "New" "command-prompt -p \
            'Name of new: ' \
            'new-session -d -s \"%1\" ; switch-client -t \"%1\"' $runshell_reload_mnu" \
        0.0 S \
        0.0 C l "Last selected" "switch-client -l        $runshell_reload_mnu" \
        0.0 C p "Previous" "switch-client -p  $runshell_reload_mnu" \
        0.0 C n "Next" "switch-client -n  $runshell_reload_mnu" \
        2.7 C c "Choose" "choose-tree -Zs" \
        0.0 S \
        1.8 C x "${cfg_danger_zone}Kill current" \
        "confirm-before -p \
        'Are you sure you want to kill this: [#S] (y/n)' \
        \"$cli_dtch_mode ; kill-session\" $runshell_reload_mnu" \
        1.8 C o "${cfg_danger_zone}Kill all other" "confirm-before -p \
        'Are you sure you want to kill all other? (y/n)' \
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

menu_name="Handling Sessions"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
