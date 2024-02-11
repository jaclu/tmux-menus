#!/bin/sh
# shellcheck disable=SC2154
#  Directives for shellcheck directly after bang path are global

#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
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
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/utils.sh

_this="relocate_window.sh"
[ "$(basename "$0")" != "$_this" ] && error_msg "$_this should NOT be sourced"

# shellcheck disable=SC1091
. "$D_TM_SCRIPTS/relocate_param_check.sh"

param_check "$@"

# shellcheck disable=SC2154
if [ "$cur_ses" = "$dest_ses" ]; then
    #
    #  to same session
    #
    # NEEDS TESTING
    [ "$action" = "L" ] && error_msg "Linking to same session is pointless!"

    #
    #  Move within the current session
    #
    $TMUX_BIN move-window -b -t ":${dest_win_idx}"
else
    #
    #  tmux move only works in same session, so we use link & unlink for
    #  moving to another session
    #
    $TMUX_BIN link-window -b -t "$dest_ses:$dest_win_idx" # Create a link to this at destination
    if [ "$action" != "L" ]; then
        #
        # Unlink window at current location, ie get rid of original instance
        # And re-indix previous session
        #
        $TMUX_BIN unlink-window
    fi
    #
    #  When Window / Pane is moved to another session, focus does not
    #  auto-switch, so this manually sets focus.
    #
    $TMUX_BIN switch-client -t "$dest_ses" # switch focus to new location
fi

if [ -z "$dest_win_idx" ]; then
    #
    # No dest windows idx given, assume it should go last
    #
    $TMUX_BIN move-window -t 999
fi
