#!/bin/sh
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Moving current pane within same session or to other session.
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/utils.sh
. "$D_TM_BASE_PATH"/scripts/utils.sh

# shellcheck source=scripts/relocate_param_check.sh
. "$d_scripts"/relocate_param_check.sh

_this="relocate_pane.sh" # error prone if script name is changed :(
[ "$current_script" != "$_this" ] && error_msg "$_this should NOT be sourced"

param_check "$@"

$TMUX_BIN move-pane -t "${dest_ses}:${dest_win_idx}.${dest_pane_idx}"

if [ "$cur_ses" != "$dest_ses" ]; then
    #
    #  When Window / Pane is moved to another session, focus does not
    #  auto-switch, so this manually sets focus.
    #
    $TMUX_BIN switch-client -t "$dest_ses" # switch focus to new location
fi
