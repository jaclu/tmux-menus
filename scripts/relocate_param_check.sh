#!/bin/sh
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Common stuff for relocate_pane.sh & relocate_windows.sh
#   Validates parameters
#
# Global check exclude, ignoring: is referenced but not assigned

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/utils.sh
. "$D_TM_BASE_PATH"/scripts/utils.sh

# Should be sourced
_this="relocate_param_check.sh" # error prone if script name is changed :(
[ "$current_script" = "$_this" ] && error_msg "$_this should be sourced"

relocate_param_parse() {
    #
    # Exposed variables:
    #   $item_type - item type to handle window/pane
    #   $action - action to take on the selected item M / L
    #   $cur_ses - current session
    #   $raw_dest - destination in raw format as given by tmux
    #   $dest_ses - session name
    #   $dest_win_id - window id
    #   $dest_pane_id - pane id
    #
    params="$*"
    log_it "relocate_param_parse($params)"
    msg="$msg dest_pane_id [$dest_pane_id]"
    item_type="$1"

    case "$item_type" in

    "W" | "P") : ;; # Valid parameters

    *)
        # NEEDS TESTING
        error_msg "relocate_param_parse($1) First param must be W or P!"
        ;;

    esac

    action="$2"

    case "$action" in

    "M") : ;; # Valid parameters

    "L")
        if [ "$item_type" = "P" ]; then
            # NEEDS TESTING
            error_msg "relocate_param_parse() Panes can not be linked!" 0 true
        fi
        ;;

    *)
        # NEEDS TESTING
        msg="relocate_param_parse($1,$2) 2nd param must be L or M"
        msg="$msg Indicating move or link action"
        error_msg "$msg" 0 true
        ;;

    esac

    #
    #  inputs:
    #    with pane idx:      =main:1.%13
    #    with window idx:    =main:3.
    #    without window idx: =main:
    #
    raw_dest="$3"

    if [ -z "$raw_dest" ]; then
        # NEEDS TESTING
        error_msg "relocate_param_parse() - no destination param 3 given!" 0 true
    fi

    cur_ses="$(tmux_error_handler display-message -p '#S')"
    dest="${raw_dest#*=}"  # skipping initial =
    dest_ses="${dest%%:*}" # up to first colon excluding it

    win_pane="${dest#*:}"         # after first colon
    dest_win_id="${win_pane%%.*}" # empty if non selected
    dest_pane_id="${win_pane#*.}"

    #  Used by
    #    relocate_window.sh  $dest_ses $dest_win_id
    #    relocate_pane.sh   $dest_ses $dest_win_id.${dest_pane_id}"

    # set -- "relocate_param_parse($params) - item_type [$item_type] action [$action]" \
    #     "cur_ses [$cur_ses] dest [$dest] win_pane [$win_pane]" \
    #     "dest_ses [$dest_ses] dest_win_id [$dest_win_id]" \
    #     "dest_pane_id [$dest_pane_id]"
    msg="<- relocate_param_parse() - item_type [$item_type]"
    msg="$msg action [$action] cur_ses [$cur_ses] raw_dest [$raw_dest]"
    msg="$msg dest_ses [$dest_ses] dest_win_id [$dest_win_id]"
    msg="$msg dest_pane_id [$dest_pane_id]"
    log_it "$msg"

    unset params
    unset dest
    unset win_pane
    return 0
}
