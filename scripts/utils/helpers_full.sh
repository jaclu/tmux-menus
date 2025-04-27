#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  The rest of the helpers
#

#---------------------------------------------------------------
#
#   Logging and error msgs
#
#---------------------------------------------------------------

error_msg() {
    #
    #  Display an error message in log and as a tmux display-message
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
    #  display-message that is shown.
    #  If exit_code is set to -1, process is not exited
    #
    em_msg="$1"
    exit_code="${2:-0}"
    log_it_minimal "error_msg($em_msg, $exit_code)"

    [ -z "$TMUX" ] && {
        # with no tmux env, dumping it to stderr & log-file is the only output options
        log_it_minimal "***  This does not seem to be running in a tmux env  ***"
    }

    log_it_minimal
    log_it_minimal "ERROR: $em_msg"
    log_it_minimal

    [ -n "$TMUX" ] && {
        # shellcheck disable=SC2154
        msg_hold="$plugin_name ERR: $em_msg"
        # shellcheck disable=SC2154
        if [ "$env_initialized" -eq 2 ] && (
            actual_win_width="$($TMUX_BIN display-message -p "#{client_width}")"
            [ "${#msg_hold}" -ge "$actual_win_width" ] || has_lf_not_at_end "$em_msg"
        ); then
            error_msg_formated "$em_msg"
        else
            display_message_hold "$msg_hold"
        fi
    }

    [ "$exit_code" -gt -1 ] && exit "$exit_code"
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

    # log_it "error_msg_formated($emf_err)"

    emf_msg="$(
        # shellcheck disable=SC2154
        echo "ERROR in plugin $plugin_name: $(relative_path "$0") [$$]"
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
    $TMUX_BIN new-window -n "tmux-error" "echo '$emf_msg' ; tail -f /dev/null "
}

display_message_hold() {
    #
    #  Display a message and hold until key-press
    #  Can't use tmux_error_handler() in this func, since that could trigger recursion
    #
    dmh_msg="$1"
    # log_it "display_message_hold($dmh_msg)"

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
    fi
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
    _org_stty=$(stty -g)
    stty raw -echo
    dd bs=1 count=1 2>/dev/null
    stty "$_org_stty"
}

extract_char() {
    _str="$1"
    _pos="$2"
    printf '%s\n' "$_str" | cut -c "$_pos"
}

lowercase_it() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

get_digits_from_string() {
    # this is used to get "clean" integer version number. Examples:
    # `tmux 1.9` => `19`
    # `1.9a`     => `19`

    _i="$(echo "$1" | tr -dC '[:digit:]')"
    echo "$_i"
}

normalize_bool_param() {
    #
    # Take a boolean style text param and convert it into an actual boolean
    # that can be used in your code. If the param starts with @ it is first read
    # from tmux
    #
    # For performance reasons all @menus... params are cached once when cache is
    # initialized. In case some other tmux variable needs to be checked,
    # ignore this cache and do a read by providing a third param, "no_cache" or similar,
    # it's content doesn't matter, if a 3rd param is provided, the cache will be ignored.
    #
    #    Examples of usage:
    #
    # if normalize_bool_param "@menus_without_prefix" "$default_no_prefix"; then
    #     cfg_no_prefix=true
    # else
    #     cfg_no_prefix=false
    # fi
    #
    #  if normalize_bool_param "$wt_pasting" false no_cache; then
    #
    #  # boolean check on regular variable - no default is needed
    #  a="YES"
    #  if normalize_bool_param "$a"; then
    #      do thing is it was true
    #  fi
    #
    nbp_param="$1"
    nbp_default="$2"  # only needed for tmux options
    nbp_no_cache="$3" # if non-empty, the cache will be ignored

    # log_it "normalize_bool_param($nbp_param, $nbp_default) [$nbp_no_cache]"
    if [ "${nbp_param%"${nbp_param#?}"}" = "@" ]; then
        #
        #  If it starts with "@", assume it is a tmux option, thus
        #  read its value from the tmux environment.
        #  In this case $2 must be given as the default value!
        #
        _tmux_param=true
        [ -z "$nbp_default" ] && {
            error_msg "normalize_bool_param($nbp_param) - no default"
        }
        tmux_get_option _v "$nbp_param" "$nbp_default" "$nbp_no_cache"
    else
        _tmux_param=false
        _v="$nbp_param"
    fi
    nbp_value_lc="$(lowercase_it "$_v")"
    case "$nbp_value_lc" in
    #
    #  Be a nice guy and accept some common positive notations
    #  Handle the unfortunate tradition in the tmux community to use
    #  1 to indicate selected / active.
    #  This means 1 is 0 and 0 is 1, how Orwellian...
    #
    1 | yes | true) return 0 ;;
    0 | no | false) return 1 ;;
    *)
        if $_tmux_param; then
            error_msg "$nbp_param = [$nbp_value_lc] - should be yes/true/1 or no/false/0"
        else
            error_msg "[$nbp_param] - should be yes/true/1 or no/false/0"
        fi
        ;;
    esac
}

has_lf_not_at_end() {
    # log_it "has_lf_not_at_end()" # with cache:

    #
    #  POSIX hack I came up with to check if a string contains LF
    #  somewhere within, since I could not figure out how to to substring
    #  search for LF in this env
    #
    # shellcheck disable=SC2059
    [ "$1" != "$(printf "$1" | tr '\n' 'X')" ]
}

is_int() {
    case $1 in
    '' | *[!0-9]*) return 1 ;; # Contains non-numeric characters
    *) return 0 ;;             # Contains only digits
    esac
}

#---------------------------------------------------------------
#
#   Get some not often used states
#
#---------------------------------------------------------------

get_screen_size_variables() {
    # Sets variables current_screen_rows & current_screen_cols - indicating screen-size
    log_it "get_screen_size_variables()"
    tmux_error_handler_assign current_screen_rows display-message -p "#{client_height}"
    tmux_error_handler_assign current_screen_cols display-message -p "#{client_width}"
}

#---------------------------------------------------------------
#
#   minimal display time to trigger screen might be too small warning
#
#---------------------------------------------------------------

check_speed_cutoff() {
    # if processing was slower than the supplied param, set a higher minimal
    # display time before triggering "SCREEN might be too small" warning
    cut_off="$1"

    # log_it "-T- check_speed_cutoff($cut_off)"
    safe_now
    # shellcheck disable=SC2154
    t_init="$(echo "$t_now - $t_script_start" | bc)"
    if [ "$(echo "$t_init < $cut_off" | bc)" -eq 1 ]; then
        t_minimal_display_time=0.1
    else
        log_it "  Failed cutoff time, considered a slow system: $t_init >= $cut_off"
        # for slower systems
        t_minimal_display_time=0.5
    fi
}

#---------------------------------------------------------------
#
#   Other
#
#---------------------------------------------------------------

config_setup() {
    # Examins tmux env, and depending on caching config either plainly read
    # tmux.conf, or prepare a f_cache_params
    # log_it "config_setup()"

    # only need default_use_cache at this point but might as well get them all
    tmux_get_defaults
    if normalize_bool_param "@menus_use_cache" "$default_use_cache"; then
        cfg_use_cache=true
        # shellcheck disable=SC2154
        safe_remove "$f_no_cache_hint" config_setup
        create_param_cache
    else
        touch "$f_no_cache_hint"
        tmux_get_plugin_options
    fi
}

safe_remove() {
    pattern="$1"
    skip_plugin_name_in_path_check="$2"

    # log_it "--->>  safe_remove($pattern)"
    [ -z "$pattern" ] && error_msg "safe_remove() - no param supplied!"

    tmpdir_noslash="${TMPDIR%/}" # Remove trailing slash if present

    case "$pattern" in
    "$tmpdir_noslash") # Prevent direct removal of TMPDIR
        error_msg "safe_remove() - refusing to delete TMPDIR itself: $pattern"
        return 1
        ;;
    "$tmpdir_noslash"/*) ;; # Allow anything inside TMPDIR
    /etc | /etc/* | /usr | /usr/* | /var | /var/* | "$HOME" | /home | \
        /Users | /bin | /bin/* | /sbin | /sbin/* | /lib | /lib/* | \
        /lib64 | /lib64/* | /boot | /boot/* | /mnt | /mnt/* | /media | /media/* | \
        /run | /run/* | /opt | /opt/* | /root | /root/* | /dev | /dev/* | \
        /proc | /proc/* | /sys | /sys/* | /lost+found | /lost+found/*)
        error_msg "safe_remove() - refusing to delete protected directory: $pattern"
        return 1
        ;;
    *) ;;
    esac

    [ -z "$skip_plugin_name_in_path_check" ] && {
        case "$pattern" in
        *"$plugin_name"*) ;;
        *)
            _s="safe_remove($pattern) seems wrong - $plugin_name not in that path"
            error_msg_safe "$_s"
            ;;
        esac
    }

    rm -rf "$pattern" || error_msg "safe_remove() - Failed to delete: $pattern"
    return 0
}

wait_to_close_display() {
    #
    #  When a menu item writes to stdout, unfortunately how to close
    #  the output window differs depending on dialog method used...
    #  call this to display an appropriate suggestion, and in the
    #  whiptail case wait for that key
    #
    #  Busybox ps has no -x and will throw error, so send to /dev/null
    #  pgrep does not provide the command line, so ignore SC2009
    #  shellcheck disable=SC2009
    if ps -x "$PPID" 2>/dev/null | grep -q tmux-menus && $cfg_use_whiptail; then
        #
        # called using whiptail menus, since a pause is needed, before what
        # might be a backgrounded process is resumed
        #
        echo " "
        echo "Press <Enter> to clear this output"
        read -r _
    else
        if [ ! -t 0 ]; then
            #
            #  Not from command-line, ie most likely called from the menus.
            #  Menu is already closed, so we can't check PPID or similar
            #
            echo " "
            echo "Press <q> or <Escape> to clear this output"
        fi
    fi
}

helpers_full_additional_files_sourced() {
    # shellcheck disable=SC2154 source=scripts/utils/cache.sh
    . "$d_scripts"/utils/cache.sh

    # shellcheck source=scripts/utils/tmux.sh
    . "$d_scripts"/utils/tmux.sh
}

display_command_label() {
    # log_it "display_command_label() - $TMUX_MENUS_SHOW_CMDS"

    # shellcheck disable=SC2154
    case "$TMUX_MENUS_SHOW_CMDS" in
    1)
        _lbl="Display Commands"
        _lbl_next="Display key binds"
        _idx_next=2
        ;;
    2)
        _lbl="Display key binds"
        _lbl_next="Hide key binds"
        _idx_next=0
        ;;
    *)
        _lbl="Hide key binds"
        _lbl_next="Display Commands"
        _idx_next=1
        ;;
    esac
}

#===============================================================
#
#   Main
#
#===============================================================

# log_it "><> [$$] STARTING: scripts/utils/helpers_full.sh"

#
#  Convenience shortcuts
#

# shellcheck disable=SC2034
{
    # shellcheck disable=SC2154
    d_help="$d_items"/help

    d_hints="$d_items"/hints
    d_custom_items="$D_TM_BASE_PATH"/custom_items
    f_custom_items_index="$d_custom_items"/_index.sh
    f_chksum_custom="$d_cache"/chksum_custom_content
    f_cached_tmux_key_binds="$d_cache"/tmux_key_binds
    f_min_display_time="$d_cache"/min_display_time
}

f_cached_tmux_options="$d_cache"/tmux_options

helpers_full_additional_files_sourced

env_initialized=2 # indicates that env is fully configured
# log_it "><> [$$] scripts/utils/helpers_full.sh - completed [$0]"
