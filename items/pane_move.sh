#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Move a pane
#

# Global directives
# shellcheck disable=SC2034,SC2154

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Move Pane"

set -- \
    0.0 M Home "Back to Main menu      <==" main.sh \
    0.0 M Left "Back to Handling Pane  <--" panes.sh \
    0.0 S \
    2.7 C m "    Move to other win/ses        " "choose-tree -Gw \
        \"run-shell '$SCRIPT_DIR/relocate_pane.sh P M %%'\""

if $TMUX_BIN display-message -p '#{pane_marked_set}' | grep -q '1'; then
    set -- "$@" \
        1.7 C s "Swap current pane with marked" "swap-pane $menu_reload"
fi

set -- "$@" \
    1.7 C "{" "<P> Swap pane with prev" "swap-pane -U $menu_reload" \
    1.7 C "}" "<P> Swap pane with next" "swap-pane -D $menu_reload" \
    0.0 S \
    2.4 E ! "<P> Break pane to a new window" "$SCRIPT_DIR/break_pane.sh" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=41
req_win_height=13

menu_parse "$@"
