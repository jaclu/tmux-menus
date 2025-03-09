#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
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
    TMUX_MENUS_FORCE_SILENT=0 # errors should always be displayed
    log_it "error_msg($em_msg)"

    # with no tmux env, dumping it to stderr is the only option
    [ -z "$TMUX" ] && log_interactive_to_stderr=1

    if [ "$log_interactive_to_stderr" = 1 ] && [ -t 0 ]; then
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
            # shellcheck disable=SC2154
            msg_hold="$plugin_name ERR: $em_msg"
            # shellcheck disable=SC2154
            actual_win_width="$($TMUX_BIN display-message -p "#{window_width}")"
            if $env_initialized && (
                [ "${#msg_hold}" -gt "$actual_win_width" ] || has_lf_not_at_end "$em_msg"
            ); then
                error_msg_formated "$em_msg"
            else
                display_message_hold "$msg_hold"
            fi
        }
    fi

    [ "$exit_code" -gt -1 ] && exit "$exit_code"

    unset em_msg
    unset exit_code
    unset do_display_message
}

error_msg_formated() {
    #
    #  Display an error in its own frame, supporting longer messages
    #  and also those formatted with LFs
    #
    #  Can't use tmux_error_handler() or error_msg() here - it could lead to
    #  recursion
    #
    emf_err="$1"

    log_it "error_msg_formated($emf_err)"

    emf_msg="$(
        # shellcheck disable=SC2154
        echo "ERROR in plugin $plugin_name: $(relative_path "$f_current_script") [$$]"
        echo
        echo "$emf_err"
    )"

    emf_msg="$(
        echo "$emf_msg"
        echo
        echo "To scroll back in this error message:"
        echo " <prefix>-[ then up/down arrows"
        echo
        echo "Press Ctrl-C to close this message"
    )"
    # posix way to wait forever - MacOS doesn't have: sleep infinity
    $TMUX_BIN new-window -n "tmux-error" "echo '$emf_msg' ; tail -f /dev/null "

    # pointless since this is exiting, but that might change some day
    unset emf_err emf_msg
}

display_message_hold() {
    #
    #  Display a message and hold until key-press
    #  Can't use tmux_error_handler in this func, since that could
    #  trigger recursion
    #
    dmh_msg="$1"
    log_it "display_message_hold($dmh_msg)"

    if tmux_vers_check 3.2; then
        # message will remain until key-press
        $TMUX_BIN display-message -d 0 "$dmh_msg"
    else
        # Manually make the error msg stay on screen a long time
        org_display_time="$($TMUX_BIN show-options -gv display-time)"
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
#   Handling of data types
#
#---------------------------------------------------------------

posix_get_char() {
    #
    #  Configure terminal to read a single character without echoing,
    #  restoring the terminal and returning the char
    #
    # log_it "posix_get_char()"

    old_stty_cfg=$(stty -g)
    stty raw -echo
    dd bs=1 count=1 2>/dev/null
    stty "$old_stty_cfg"

    unset old_stty_cfg
}

extract_char() {
    # log_it "extract_char($1,$2)"
    str="$1"
    pos="$2"
    printf '%s\n' "$str" | cut -c "$pos"
    unset str pos
}

lowercase_it() {
    # log_it "lowercase_it($1)"
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

get_digits_from_string() {
    # this is used to get "clean" integer version number. Examples:
    # `tmux 1.9` => `19`
    # `1.9a`     => `19`

    log_it "get_digits_from_string($1)"
    s="$1"
    i="$(echo "$s" | tr -dC '[:digit:]')"
    # log_it "get_digits_from_string($s) -> [$i]"
    echo "$i"
    unset s i
}

normalize_bool_param() {
    #
    # Take a boolean style text param and convert it into an actual boolean
    # that can be used in your code. If the param starts with @ it is first read
    # from tmux
    #    Example of usage:
    #
    # if normalize_bool_param "@menus_without_prefix" "$default_no_prefix"; then
    #     cfg_no_prefix=true
    # else
    #     cfg_no_prefix=false
    # fi

    #  normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
    #      cfg_no_prefix=true || cfg_no_prefix=false
    #
    #  $cfg_no_prefix && echo "Don't use prefix"
    #
    nbp_param="$1"
    nbp_default="$2" # only used for tmux options
    nbp_variable_name=""

    # log_it "normalize_bool_param($nbp_param, $nbp_default) [$nbp_variable_name]"
    [ "${nbp_param%"${nbp_param#?}"}" = "@" ] && {
        #
        #  If it starts with "@", assume it is a tmux option, thus
        #  read its value from the tmux environment.
        #  In this case $2 must be given as the default value!
        #
        [ -z "$nbp_default" ] && {
            error_msg "normalize_bool_param($nbp_param) - no default"
        }
        nbp_param="$(tmux_get_option "$nbp_param" "$nbp_default")" # TODO: profile this
    }

    nbp_value_lc="$(lowercase_it "$nbp_param")"

    case "$nbp_value_lc" in
    #
    #  Be a nice guy and accept some common positive notations
    #  Handle the unfortunate tradition in the tmux community to use
    #  1 to indicate selected / active.
    #  This means 1 is 0 and 0 is 1, how Orwellian...
    #
    1 | yes | true) return 0 ;;
    0 | no | false) return 1 ;;
    *) error_msg "[$nbp_value_lc] - should be yes/true/1 or no/false/0" ;;
    esac
}

has_lf_not_at_end() {
    log_it "has_lf_not_at_end()" # with cache:

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

# safe_now() {
#     log_it "safe_now()" # with cache:
#     #
#     #  MacOS date only display whole seconds, if gdate (GNU-date) is
#     #  installed, it can  display times with more precision
#     #
#     if [ -d /proc ] && [ -f /proc/version ]; then
#         #  On Linux the native date supports sub second precision
#         #  unless its the busybox date - only gives seconds...
#         date +%s.%N
#     else
#         # Running on macOS
#         if [ -n "$(command -v gdate)" ]; then
#             gdate +%s.%N
#         else
#             date +%s
#         fi
#     fi
# }

wait_to_close_display() {
    #
    #  When a menu item writes to stdout, unfortunately how to close
    #  the output window differs depending on dialog method used...
    #  call this to display an appropriate suggestion, and in the
    #  whiptail case wait for that key
    #
    log_it "wait_to_close_display()" # with cache:
    echo
    # shellcheck disable=SC2154
    if $cfg_use_whiptail; then
        echo "Press <Enter> to clear this output"
        read -r foo
    else
        echo "Press <Escape> to clear this output"
    fi
}

#===============================================================
#
#   Main
#
#===============================================================

[ -z "$D_TM_BASE_PATH" ] && error_msg "D_TM_BASE_PATH undefined"

#
#  Convenience shortcuts
#

d_help="$d_items"/help
d_hints="$d_items"/hints
d_custom_items="$D_TM_BASE_PATH"/custom_items
f_custom_items_index="$d_custom_items"/_index.sh
f_update_custom_inventory="$d_scripts"/update_custom_inventory.sh
f_cached_tmux_options="$d_cache"/tmux_options

# will be set to true at end of this, this indicates everything is prepared
env_initialized=false

# shellcheck source=scripts/utils/cache.sh
. "$d_scripts"/utils/cache.sh

# shellcheck source=scripts/utils/tmux.sh
. "$d_scripts"/utils/tmux.sh

# log_it "><>===================================================== $0"

if $cfg_use_whiptail; then
    menu_reload="; $f_current_script"
    #
    #  I haven't been able do to menu reload with whiptail/dialog yet,
    #  so disabled for now
    #
    reload_in_runshell=""
else
    menu_reload="; run-shell \"$f_current_script\""
    reload_in_runshell=" ; $f_current_script"
fi

env_initialized=true # indicates that env is fully configured
#clog_it "><> scripts/utils/helpers-full.sh - completed"
