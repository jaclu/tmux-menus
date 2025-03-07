#!/bin/sh
# Always sourced file - Fake bang path to help editors
# shellcheck disable=SC2034,SC2154

#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Some timing functions I user when I need to optimize some performances
#  Each printout displays both total run time and time since last update
#
#  Typical usage:
#  In the script I want to optimize paste the code below, time starts when
#  set_dbg_t_now is called so depending on what you want to measure the dropin
#  point for this code can make a difference!
#
#  at any point you want to see timings before/after, do this:
#
#    dbg_t_update "will source cache"
#    . "$d_scripts"/utils/cache.sh
#    dbg_t_update "source cache - done!"
#
#   If you just want to see how much time have been spent at a certain point,
#   including time since last time update, use it like:
#       dbg_t_update "get_config done"
#

set_dbg_t_now() {
    #
    #  Sets dbg_t_now to current epoch
    #
    dbg_ts="$(date +%s%N)"
    dbg_t_now="${dbg_ts%??????}" # Strip last 6 digits → milliseconds
    [ -z "$dbg_t_start" ] && {
        dbg_t_start="$dbg_t_now"
        dbg_t_last_update="$dbg_t_now"
    }
}

dbg_t_update() {
    set_dbg_t_now
    dbg_t_since_start=$((dbg_t_now - dbg_t_start))
    dbg_t_sine_update=$((dbg_t_now - dbg_t_last_update))
    dbg_t_last_update="$dbg_t_now"
    echo "$1 - total: $dbg_t_since_start   since last: $dbg_t_sine_update"

}

set_dbg_t_now
