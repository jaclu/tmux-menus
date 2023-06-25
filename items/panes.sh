#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

#  shellcheck disable=SC1091,SC2034,SC2154
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

. "$SCRIPT_DIR/utils.sh"

. "$SCRIPT_DIR/dialog_handling.sh"

new_mark_state="$($TMUX_BIN display -p '#{?pane_marked,Unmark,Mark}')"
new_sync_state="$($TMUX_BIN display -p '#{?pane_synchronized,Disable,Activate}')"

menu_name="Handling Pane"

set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 M M "Move pane             -->" pane_move.sh \
    0.0 M R "Resize pane           -->" pane_resize.sh \
    2.0 M B "Paste buffers         -->" pane_buffers.sh \
    0.0 S \
    2.6 C t "    Set Title" "command-prompt -I '#T'  -p 'Title: '  \
        'select-pane -T \"%%\"' $menu_reload" \
    1.8 C z "<P> Zoom pane toggle" "resize-pane -Z $menu_reload" \
    1.7 C q "<P> Display pane numbers" "display-panes $menu_reload" \
    1.8 C "[" '<P> Copy mode - "history"' "copy-mode" \
    2.1 C m "<P> $new_mark_state current pane" "select-pane -m $menu_reload" \
    1.7 C s "    Display pane size" "display-message \
        'Pane: #P size: #{pane_width}x#{pane_height}' $menu_reload" \
    0.0 S \
    1.9 C y " $new_sync_state synchronized panes" "set -w synchronize-panes" \
    2.0 C h "Save pane history no escapes" "command-prompt -p \
        'Save to (no escapes):' -I '~/tmux.history' \
        'capture-pane -S - -E - ; save-buffer %1 ; delete-buffer'" \
    2.0 C e "Save pane history with escapes" "command-prompt -p \
        'Save to (with escapes):' -I '~/tmux.history' \
        'capture-pane -S - -E - -e ; save-buffer %1 ; delete-buffer'" \
    0.0 S \
    2.0 C r "    Respawn current pane" "confirm-before -p \
        'respawn-pane #P? (y/n)' 'respawn-pane -k'" \
    2.0 C x "<P> Kill current pane" "confirm-before -p \
        'kill-pane #T (#P)? (y/n)' kill-pane" \
    2.0 C o "    Kill all other panes" "confirm-before -p \
        'Are you sure you want to kill all other panes? (y/n)' \
        'kill-pane -a'" \
    0.0 S \
    0.0 M H 'Help  -->' "$CURRENT_DIR/help_panes.sh $current_script"

req_win_width=38
req_win_height=23

menu_parse "$@"
