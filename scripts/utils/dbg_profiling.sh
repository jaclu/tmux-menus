#!/bin/sh
# Always sourced file - Fake bang path to help editors
# shellcheck disable=SC2034,SC2154

#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Some timing functions I use when I need to optimize performance
#  Each printout displays both total run time and time since last update
#
#  Typical usage:
#  In the script I want to optimize paste the code below, time starts when
#  set_profiling_t_now is called so depending on what you want to measure the dropin
#  point for this code can make a difference!
#
#  at any point you want to see timings before/after, do this:
#
#    profiling_t_update "will source cache"
#    . "$d_scripts"/utils/cache.sh
#    profiling_t_update "source cache - done!"
#
#   If you just want to see how much time have been spent at a certain point,
#   including time since last time update, use it like:
#       profiling_t_update "get_config done"
#

[ "$MENUS_PROFILING" != "1" ] && {
    echo
    echo "ERRORR: sourcing dbg_pofiling.sh without MENUS_PROFILING being 1 [$0]"
    exit 1
}

set_profiling_t_now() {
    #
    #  Sets profiling_t_now to current epoch
    #
    _t="$(date +%s%N)"
    profiling_t_now="${_t%??????}" # Strip last 6 digits → milliseconds
    [ -z "$profiling_t_start" ] && {
        profiling_t_start="$profiling_t_now"
        profiling_t_last_update="$profiling_t_start"
    }
}

set_profiling_t_now # start timer as early as possible

profiling_t_update() {
    [ "$TMUX_MENU_FORCE_SILENT" = "2" ] && return

    set_profiling_t_now
    _since_start=$((profiling_t_now - profiling_t_start))
    _sine_update=$((profiling_t_now - profiling_t_last_update))
    profiling_t_last_update="$profiling_t_now"

    _s="$1 - total: $_since_start   since last: $_sine_update"
    if [ -t 0 ] && [ "$TMUX_MENU_FORCE_SILENT" != "1" ]; then
        echo "$_s" >/dev/stderr
    elif [ -n "$cfg_log_file" ]; then
        log_it "$_s"
    fi
}

[ -t 0 ] && {
    echo
    echo "Starting profiling for: $0"
    echo
}

dbg_profiling_sourced=1
