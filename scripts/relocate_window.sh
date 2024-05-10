#!/bin/sh
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
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/utils.sh
. "$D_TM_BASE_PATH"/scripts/utils.sh

_this="relocate_window.sh" # error prone if script name is changed :(
[ "$current_script" != "$_this" ] && error_msg "$_this should NOT be sourced"

# shellcheck source=scripts/relocate_param_check.sh
. "$d_scripts"/relocate_param_check.sh

relocate_param_parse "$@"

if [ "$cur_ses" = "$dest_ses" ]; then
    [ "$action" = "L" ] && error_msg \
        "Linking to same session is pointless!" 0 true

    if [ -n "$dest_win_id" ]; then
        #  move to before selected win
        _dest="-t :$dest_win_id" # -b
    else
        # put it after last window -a
        _dest="-t :$(tmux_error_handler display-message -p "#{last_window_index}")"
    fi
    log_it "dest_win_id[$dest_win_id] _dest[$_dest]"
    tmux_error_handler move-window "$_dest"
else
    #
    #  tmux move only works in same session, so we use link & unlink for
    #  moving to another session
    #

    # Create a link to this at destination

    #  link-window  3.1c
    #  -b 3.2 !3.1c
    #  -t 2.7
    tmux_error_handler link-window -b -t "$dest_ses:$dest_win_id"
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
    # switch-client
    tmux_error_handler switch-client -t "$dest_ses"
fi

# re-open last menu
log_it "reloading last menu: $(cat "$f_last_menu_displayed")"
eval cat "$f_last_menu_displayed"
