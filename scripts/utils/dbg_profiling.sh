#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Some timing functions I use when I need to optimize performance
#  Each printout displays both total run time and time since last update
#  Unit is milliseconds, in order to make the timing calculations quicker by
#  using integers.
#  Diffs smaller than milliseconds doesn't really matter in profiling anyhow...
#
#  Typical usage:
#  In the script I want to optimize paste the code below, time starts when
#  set_profiling_t_now is called so depending on what you want to measure the dropin
#  point for this code can make a difference!
#
#   If you want to see the precise time for an action, do this:
#
#    profiling_update_time_stamps
#    . "$d_scripts"/utils/cache.sh
#    profiling_display "sourced cache"
#
#   If you just want to see how much time have been spent at a certain point,
#   including time since last time update, use it like:
#       profiling_display "get_config done"
#

profiling_is_function_defined() {
    [ "$(command -v "$1")" = "$1" ]
}

profiling_display_it() {
    if [ -t 0 ]; then
        printf '%s\n' "$1" >/dev/stderr
    elif [ -n "$cfg_log_file" ]; then
        printf '[P] %s\n' "$1" >>"$cfg_log_file"
    fi
}

profiling_error_msg() {
    # If this file was sourced befoe helpers_minimal error_msg_safe is not
    # yet available...
    if profiling_is_function_defined "error_msg_safe"; then
        error_msg_safe "$_m"
    else
        profiling_display_it
        profiling_display_it "ERROR: $_m"
        profiling_display_it
    fi
    exit 2
}

profiling_select_timing_method() {
    # figure out what method to use and save the selection for future usage
    [ -n "$profiling_selected_get_time" ] && {
        # if this is called when the method was selected something is wrong...
        _m="recursive call to: profiling_select_timing_method()"
        profiling_error_msg "$_m"
    }

    if [ -d /proc ] && [ -f /proc/version ]; then
        #  On Linux the native date supports sub second precision
        #  unless its the busybox date - only gives seconds...
        profiling_selected_get_time="date"
    elif [ "$(uname)" = "Linux" ]; then
        # Non-standard devices still being Linux, such as termux
        profiling_selected_get_time="date"
    elif [ -n "$(command -v gdate)" ]; then
        # The MacOS date doesn't support sub seconds, if gdate is available use it.
        profiling_selected_get_time="gdate"
    elif [ -n "$(command -v perl)" ]; then
        # Slower than gdate but still usable, built-in on MacOS
        profiling_selected_get_time="perl"
    else
        # Fallback
        profiling_selected_get_time="date"
    fi
}

profiling_get_time() {
    #
    #  Sets profiling_t_now to current time in milliseconds
    #
    if [ "$profiling_use_default_timer" = "1" ]; then
        safe_now profiling_t_now
    else
        case "$profiling_selected_get_time" in
        date)
            _t="$(date +%s%N)"
            profiling_t_now="${_t%??????}" # Strip last 6 digits → milliseconds
            ;;
        gdate)
            _t="$(gdate +%s%N)"
            profiling_t_now="${_t%??????}" # Strip last 6 digits → milliseconds
            ;;
        perl)
            profiling_t_now="$(perl -MTime::HiRes=time -E 'say int(time * 1e3)')"
            ;;
        *)
            _m="Call to profiling_get_time without first cslling"
            _m="$_m profiling_select_timing_method"
            profiling_error_msg "$_m"
            ;;
        esac
    fi

    [ -z "$profiling_t_start" ] && {
        profiling_t_start="$profiling_t_now"
        profiling_t_last_update="$profiling_t_start"
    }
}

profiling_update_time_stamps() {
    profiling_get_time
    if [ "$profiling_use_default_timer" = "1" ]; then
        t_prof_since_start="$(echo "$profiling_t_now - $profiling_t_start" | bc)"
        t_prof_sine_update="$(echo "$profiling_t_now - $profiling_t_last_update" | bc)"
    else
        t_prof_since_start=$((profiling_t_now - profiling_t_start))
        t_prof_sine_update=$((profiling_t_now - profiling_t_last_update))
    fi
    profiling_t_last_update="$profiling_t_now"
}

profiling_display() {
    profiling_update_time_stamps

    _s="$1 - total: $t_prof_since_start   since last: $t_prof_sine_update"
    profiling_display_it "$_s"
    [ "$2" = "LF" ] && profiling_display_it
}

#===============================================================
#
#   Main
#
#===============================================================

[ "$profiling_sourced" = 1 ] && {
    profiling_error_msg "scripts/utils/dbg_profiling.sh already sourced"
}

# shellcheck disable=SC2154 # TMUX_MENUS_PROFILING is an env variable
case "$TMUX_MENUS_PROFILING" in
1)
    # profiling will be used
    profiling_select_timing_method
    _m="Starting profiling for: $0 - using time method: $profiling_selected_get_time"
    profiling_display_it "$_m"
    profiling_get_time # start timer as early as possible
    ;;
*)
    #
    # This file should not be sourced normally and profiling calls should not be
    # left in the code base long term, the below function overrides are primarily
    # intended to disable them when profiling is temporarily disabled
    #

    profiling_update_time_stamps() {
        :
    }
    profiling_display() {
        :
    }
    ;;
esac

profiling_use_default_timer=0
profiling_sourced=1 # Indicate this has been sourced
