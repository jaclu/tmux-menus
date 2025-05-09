#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf in order to pick the version matching the server running.
#  If not found, it is set to whatever is in path, so should have no negative
#  impact. In all calls to tmux I use $TMUX_BIN instead in the rest of this
#  plugin.
#
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

#
# if multiple instances of the same tmux bin are used, errors can spill over
# and cause issues in the other instance
# this ensures that everything is run in the current environment
#
case "$TMUX_BIN" in
*-L*) ;; # already using socket
*)
    #
    # in case an inner tmux is using this plugin, make sure the current socket is
    # used to avoid picking up states from the outer tmux
    #
    # shellcheck disable=SC2154
    f_name_socket="$(echo "$TMUX" | cut -d, -f 1)"
    socket="${f_name_socket##*/}"
    TMUX_BIN="$TMUX_BIN -L $socket"
    ;;
esac
