#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.8 2022-06-08
#
#   Handling pane
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Handling Pane"
req_win_width=38
req_win_height=23


this_menu="$CURRENT_DIR/panes.sh"
reload="; run-shell '$this_menu'"
open_menu="run-shell '$CURRENT_DIR"

title="command-prompt -I '#T'  -p 'Title: '  'select-pane -T \"%%\"'"
pane_size="display-message 'Pane: #P size: #{pane_width}x#{pane_height}'"

#
#  adding -e to capture-pane saves escape sequences, but then less/most fails
#  to display, cat/bat history-file will display the included colors correctly.
#
set --  "command-prompt -p 'Save to (no escapes):' -I '~/tmux.history'"  \
        "'capture-pane -S - -E - ; save-buffer %1 ; delete-buffer'"
hist_no_esc="$*"

set --  "command-prompt -p 'Save to (with escapes):' -I '~/tmux.history'"  \
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


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                           \
    -T "#[align=centre] Handling Pane "                                     \
    -x "$menu_location_x" -y "$menu_location_y"                             \
                                                                            \
    "Back to Main menu"   Left  "$open_menu/main.sh'"                       \
    "Move pane      -->"  M     "$open_menu/pane_move.sh'"                  \
    "Resize pane    -->"  R     "$open_menu/pane_resize.sh'"                \
    "Paste buffers  -->"  B     "$open_menu/pane_buffers.sh'"               \
    ""                                                                      \
    "    Set Title"                  t  "$title"                            \
    "<P> Zoom pane toggle"           z  "resize-pane -Z $reload"            \
    "<P> Display pane numbers"       q  "display-panes $reload"             \
    '<P> Copy mode - "history"'     "[" "copy-mode"                         \
    "<P> #{?pane_marked,Unmark,Mark} current pane"                          \
                                     m  "select-pane -m $reload"            \
    "    Display pane size"          s  "$pane_size"                        \
    ""                                                                      \
    "#{?pane_synchronized,Disable,Activate} synchronized panes"             \
                                     y  "set -w synchronize-panes $reload"  \
    "Save pane history no escapes"   h  "$hist_no_esc"                      \
    "Save pane history with escapes" e  "$hist_w_esc"                       \
    ""                                                                      \
    "    Respawn current pane"       r  "$respawn"                          \
    "<P> Kill current pane"          x  "$kill_this"                        \
    "    Kill all other panes"       o  "$kill_others"                      \
    ""                                                                      \
    "Help  -->"  H  "$open_menu/help_panes.sh $this_menu'"

ensure_menu_fits_on_screen
