#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

#  shellcheck disable=SC1091,SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

. "$SCRIPT_DIR/utils.sh"

. "$SCRIPT_DIR/dialog_handling.sh"

title="command-prompt -I '#T'  -p 'Title: '  'select-pane -T \"%%\"'"
pane_size="display-message 'Pane: #P size: #{pane_width}x#{pane_height}'"

new_mark_state="$(tmux display -p '#{?pane_marked,Unmark,Mark}')"
new_sync_state="$(tmux display -p '#{?pane_synchronized,Disable,Activate}')"
#
#  adding -e to capture-pane saves escape sequences, but then less/most fails
#  to display, cat/bat history-file will display the included colors correctly.
#
set -- "command-prompt -p 'Save to (no escapes):' -I '~/tmux.history'" \
    "'capture-pane -S - -E - ; save-buffer %1 ; delete-buffer'"
hist_no_esc="$*"

set -- "command-prompt -p 'Save to (with escapes):' -I '~/tmux.history'" \
    "'capture-pane -S - -E - -e ; save-buffer %1 ; delete-buffer'"
hist_w_esc="$*"

respawn="confirm-before -p 'respawn-pane #P? (y/n)' 'respawn-pane -k'"
kill_this="confirm-before -p 'kill-pane #T (#P)? (y/n)' kill-pane"
#
#  Slightly weird, I can't get line continuation passed shellcheck on this
#  one, so have to revert to multi step assignment
#
kill_others="confirm-before -p 'Are you sure you want to kill "
kill_others="$kill_others all other panes? (y/n)' 'kill-pane -a'"

menu_name="Handling Pane"

#  shellcheck disable=SC2154
set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 M M "Move pane             -->" pane_move.sh \
    0.0 M R "Resize pane           -->" pane_resize.sh \
    2.0 M B "Paste buffers         -->" pane_buffers.sh \
    0.0 S \
    2.6 C t "    Set Title" "$title $menu_reload" \
    1.8 C z "<P> Zoom pane toggle" "resize-pane -Z $menu_reload" \
    1.7 C q "<P> Display pane numbers" "display-panes $menu_reload" \
    2.0 C "[" '<P> Copy mode - "history"' "copy-mode" \
    2.1 C m "<P> $new_mark_state current pane" "select-pane -m $menu_reload" \
    1.7 C s "    Display pane size" "$pane_size $menu_reload" \
    0.0 S \
    1.9 C y " $new_sync_state synchronized panes" "set -w synchronize-panes" \
    2.0 C h "Save pane history no escapes" "$hist_no_esc" \
    2.0 C e "Save pane history with escapes" "$hist_w_esc" \
    0.0 S \
    2.0 C r "    Respawn current pane" "$respawn" \
    2.0 C x "<P> Kill current pane" "$kill_this" \
    2.0 C o "    Kill all other panes" "$kill_others" \
    0.0 S \
    0.0 M H 'Help  -->' "$CURRENT_DIR/help_panes.sh $current_script"

req_win_width=38
req_win_height=23

parse_menu "$@"
