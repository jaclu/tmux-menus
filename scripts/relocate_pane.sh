#!/bin/sh
#  shellcheck disable=SC2154
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Moving current pane within same session or to other session.
#

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/relocate_param_check.sh"

# safety check to ensure it is defined
[ -z "$TMUX_BIN" ] && echo "ERROR: relocate_pane.sh - TMUX_BIN is not defined!"

param_check "$@"

$TMUX_BIN move-pane -t "${dest_ses}:${dest_win_idx}.${dest_pane_idx}"

if [ "$cur_ses" != "$dest_ses" ]; then
    #
    #  When Window / Pane is moved to another session, focus does not
    #  auto-switch, so this manually sets focus.
    #
    $TMUX_BIN switch-client -t "$dest_ses" # switch focus to new location
fi
