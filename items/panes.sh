#!/bin/sh
#  shellcheck disable=SC2034,SC2154
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

dynamic_content() {
    # Things that change dependent on various states

    new_mark_state="$($TMUX_BIN display -p '#{?pane_marked,Unmark,Mark}')"
    new_sync_state="$($TMUX_BIN display -p '#{?pane_synchronized,Disable,Activate}')"

    # dynamic -2
    if [ "$($TMUX_BIN display -p '#{window_zoomed_flag}')" -eq 0 ]; then
        zoom_action="Zoom"
    else
        zoom_action="Un-Zoom"
    fi

    set -- \
        2.0 C z "<P> $zoom_action pane" "resize-pane -Z $menu_reload" \
        2.1 C m "<P> $new_mark_state current pane" "select-pane -m $menu_reload" \
        1.9 C y "$new_sync_state synchronized panes" "set -w synchronize-panes"

    menu_generate_part 2 "$@"
}

static_content() {
    menu_name="Handling Pane"
    req_win_width=38
    req_win_height=23

    # # f_cache_file_panes="${f_cache_file}-panes"
    # zoom_action_placeholder="===Zoom-or-UnZoom==="

    # static - 1
    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 M M "Move pane         -->" pane_move.sh \
        0.0 M R "Resize pane       -->" pane_resize.sh \
        0.0 S \
        2.6 C t " Set Title" "command-prompt -I '#T'  -p 'Title: '  \
            'select-pane -T \"%%\"' $menu_reload" \
        2.6 C c " Clear history & screen" \
        "send-keys C-l ; run 'sleep 0.3' ; clear-history" \
        1.7 C q "<P> Display pane numbers" "display-panes $menu_reload" \
        1.8 C "[" '<P> Copy mode - "history"' "copy-mode" \
        1.7 C s " Display pane size" "display-message \
            'Pane: #P size: #{pane_width}x#{pane_height}' $menu_reload"

    menu_generate_part 1 "$@"

    # static -3
    set -- \
        0.0 S \
        2.0 C h "Save pane history no escapes" "command-prompt -p \
            'Save to (no escapes):' -I '~/tmux.history' \
            'capture-pane -S - -E - ; save-buffer %1 ; delete-buffer'" \
        2.0 C e "Save pane history with escapes" "command-prompt -p \
            'Save to (with escapes):' -I '~/tmux.history' \
            'capture-pane -S - -E - -e ; save-buffer %1 ; delete-buffer'" \
        0.0 S \
        2.0 C r " Respawn current pane" "confirm-before -p \
            'respawn-pane #P? (y/n)' 'respawn-pane -k'" \
        2.0 C x "<P> Kill current pane" "confirm-before -p \
            'kill-pane #T (#P)? (y/n)' kill-pane" \
        2.0 C o "  Kill all other panes" "confirm-before -p \
            'Are you sure you want to kill all other panes? (y/n)' \
            'kill-pane -a'" \
        0.0 S \
        0.0 M H 'Help -->' "$D_TM_ITEMS/help_panes.sh $current_script"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

#  Source dialog handling script
# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
