#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Switch to other floating pane on window (if any)
#

switch_floating_pane() {

    # Moves to next/prev floating pane on same window if any
    action="$1" # one of previous/next

    # Filter listing panes that are floating but not the active one
    filt_all_other_floating_panes='#{?pane_floating_flag,#{?pane_active,0,1},0}'
    other_floating_panes=$($TMUX_BIN list-panes -F '#{pane_id}' \
        -f "$filt_all_other_floating_panes" | sort -t '%' -k 2 -n)

    [ -z "$other_floating_panes" ] && return # nothing to do here

    this_pane=$($TMUX_BIN display -p '#{pane_id}')
    this_num=${this_pane#%}

    case "$action" in
        previous)
            # Last item other_floating_panes with id lower than $this_pane or last item
            # if no with lower id
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
            # First item in other_floating_panes with higher id than $this_pane or first
            # if no with higher id
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

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

tmux_vers_check 3.7 || {
    error_msg "switch_floating_pane() requires tmux 3.7"
}

switch_floating_pane "$1"
