#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Support functions for multiple floating pane handling menus
#
#  Provides:
#   current_pane_is_floating 0/1
#   other_floating_panes     all non-focused floating panes, if any
#

define_other_floating_panes() {
    other_floating_panes=$($TMUX_BIN list-panes -F '#{pane_id}' \
        -f '#{?pane_floating_flag,#{?pane_active,0,1},0}' \
        | sort -t '%' -k 2 -n)
}

floating_pane_focus() {
    # switch focus to a floating pane if any visible

    [ "$current_pane_is_floating" != 1 ] && [ -n "$other_floating_panes" ] && {
        # If non-focused floating panes are present on the window, shift focus
        # to one of them first
        $scr_float_pane_switch next
        current_pane_is_floating=1 # now focused pane is a floating one
        define_other_floating_panes
    }
}

switch_floating_pane() {
    # Moves to next/prev floating pane on same window if any
    action="$1" # one of previous/next

    [ -z "$other_floating_panes" ] && {
        # return # nothing to do here
        error_msg "switch_floating_pane() called with no other floating pane visible"
    }

    this_pane=$($TMUX_BIN display -p '#{pane_id}')
    this_num=${this_pane#%}

    case "$action" in
        previous)
            # Switch to first item in other_floating_panes with id lower than
            # $this_pane - or last item, if none with lower id
            previous=
            last=

            for pane in $other_floating_panes; do
                num=${pane#%}

                last=$pane

                if [ "$num" -lt "$this_num" ]; then
                    previous=$pane
                fi
            done

            # Wrap around if none lower
            [ -n "$previous" ] || previous=$last

            $TMUX_BIN select-pane -t "$previous"
            ;;
        next)
            # switch to first item in other_floating_panes with higher id than
            # $this_pane - or first item, if none with higher id
            next=
            first=

            for pane in $other_floating_panes; do
                num=${pane#%}

                [ -n "$first" ] || first=$pane

                if [ "$num" -gt "$this_num" ]; then
                    next=$pane
                    break
                fi
            done

            # Wrap around if none higher
            [ -n "$next" ] || next=$first

            $TMUX_BIN select-pane -t "$next"
            ;;
        *) error_msg "Invalid action for switch_floating_pane()" ;;
    esac
}

#===============================================================
#
#   Main
#
#===============================================================

[ "${env_initialized:-0}" -lt 1 ] && {
    # Only source if not done

    [ -z "$D_TM_BASE_PATH" ] && {
        # helpers not yet sourced, so error_msg() not yet available
        msg="ERROR: menu_handling.sh - D_TM_BASE_PATH must be set before sourcing this file"
        (
            echo
            echo "$msg"
            echo
        ) >/dev/stderr
        exit 1
    }
    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh
}

# Set up basic floating pane env

current_pane_is_floating=$($TMUX_BIN display -p '#{pane_floating_flag}')
define_other_floating_panes
