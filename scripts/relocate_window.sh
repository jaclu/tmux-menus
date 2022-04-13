#!/bin/sh
# shellcheck disable=SC2154
#  Directives for shellcheck directly after bang path are global

#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.5 2022-04-13
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
# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
. "$CURRENT_DIR/utils.sh"

# shellcheck disable=SC1091
. "$CURRENT_DIR/relocate_param_check.sh"

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
    tmux move-window -b -t ":${dest_win_idx}"
else
    #
    #  tmux move only works in same session, so we use link & unlink for
    #  moving to another session
    #
    tmux link-window -b -t "$dest_ses:$dest_win_idx" # Create a link to this at destination
    if [ "$action" != "L" ]; then
        #
        # Unlink window at current location, ie get rid of original instance
        # And re-indix previous session
        #
        tmux unlink-window
    fi
    #
    #  When Window / Pane is moved to another session, focus does not
    #  auto-switch, so this manually sets focus.
    #
    tmux switch-client -t "$dest_ses"  # switch focus to new location
fi

if [ -z "$dest_win_idx" ]; then
    #
    # No dest windows idx given, assume it should go last
    #
    tmux move-window -t 999
fi
