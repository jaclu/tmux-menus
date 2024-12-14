#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Common tools and settings for this plugins
#
# shellcheck disable=SC2034

#---------------------------------------------------------------
#
#   Logging and error msgs
#
#---------------------------------------------------------------

log_it() {
    [ -z "$cfg_log_file" ] && return #  early abort if no logging

    $log_interactive_to_stderr && [ -t 0 ] && {
        printf "log: %s\n" "$@" >/dev/stderr
        return
    }

    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$@" >>"$cfg_log_file"
}

error_msg() {
    #
    #  Display $1 as an error message in log and as a tmux display-message
    #  unless do_display_message is false
    #
    #  Using do_display_message is only practical for short one liners,
    #  for longer error msgs, needing formatting, use error_msg_formated()
    #  instead.
    #
    #  exit_code defaults to 0, which might seem odd for an error exit,
    #  but in combination with display-message it makes sense.
    #  If the script exits with something else than 0, the current pane
    #  will be temporary replaced by an error message mentioning the exit
    #  code. Which is both redundant and much less informative than the
    #  display-message that is also printed.
    #  If display-message is not desired it would make sense to use a more
    #  normal positive exit_code to indicate error, making the 2 & 3
    #  params be something like: 1 false
    #
    #  If exit_code is set to -1, process is not exited
    #
    em_msg="$1"
    exit_code="${2:-0}"
    do_display_message=${3:-true}

    # with no tmux env, dumping it to stderr is the only option
    [ -z "$TMUX" ] && log_interactive_to_stderr=true

    if $log_interactive_to_stderr && [ -t 0 ]; then
        [ -z "$TMUX" ] && {
            (
                echo
                echo "***  This does not seem to be running in a tmux env  ***"
                echo
            ) >/dev/stderr
        }
        echo "ERROR: $em_msg" >/dev/stderr
    else
        log_it
        log_it "ERROR: $em_msg"
        log_it

        $do_display_message && {
            if [ "${#em_msg}" -gt 50 ] || has_lf_not_at_end "$em_msg"; then
                error_msg_formated "$em_msg"
            else
                display_message_hold "$plugin_name ERR: $em_msg"
            fi
        }
    fi

    [ "$exit_code" -gt -1 ] && exit "$exit_code"

    unset em_msg
    unset exit_code
    unset do_display_message
}

# shellcheck disable=SC2154
error_msg_formated() {
    #
    #  Display an error in its own frame, supporting longer messages
    #  and also those formatted with LFs
    #
    #  Can't use tmux_error_handler() or error_msg() here - it could lead to
    #  recursion
    #
    emf_err="$1"

    # log_it "error_msg_formated($emf_err)"

    emf_msg="$(
        echo "ERROR in plugin: $plugin_name:$current_script [$$]"
        echo
        echo "$emf_err"
    )"

    # emf_msg="$(
    #     echo "$emf_msg"
    #     echo
    #     echo "Press ESC to close this display"
    # )"
    # if tmux_vers_check 3.3; then # using full pane display view
    #     # subpar cuts of long lines
    #     $TMUX_BIN run-shell "echo '$emf_msg'"
    # elif tmux_vers_check 3.2; then # using display-popup
    #     # subpar prevents checking other panes or windows
    #     $TMUX_BIN display-popup -h 90% -w 95% "echo '$emf_msg'"
    # else # display in a tmp window
    emf_msg="$(
        echo "$emf_msg"
        echo
        echo "Scroll-mode: <prefix> ["
        echo "Press Ctrl-C to close this temporary window"
    )"
    # posix way to wait forever - MacOS doesn't have: sleep infinity
    $TMUX_BIN new-window -n "tmux-error" \
        "echo '$emf_msg' ; tail -f /dev/null "
    # fi

    # pointless since this is exiting, but that might change some day
    unset emf_err emf_msg
}

display_message_hold() {
    #
    #  Display a message and hold until key-press
    #  Can't use tmux_error_handler in this func, since that could
    #  trigger recursion
    #
    # log_it "display_message_hold()"
    dmh_msg="$1"

    if tmux_vers_check 3.2; then
        # message will remain until key-press
        $TMUX_BIN display-message -d 0 "$dmh_msg"
    else
        # Manually make the error msg stay on screen a long time
        org_display_time="$($TMUX_BIN show-option -gv display-time)"
        $TMUX_BIN set -g display-time 120000 >/dev/null
        $TMUX_BIN display-message "$dmh_msg"

        posix_get_char >/dev/null # wait for keypress
        $TMUX_BIN set -g display-time "$org_display_time" >/dev/null

        unset org_display_time
    fi
    unset dmh_msg
}

#---------------------------------------------------------------
#
#   Handling of specific data types
#
#---------------------------------------------------------------

posix_get_char() {
    #
    #  Configure terminal to read a single character without echoing,
    #  restoring the terminal and returning the char
    #
    old_stty_cfg=$(stty -g)
    stty raw -echo
    dd bs=1 count=1 2>/dev/null
    stty "$old_stty_cfg"

    unset old_stty_cfg
}

extract_char() {
    str="$1"
    pos="$2"
    printf '%s\n' "$str" | cut -c "$pos"
    unset str pos
}

lowercase_it() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

get_digits_from_string() {
    # this is used to get "clean" integer version number. Examples:
    # `tmux 1.9` => `19`
    # `1.9a`     => `19`

    s="$1"
    i="$(echo "$s" | tr -dC '[:digit:]')"
    # log_it "get_digits_from_string($s) -> [$i]"
    echo "$i"
    unset s i
}

has_lf_not_at_end() {
    #
    #  POSIX hack I came up with to check if a string contains LF
    #  somewhere within, since I could not figure out how to to substring
    #  search for LF in this env
    #
    # shellcheck disable=SC2059
    [ "$1" != "$(printf "$1" | tr '\n' 'X')" ]
}

#---------------------------------------------------------------
#
#   Other
#
#---------------------------------------------------------------

safe_now() {
    #
    #  MacOS date only display whole seconds, if gdate (GNU-date) is
    #  installed, it can  display times with more precision
    #
    if [ "$(uname)" = "Darwin" ]; then
        if [ -n "$(command -v gdate)" ]; then
            gdate +%s.%N
        else
            date +%s
        fi
    else
        #  On Linux the native date supports sub second precision
        #  unless its the busybox date - only gives seconds...
        date +%s.%N
    fi
}

wait_to_close_display() {
    #
    #  When a menu item writes to stdout, unfortunately how to close
    #  the output window differs depending on dialog method used...
    #  call this to display an appropriate suggestion, and in the
    #  whiptail case wait for that key
    #
    echo
    # shellcheck disable=SC2154
    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        echo "Press <Enter> to clear this output"
        read -r foo
    else
        echo "Press <Escape> to clear this output"
    fi
}

relative_path() {
    # remove D_TM_BASE_PATH prefix
    echo "$1" | sed "s|^$D_TM_BASE_PATH/||"
}

get_config() { # tmux stuff
    #
    #  The plugin init .tmux script should NOT depend on this!
    #  This is used by everything else sourcing helpers.sh, then trusting
    #  that the param cache is valid if found
    #

    log_it "get_config()"
    if [ -f "$f_cache_not_used_hint" ]; then
        tmux_define_vers_vars
        tmux_get_plugin_options
    else
        cache_validation
        # shellcheck source=cache/plugin_params disable=SC1091
        [ -f "$f_cache_not_used_hint" ] || . "$f_cache_params"
    fi
}

#===============================================================
#
#   Main
#
#===============================================================

plugin_name="tmux-menus"

#
#  Setting a cfg_log_file here will ignore the tmux setting @menus_log_file
#  This is mostly for debugging early stuff before the settings have
#  been processed. Should normally be commented out!
#
# cfg_log_file="$HOME/tmp/${plugin_name}-dbg.log"

#
#  Even if this one is used, a cfg_log_file must still be defined
#  since log_it quick aborts if that is undefined
#
log_interactive_to_stderr=false

[ -z "$D_TM_BASE_PATH" ] && error_msg "D_TM_BASE_PATH undefined"

# ensure no caching until the setting has been read
cfg_use_cache=false

#
#  Convenience shortcuts
#
d_items="$D_TM_BASE_PATH"/items
d_scripts="$D_TM_BASE_PATH"/scripts

d_tmp="${TMPDIR:-/tmp}"

# defines tmux_pid used in init of cache.sh, so must be defined before
# shellcheck source=scripts/utils/tmux.sh
. "$d_scripts"/utils/tmux.sh

# shellcheck source=scripts/utils/cache.sh
. "$d_scripts"/utils/cache.sh

#
#  Convert script name to full actual path notation the path is used
#  for caching, so save it to a variable as well
#
current_script="$(basename "$0")" # name without path
# ensure f_current_script is a full path
d_current_script="$(realpath "$(dirname -- "$0")")"
f_current_script="$d_current_script/$current_script"

# shellcheck disable=SC2154
if [ "$initialize_plugin" = "1" ]; then
    log_it "Doing plugin initialization"
    cache_validation
    cache_update_params
    #
    #  at this point plugin_params are trusted if found, menus.tmux will
    #  always always replace it with current tmux conf during plugin init
    #
    #
    #  By printing a NL and date, its easier to keep separate runs apart
    #
    log_it
    log_it "$(date)"
else
    get_config
fi

if ! tmux_vers_check 3.0; then
    min_tmux_vers="1.8"
    if ! tmux_vers_check "$min_tmux_vers"; then
        # @variables are not usable prior to 1.8
        error_msg "need at least tmux $min_tmux_vers to work!"
    fi
    FORCE_WHIPTAIL_MENUS=1
fi

if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
    menu_reload="; $f_current_script"
    #
    #  I haven't been able do to menu reload with whiptail yet,
    #  so disabled for now
    #
    # f_wt_reload_script="$d_tmp/${plugin_name}-reload-${tmux_pid}"
    # reload_in_runshell="echo $f_current_script > $f_wt_reload_script ;"
    reload_in_runshell="" # TODO: try to fix this...
else
    menu_reload="; run-shell \"$f_current_script\""
    reload_in_runshell=" ; $f_current_script"
fi

# log_it "-----   end of helpers.sh"
