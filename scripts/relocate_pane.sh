#!/bin/sh
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Moving current pane within same session or to other session.
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

# shellcheck source=scripts/relocate_param_check.sh
. "$d_scripts"/relocate_param_check.sh

_this="relocate_pane.sh" # error prone if script name is changed :(
[ "$bn_current_script" != "$_this" ] && error_msg_safe "$_this should NOT be sourced"

tmux_error_handler move-pane -t "${dest_ses}:${dest_win_idx}.${dest_pane_idx}"

# shellcheck disable=SC2154
if [ "$cur_ses" != "$dest_ses" ]; then
    #
    #  When Window / Pane is moved to another session, focus does not
    #  auto-switch, so this manually sets focus.
    #
    tmux_error_handler switch-client -t "$dest_ses" # switch focus to new location
fi
