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
#  Unit is milliseconds, in order to make the timing calculations quicker by
#  using integers.
#  Diffs smaller than miliseconds doesn't really matter in profiling anyhow...
#
#  Typical usage:
#  In the script I want to optimize paste the code below, time starts when
#  set_profiling_t_now is called so depending on what you want to measure the dropin
#  point for this code can make a difference!
#
#  at any point you want to see timings before/after, do this:
#
#    profiling_display "will source cache"
#    . "$d_scripts"/utils/cache.sh
#    profiling_display "source cache - done!"
#
#   If you just want to see how much time have been spent at a certain point,
#   including time since last time update, use it like:
#       profiling_display "get_config done"
#

[ "$MENUS_PROFILING" != "1" ] && {
    echo
    echo "ERRORR: sourcing dbg_pofiling.sh without MENUS_PROFILING being 1 [$0]"
    exit 1
}

profiling_is_function_defined() {
    [ "$(command -v "$1")" = "$1" ]
}

profiling_log_it() {
    # Only call log_it if it has been defined
    # During normal sourcing of this it has been, but if this is early sourced
    # in some other script, this is not initially available
    if [ -t 0 ] && [ "$TMUX_MENUS_FORCE_SILENT" != "2" ]; then
        echo "$@" >/dev/stderr
    elif profiling_is_function_defined "log_it"; then
        log_it profiling "$@" || exit 2
    fi
}

profiling_set_t_date() {
    _t="$(date +%s%N)"
    profiling_t_now="${_t%??????}" # Strip last 6 digits → milliseconds
}

profiling_set_t_gdate() {
    _t="$(gdate +%s%N)"
    profiling_t_now="${_t%??????}" # Strip last 6 digits → milliseconds
}

profiling_set_t_perl() { # represented as milliseconds
    profiling_t_now="$(perl -MTime::HiRes=time -E 'say int(time * 1e3)')"
}

profiling_select_timing_method() {
    # figure out what method to use and save the selection for future usage
    [ -n "$profiling_selected_get_time" ] && {
        # if this is called when the method was selected something is wrong...
        _m="recursive call to: profiling_select_timing_method()"
        if profiling_is_function_defined "error_msg_safe"; then
            error_msg_safe "$_m"
            # exit should have already happened, but since this is a recursion error
            # play it safe and ensure exit happens...
            exit 2
        else
            echo
            echo "ERROR: $_m"
            echo
            exit 2
        fi
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
        # Slower than gdate but still useable, built-in on MacOS
        profiling_selected_get_time="perl"
    else
        # Fallback
        profiling_selected_get_time="date"
    fi
    _m="profiling is using timing method: $profiling_selected_get_time"
    profiling_log_it "$_m"
}

profiling_get_time() {
    #
    #  Sets profiling_t_now to current epoch
    #
    case "$profiling_selected_get_time" in
    date) profiling_set_t_date ;;
    gdate) profiling_set_t_gdate ;;
    perl) profiling_set_t_perl ;;
    *) profiling_select_timing_method ;;
    esac
    # safe_now
    # profiling_t_now="$t_now"

    [ -z "$profiling_t_start" ] && {
        profiling_t_start="$profiling_t_now"
        profiling_t_last_update="$profiling_t_start"
    }
}

[ "$profiling_sourced" != "1" ] && {
    # Only start timer first time this is sourced

    # if profiling should go to log file, disable this
    [ "$TMUX_MENUS_FORCE_SILENT" = "2" ] && log_interactive_to_stderr="0"

    profiling_get_time # start timer as early as possible
}

profiling_update_time_stamps() {
    profiling_get_time
    # _since_start="$(echo "$profiling_t_now - $profiling_t_start" | bc)"
    # _sine_update="$(echo "$profiling_t_now - $profiling_t_last_update" | bc)"
    _since_start=$((profiling_t_now - profiling_t_start))
    _sine_update=$((profiling_t_now - profiling_t_last_update))

    profiling_t_last_update="$profiling_t_now"
}

profiling_display() {
    [ "$TMUX_MENUS_FORCE_SILENT" = "3" ] && return
    profiling_update_time_stamps

    _s="$1 - total: $_since_start   since last: $_sine_update"
    if [ -t 0 ] && [ "$TMUX_MENUS_FORCE_SILENT" != "2" ]; then
        echo "$_s" >/dev/stderr
    elif [ -n "$cfg_log_file" ]; then
        profiling_log_it "$_s"
    fi

    # echo "profiling_t_start [$profiling_t_start] _since_start [$_since_start] profiling_t_last_update [$profiling_t_last_update] _sine_update [$_sine_update]"

    # do it again to not count this update in processing time
    # only makes sense on slowish systems
    # profiling_update_time_stamps
}

profiling_sourced=1

[ -t 0 ] && {
    case "$TMUX_MENUS_FORCE_SILENT" in
    2 | 3) return ;;
    *) ;;
    esac

    echo
    echo "Starting profiling for: $0"
    echo
}
