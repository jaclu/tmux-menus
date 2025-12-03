#!/bin/sh
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Split display
#

static_content() {
    if [ -d "$HOME"/tmp ]; then
        d_history="$HOME"/tmp
    else
        d_history="$d_tmp"
    fi
    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Handling Pane  $nav_prev" panes.sh \
        0.0 M Home "Back to Main menu      $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    #
    set -- \
        0.0 S \
        0.0 E c "Clear screen & history" "$d_scripts/act_clear_screen.sh $rn_current_script" \
        0.0 C h 'Pane history (enter \"copy mode\")' "copy-mode" \
        2.0 C s "Save pane history no escapes" "command-prompt -p \
            'Save to (no escapes):' -I '$d_history/tmux-history' \
            'capture-pane -S - -E - ; save-buffer %1 ; delete-buffer'  $runshell_reload_mnu" \
        2.0 C e "Save pane history with escapes" "command-prompt -p \
            'Save to (with escapes):' -I '$d_history/tmux-history-escapes' \
            'capture-pane -S - -E - -e ; save-buffer %1 ; delete-buffer' $runshell_reload_mnu" \
        0.0 S \
        0.0 M H "Help                   $nav_next" "$d_help/help_pane_history.sh $0"
    menu_generate_part 3 "$@"
    unset d_history
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Pane History"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
