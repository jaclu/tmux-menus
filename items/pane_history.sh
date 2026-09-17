#!/bin/sh
#
#   Copyright (c) 2025-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Split display
#

static_content() {
    if [ -d "$HOME"/tmp ]; then
        _d_history="$HOME"/tmp
    else
        _d_history="$d_tmp"
    fi

    set -- \
        0.0 M Left "Back to Previous  $nav_prev" panes.sh \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 M H "Help              $nav_next" "$d_help/h_pane_history.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    cmd="capture-pane -J -S - -E -"
    set -- \
        0.0 S \
        0.0 C h 'History (enter copy mode)' "copy-mode" \
        2.0 C s "Save (no escapes)" "command-prompt -p \
            'Save to (no escapes):' -I '$_d_history/tmux-history' \
            '$cmd ; save-buffer %1 ; delete-buffer'  $runshell_reload_mnu" \
        2.0 C e "Save (with escapes)" "command-prompt -p \
            'Save to (with escapes):' -I '$_d_history/tmux-history-escapes' \
            '$cmd -e ; save-buffer %1 ; delete-buffer' $runshell_reload_mnu" \
        3.8 C t "Save (with timestamps)" "command-prompt -p \
            'Save to (with timestamps):' -I '$_d_history/tmux-history-timestamps' \
            '$cmd -I ; save-buffer %1 ; delete-buffer' $runshell_reload_mnu" \
        0.0 S \
        3.8 C r "Copy Mode Refresh - Enable" "send-keys -X refresh-on" \
        3.8 C o "Copy Mode Refresh - Disable" "send-keys -X refresh-off" \
        3.8 C g "Copy Mode Refresh - Toggle" "send-keys -X refresh-toggle" \
        3.8 C n "Copy Mode - Refresh now" "send-keys -X refresh-now" \
        0.0 E c "${cfg_danger_zone}Clear all" "$d_scripts/act_clear_screen.sh $0"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Pane History"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
