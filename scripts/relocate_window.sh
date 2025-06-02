#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Moving current window within same session or to other session.
#
#   If a window is selected, move the current to that index pushing
#   the rest back one step.
#
#   If just a session is selected, move it to the last position in that session.
#
#   If a pane is selected, that part of the selection is simply ignored.
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

log_it "><> ==> $rn_current_script params: $*"

action="$1"
parse_move_link_dest "$2"

# shellcheck disable=SC2154 # cur_ses defined in relocate_param_check.sh
if [ "$cur_ses" = "$dest_ses" ]; then
    #
    #  to same session
    #
    [ "$action" = "l" ] && error_msg "Linking to same session is pointless!"

    #
    #  Move within the current session
    #
    tmux_error_handler move-window -b -t ":${dest_win_idx}"
else
    #
    #  tmux move only works in same session, so we use link & unlink for
    #  moving to another session
    #

    # Create a link to this at destination
    tmux_error_handler link-window -b -t "$dest_ses:$dest_win_idx"
    if [ "$action" != "l" ]; then
        #
        # Unlink window at current location, ie treat the action as a move and
        # get rid of original instance
        #
        tmux_error_handler unlink-window
    fi
    #
    #  When Window is moved to another session, focus does not
    #  auto-switch, so this manually sets focus to the destination.
    #
    tmux_error_handler switch-client -t "$dest_ses" # switch focus to new location
fi

if [ -z "$dest_win_idx" ]; then
    #
    # No dest windows idx given, assume it should go last
    #
    tmux_error_handler move-window -t 999
fi
