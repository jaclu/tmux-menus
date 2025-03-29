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

_this="relocate_window.sh" # error prone if script name is changed :(
[ "$bn_current_script" != "$_this" ] && error_msg_safe "$_this should NOT be sourced"

# shellcheck source=scripts/relocate_param_check.sh
. "$d_scripts"/relocate_param_check.sh

param_check "$@"

# shellcheck disable=SC2154
if [ "$cur_ses" = "$dest_ses" ]; then
    #
    #  to same session
    #
    # NEEDS TESTING
    [ "$action" = "L" ] && error_msg_safe "Linking to same session is pointless!"

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
    if [ "$action" != "L" ]; then
        #
        # Unlink window at current location, ie get rid of original instance
        # And re-indix previous session
        #
        tmux_error_handler unlink-window
    fi
    #
    #  When Window / Pane is moved to another session, focus does not
    #  auto-switch, so this manually sets focus.
    #
    tmux_error_handler switch-client -t "$dest_ses" # switch focus to new location
fi

if [ -z "$dest_win_idx" ]; then
    #
    # No dest windows idx given, assume it should go last
    #
    tmux_error_handler move-window -t 999
fi
