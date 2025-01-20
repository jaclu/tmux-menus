#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

static_content() {
    if [ -d "$HOME"/tmp ]; then
        d_history="$HOME"/tmp
    else
        d_history="$d_tmp"
    fi
    set -- \
        0.0 M Left "Back to Main menu    $nav_home" main.sh \
        0.0 M M "Move pane            $nav_next" pane_move.sh \
        0.0 M R "Resize pane          $nav_next" pane_resize.sh \
        0.0 S \
        1.8 C z "Toggle pane zoom" "resize-pane -Z $menu_reload" \
        2.1 C m "Toggle mark current pane" "select-pane -m $menu_reload" \
        1.9 C y "Toggle synchronized panes" "set -w synchronize-panes $menu_reload" \
        2.6 C c "Clear screen & history" \
        "send-keys C-l ; run 'sleep 0.3' ; clear-history" \
        1.8 C h 'history (enter \"copy mode\")' "copy-mode" \
        2.6 C t "Set Pane Title" "command-prompt -I '#T'  -p 'Title: '  \
            'select-pane -T \"%%\"' $menu_reload" \
        1.7 C n "Display pane numbers" "display-panes $menu_reload" \
        1.7 C d "Display pane size" "display-message \
            'Pane: #P size: #{pane_width}x#{pane_height}' $menu_reload" \
        0.0 S \
        2.0 C s "Save pane history no escapes" "command-prompt -p \
            'Save to (no escapes):' -I '$d_history/tmux-history' \
            'capture-pane -S - -E - ; save-buffer %1 ; delete-buffer'" \
        2.0 C e "Save pane history with escapes" "command-prompt -p \
            'Save to (with escapes):' -I '$d_history/tmux-history-escapes' \
            'capture-pane -S - -E - -e ; save-buffer %1 ; delete-buffer'" \
        0.0 S \
        2.0 C r "Respawn current pane" "confirm-before -p \
            'respawn-pane #P? (y/n)' 'respawn-pane -k'" \
        2.0 C x "Kill current pane" "confirm-before -p \
            'kill-pane #T (#P)? (y/n)' kill-pane" \
        2.0 C o "Kill all other panes" "confirm-before -p \
            'Are you sure you want to kill all other panes? (y/n)' \
            'kill-pane -a'" \
        0.0 S \
        0.0 M H "Help $nav_next" "$d_help/help_panes.sh $f_current_script"

    menu_generate_part 1 "$@"
    unset d_history
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Pane"
# window_width=38
# window_height=23

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
