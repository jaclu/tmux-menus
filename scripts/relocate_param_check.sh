#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-02-03
#
#   Common stuff for relocate_pane.sh & relocate_windows.sh
#   Validate params
#

param_check() {
    item_type="$1"

    case "$item_type" in
        
        "W" | "P" ) : ;;  # Valid params
        
        "*" )
            echo "ERROR: First param must be W or P!"
            echo "       Indicating source is Window or Pane!"
            exit 1
            ;;
        
    esac


    action="$2"
    
    case "$action" in
    

        "M" ) : ;;  # Valid param

        "L" )
            if [ "$item_type" = "P" ]; then
                echo "ERROR: Panes can not be linked!"
                exit 1
            fi
            ;;
        
        "*" )
            echo "ERROR: Second param must be L or M!"
            echo "       Indicating move or link action"
            echo "       Only windows can be linked!"
            exit 1
            ;;
        
    esac


    #
    #  inputs:
    #    with pane idx:      =main:1.%13
    #    with window idx:    =main:3.
    #    without window idx: =main:
    #
    raw_dest="$3"
    
    
    if [ -z "$raw_dest" ] ; then
        echo "ERROR: no destination param given!"
        exit 1
    fi
    
    
    dest="${raw_dest#*=}"  # skipping initial =
    dest_ses="${dest%%:*}" # upto first colon excluding it
    win_pane="${dest#*:}"  # after first colon


    dest_win_idx="${win_pane%%.*}"   # up to first dot excluding it
    dest_pane_idx="${win_pane#*.}"
    cur_ses="$(tmux display -p '#S')"
}
