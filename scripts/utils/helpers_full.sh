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

display_message() {
    dm_msg="$1"
    dm_no_hold="$2"
    # shellcheck disable=SC2154 # plugin_name defined in cache/plugin_params
    dm_msg_hold="$plugin_name: $dm_msg"

    if tmux_vers_check 1.7; then
        # "#{client_width}" - not usable before tmux 1.7
        # shellcheck disable=SC2154 # $TMUX_BIN defined in helpers_minimal.sh
        actual_win_width="$($TMUX_BIN display-message -p '#{client_width}')"
        if [ "${#dm_msg_hold}" -ge "$actual_win_width" ] || has_lf_not_at_end "$dm_msg"; then
	        display_formatted_message "$dm_msg"
        else
            display_message_hold "$dm_msg_hold" "$dm_no_hold"
        fi
    else
        # Pre tmux 1.7 screen with not accessible, always display as formatted msg
        display_formatted_message "$dm_msg" "$dm_no_hold"
    fi
}

display_message_hold() {
    #
    #  Display a message and hold until key-press
    #  Can't use tmux_error_handler() in this func, since that could trigger recursion
    #
    dmh_msg="$1"
    dmh_no_hold="$2"

    # log_it "display_message_hold($dmh_msg) no_hold: $dmh_no_hold"

    [ "$dmh_no_hold" = "no_hold" ] && {
	# request to not hold the msg
        $TMUX_BIN display-message "$dmh_msg"
	return
    }

    if tmux_vers_check 3.2; then
        # message will remain until key-press
        $TMUX_BIN display-message -d 0 "$dmh_msg"
    else
        # Manually make the error msg stay on screen a long time

        # save value in a pre tmux 1.7 safe way, not relying on show-options -v
        org_display_time="$($TMUX_BIN show-options -g display-time | cut -d' ' -f2)"
        $TMUX_BIN set -g display-time 120000 >/dev/null
        $TMUX_BIN display-message "$dmh_msg"

        posix_get_char >/dev/null # wait for keypress
        $TMUX_BIN set -g display-time "$org_display_time" >/dev/null
    fi
}

display_formatted_message() {
    #
    # Display a long (typically multi line) message in a temp window
    #
    # if _msg_type is specified, it is left to the caller to add a header if such
    # is wanted
    #
    #  This is called from error_msg_formatted(), this means
    #  tmux_error_handler(), tmux_error_handler_assign() or error_msg()
    #  Can not be used here - it could lead to infinite recursion...
    #
    _dfm_msg="$1"
    _default_msg_type="notification message"
    _msg_type="${2:-$_default_msg_type}"
    # log_it "display_formatted_message()"

    [ -z "$_dfm_msg" ] && {
        # Can't use error_msg here, so _dfm_msg is used to display this error
        _dfm_msg="display_formatted_message() - Param error: no message provided"
    }
    _msg_escaped="$(tmux_escape_for_display "$_dfm_msg")"
    _display_msg="$(
        [ "$_msg_type" = "$_default_msg_type" ] && {
	    # shellcheck disable=SC2154 # rn_current_script defined in helpers_minimal.sh
            echo "Notification from plugin $plugin_name - running: $rn_current_script"
            echo
        }
        echo "$_msg_escaped"
        echo
        echo "-----  About this full page notification   -----"
    )"
    [ "$_dfm_msg" != "$_msg_escaped" ] && {
        #region tmux _display_msg
        _display_msg="$_display_msg\n
Due to limits in what can be displayed via tmux this way,
all usages of single-quote have been replaced by backtick in this message"
        #endregion
    }
    _display_msg="$_display_msg\n
To scroll back in this ${_msg_type}:
 <prefix>-[ then up/down arrows

Press Ctrl-C to close this message
"

    $TMUX_BIN new-window -n "tmux-menus notification" "echo '$_display_msg' ; tail -f /dev/null " || {

        log_it "><> display_formatted_message() - triggered error: $?"
        exit 1
    }
}

error_msg() {
    #
    #  Logs an error and displays it via tmux, adapting to message length.
    #
    #  Handles both short messages and multi-line or long-form errors,
    #  automatically choosing between display-message and formatted output.
    #
    #  Defaults to exit code 0 to suppress tmux's less informative
    #  "pane replaced" error overlay. Use -1 to avoid exiting entirely.
    #
    #  If dont_display is non-empty, the message is only logged
    #  (useful during debugging).
    #
    em_msg="$1"
    exit_code="${2:-0}"
    dont_display="$3"

    log_it_minimal "error_msg($em_msg, $exit_code)"

    [ -z "$dont_display" ] && error_msg_actual
    [ "$exit_code" -gt -1 ] && exit "$exit_code"
}

error_msg_actual() {
    # Disable logging for the remainder of error_msg processing, to avoid getting
    # log-flooded, unless exit is not requested
    # [ "$exit_code" -gt -1 ] && cfg_log_file=""

    # log_it "error_msg_actual()"

    if [ -z "$TMUX" ]; then
        # with no tmux env, dumping it to stderr & log-file is the only output options
        log_it_minimal "***  This does not seem to be running in a tmux env  ***"
        print_stderr "$em_msg"
        return
    elif ! tmux_vers_check "1.4"; then
        # not able to generate a formatted error msg...
        (
            echo
            # shellcheck disable=SC2154 # defined in helpers_minimal.sh
            echo "error_msg() can't proceed on tmux < 1.4 - Dumping it to stderr:"
            echo "-----   start   -----"
            echo "$em_msg"
            echo "-----    end    -----"
            echo
        ) >/dev/stderr
        return
    fi

    msg_hold="$plugin_name ERR: $em_msg"
    if tmux_vers_check 1.7; then
        # "#{client_width}" - not usable before tmux 1.7
        actual_win_width="$($TMUX_BIN display-message -p '#{client_width}')"
        if [ "${#msg_hold}" -ge "$actual_win_width" ] || has_lf_not_at_end "$em_msg"; then
            error_msg_formatted "$em_msg"
        else
            display_message_hold "$msg_hold"
        fi
    else
        error_msg_formatted "$em_msg"
    fi
}

error_msg_formatted() {
    #
    #  Display an error in its own frame, supporting longer messages
    #  and also those formatted with LFs
    #
    #  Can't use tmux_error_handler() or error_msg() here - it could lead to
    #  recursion
    #
    emf_err="$1"

    # log_it "error_msg_formatted()"

    emf_msg="$(
        echo "ERROR in plugin $plugin_name - running: $rn_current_script"
        echo
        echo "$emf_err"
    )"

    display_formatted_message "$emf_msg" "error message"
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
    #  Normalizes a string into a boolean value usable in conditionals.
    #
    #  If the param starts with @, it's treated as a tmux option and read
    #  from cache (intended for @menus* vars) unless a third argument is provided,
    #  in which case the cache is bypassed.
    #
    #  Supports both direct values (e.g. "yes", "no", "true", "false") and
    #  tmux option lookups with a fallback default.
    #
    #  Examples:
    #    if normalize_bool_param "@menus_enabled" true; then ...
    #    if normalize_bool_param "$some_flag"; then ...
    #    if normalize_bool_param "@var" false no_cache; then ...
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
            error_msg "$nbp_param = [$nbp_value_lc] ($_v) - should be yes/true/1 or no/false/0"
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
    [ "$1" != "$(printf '%s' "$1" | tr '\n' 'X')" ]
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

    # SC2154: t_script_start assigned dynamically by safe_now using eval in helpers_minimal.sh
    # shellcheck disable=SC2154
    time_span "$t_script_start"

    # # SC2154: t_time_span assigned dynamically by time_span
    # # shellcheck disable=SC2154
    # log_it "-T- check_speed_cutoff($cut_off) - $t_time_span"

    # SC2154: t_time_span assigned dynamically by time_span
    # shellcheck disable=SC2154
    if [ "$(echo "$t_time_span < $cut_off" | bc)" -eq 1 ]; then
        t_minimal_display_time=0.1
    else
        # log_it "  Failed cutoff time, considered a slow system: $t_time_span >= $cut_off"
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

    #
    # If called from plugin_init.sh cfg_use_cache has already been checked, but since
    # config_setup will also be called if other things fail to read the cached
    # params, it should be re-checked here.
    # Since this will not happen regularly this overhead will not ruin general performance
    #
    # shellcheck disable=SC2154 # default_use_cache defined in tmux.sh
    if normalize_bool_param "@menus_use_cache" "$default_use_cache"; then
        cfg_use_cache=true
        safe_remove "$f_no_cache_hint" "config_setup()" config_setup
        create_param_cache
    else
        # shellcheck disable=SC2034 # cfg_use_cache used to define cache/plugin_params
        cfg_use_cache=false
        touch "$f_no_cache_hint"
        tmux_get_plugin_options
    fi
}

safe_remove() {
    #
    # Ensures what is to be removed is not a "dangerous" path that would
    # cause a mess of the file system
    # If param 2 is empty, an extra check will be made that the pattern is prefixed
    # by the location of this plugin, only use param 2 if something outside
    # the plugin location needs to be removed
    #
    pattern="$1"
    reason="$2"
    skip_plugin_name_in_path_check="$3"

    # log_it "safe_remove($pattern) - $reason"
    [ -z "$pattern" ] && error_msg "safe_remove() - no path supplied!"
    [ -z "$reason" ] && error_msg "safe_remove() - no reason given!"

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
            error_msg "$_s"
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
    # if ps -x "$PPID" 2>/dev/null | grep -q tmux-menus && $cfg_use_whiptail; then
    _b_is_whiptail=false
    case $(ps -o command= -p "$PPID" 2>/dev/null) in
    *tmux-menus*)
        # shellcheck disable=SC2154 # cfg_use_whiptail defined in settings
        [ "$cfg_use_whiptail" = true ] && _b_is_whiptail=true
        ;;
    *) ;;
    esac
    if [ "$_b_is_whiptail" = true ]; then
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
    # SC2154: d_scripts  defined in helpers_minimal.sh
    # shellcheck disable=SC2154 source=scripts/utils/cache.sh
    . "$d_scripts"/utils/cache.sh

    # shellcheck source=scripts/utils/tmux.sh
    . "$d_scripts"/utils/tmux.sh
}

set_display_command_labels() {
    # log_it "set_display_command_labels() - $show_cmds_state"

    # shellcheck disable=SC2154 # show_cmds_state defined in display_commands_toggle()
    case "$show_cmds_state" in
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

parse_move_link_dest() {
    #
    # Used by relocate_pane.sh & relocate_window.sh to parse the destination
    # parameter, to check for validity and split it into its components
    #
    #  inputs:
    #    with pane idx:      =main:1.%13
    #    with window idx:    =main:3.
    #    without window idx: =main:
    #
    #  Defines:
    #   cur_ses
    #   dest_ses
    #   dest_win_idx
    #   dest_pane_idx
    #
    _raw_dest="$1"

    if [ -z "$_raw_dest" ]; then
        error_msg "parse_move_link_dest() - no destination param given!"
    fi

    tmux_error_handler_assign cur_ses display-message -p '#S'

    _dest="${_raw_dest#*=}" # skipping initial =
    _win_pane="${_dest#*:}" # after first colon
    # shellcheck disable=SC2034 # used in relocate_pane.sh & relocate_window.sh
    {
        dest_ses="${_dest%%:*}"         # up to first colon excluding it
        dest_win_idx="${_win_pane%%.*}" # up to first dot excluding it
        dest_pane_idx="${_win_pane#*.}"
    }
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

# shellcheck disable=SC2034 # defined as full env for other scripts
{
    # shellcheck disable=SC2154 # defined in helpers_minimal.sh
    d_help="$d_items"/help

    d_hints="$d_items"/hints
    d_custom_items="$D_TM_BASE_PATH"/custom_items
    f_custom_items_index="$d_custom_items"/_index.sh
    f_chksum_custom="$d_cache"/chksum_custom_content
    f_min_display_time="$d_cache"/min_display_time
}

f_cached_tmux_options="$d_cache"/tmux_options

helpers_full_additional_files_sourced

# shellcheck disable=SC2034 # defined as full env for other scripts
env_initialized=2 # indicates that env is fully configured

# log_it "><> [$$] scripts/utils/helpers_full.sh - completed [$0]"
