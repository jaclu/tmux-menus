#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

dynamic_content() {
    # Things that change dependent on various states

    new_mark_state="$(tmux_error_handler display -p '#{?pane_marked,Unmark,Mark}')"
    new_sync_state="$(tmux_error_handler display -p '#{?pane_synchronized,Disable,Activate}')"

    # dynamic -2
    if [ "$(tmux_error_handler display -p '#{window_zoomed_flag}')" -eq 0 ]; then
        zoom_action="Zoom"
    else
        zoom_action="Un-Zoom"
    fi

    set -- \
        1.8 C z "$zoom_action pane" "resize-pane -Z $menu_reload" \
        2.1 C m "$new_mark_state current pane" "select-pane -m $menu_reload" \
        1.9 C y "$new_sync_state synchronized panes" "set -w synchronize-panes"

    menu_generate_part 2 "$@"
}

static_content() {

    # # f_cache_file_panes="${f_cache_file}-panes"
    # zoom_action_placeholder="===Zoom-or-UnZoom==="

    # static - 1
    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 M M "Move pane         -->" pane_move.sh \
        0.0 M R "Resize pane       -->" pane_resize.sh \
        0.0 S

    menu_generate_part 1 "$@"

    # static -3
    set -- \
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
            'Save to (no escapes):' -I '~/tmux.history' \
            'capture-pane -S - -E - ; save-buffer %1 ; delete-buffer'" \
        2.0 C e "Save pane history with escapes" "command-prompt -p \
            'Save to (with escapes):' -I '~/tmux.history' \
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
        0.0 M H 'Help -->' "$d_items/help_panes.sh $f_current_script"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Pane"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
