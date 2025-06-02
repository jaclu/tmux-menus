#!/bin/sh
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

. "$D_TM_BASE_PATH"/scripts/helpers.sh

log_it "><> ==> $rn_current_script params: $*"

parse_move_link_dest "$1"

tmux_error_handler move-pane -t "${dest_ses}:${dest_win_idx}.${dest_pane_idx}"

# shellcheck disable=SC2154 # cur_ses defined in relocate_param_check.sh
if [ "$cur_ses" != "$dest_ses" ]; then
    #
    #  When Window / Pane is moved to another session, focus does not
    #  auto-switch, so this manually sets focus.
    #
    tmux_error_handler switch-client -t "$dest_ses" # switch focus to new location
fi
