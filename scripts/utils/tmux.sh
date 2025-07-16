#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Handling tmux env
#

tmux_vers_check_do_compare() {
    # Called fomh helpers_minimal.sh:tmux_vers_check() if checked version was not cached
    _v_comp="$1"
    [ -z "$_v_comp" ] && error_msg "tmux_vers_check_do_compare() - no param!"
    # log_it "tmux_vers_check_do_compare($_v_comp)"

    # Compare numeric parts first for quick decisions.
    tpt_digits_from_string _i_comp "$_v_comp"

    # SC2154: _i_comp assigned dynamically by tpt_digits_from_string using eval
    #         current_tmux_vers_i defined in cache.sh
    # shellcheck disable=SC2154
    [ "$_i_comp" -lt "$current_tmux_vers_i" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    [ "$_i_comp" -gt "$current_tmux_vers_i" ] && {
        cache_add_bad_vers "$_v_comp"
        return 1
    }

    # Compare suffixes only if numeric parts are equal.
    tpt_tmux_vers_suffix _suf "$_v_comp"
    # - If no suffix is required or suffix matches, return success
    if [ -z "$_suf" ] || [ "$_suf" = "$current_tmux_vers_suffix" ]; then
        cache_add_ok_vers "$_v_comp"
        return 0
    fi
    # If the desired version has a suffix but the running version doesn't, fail
    [ -n "$_suf" ] && [ -z "$current_tmux_vers_suffix" ] && {
        cache_add_bad_vers "$_v_comp"
        return 1
    }
    # Perform lexicographical comparison of suffixes only if necessary
    [ "$(printf '%s\n%s\n' "$_suf" "$current_tmux_vers_suffix" |
        LC_COLLATE=C sort | head -n 1)" = "$_suf" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    # If none of the above conditions are met, the version is insufficient
    cache_add_bad_vers "$_v_comp"
    return 1
}

tmux_get_defaults() { # new init
    #
    #  Defaults for plugin params
    #
    #  Public variables
    #   default_  defaults for tmux config options
    #

    # log_it "tmux_get_defaults()"

    default_trigger_key=\\
    default_no_prefix=No

    # Since default_use_cache is needed early on, before this function can be
    # called, it is defined in the main segment of this script

    if tmux_vers_check 3.2; then
        default_location_x=C
        default_location_y=C
    else
        default_location_x=P
        default_location_y=P
    fi

    default_format_title="'#[align=centre] #{@menu_name} '"
    default_border_type="EMPTY"
    default_simple_style_selected="EMPTY"
    default_simple_style="EMPTY"
    default_simple_style_border="EMPTY"
    default_nav_next="-->"
    default_nav_prev="<--"
    default_nav_home="<=="

    default_display_commands=No
    default_display_cmds_cols=75

    default_use_hint_overlays=Yes
    default_show_key_hints=No

    if [ -n "$TMUX_CONF" ]; then
        default_tmux_conf="$TMUX_CONF"
    elif [ -n "$XDG_CONFIG_HOME" ]; then
        default_tmux_conf="$XDG_CONFIG_HOME/tmux/tmux.conf"
    else
        default_tmux_conf="$HOME/.tmux.conf"
    fi
    default_log_file="EMPTY"
}

cache_save_options_defined_in_tmux() {
    #
    #  On slow systems, doing individual show-options takes a ridiculous amount of
    #  time. Here we read all relevant options in one go and store them in a cache file
    #
    # shellcheck disable=SC2154 # defined in helpers_full.sh
    [ -f "$f_cached_tmux_options" ] && return
    # log_it "cache_save_options_defined_in_tmux()"
    # shellcheck disable=SC2154 # TMUX_BIN defined in helpers_minimal.sh
    $TMUX_BIN show-options -g | grep ^@menus_ >"$f_cached_tmux_options"
    $TMUX_BIN show-options -g | grep @use_bind_key_notes_in_plugins \
        >>"$f_cached_tmux_options"
    # log_it "  <-- cache_save_options_defined_in_tmux() - wrote: $f_cached_tmux_options"
}

tmux_get_option() {
    tgo_varname="$1" # The variable name to store the result in
    tgo_option="$2"
    tgo_default="$3"
    # if non-empty, prevent cache from being used - when options other than
    #  @menux_ needs to be read
    tgo_no_cache="$4"

    # log_it "tmux_get_option($tgo_varname, $tgo_option, $tgo_default, $tgo_no_cache)"
    # usually disabled for performance
    validate_varname "$tgo_varname" "tmux_get_option()"

    # [ -z "$tgo_varname" ] && error_msg "tmux_get_option() param 1 empty!"
    [ -z "$tgo_option" ] && error_msg "tmux_get_option() param 2 empty!"
    [ -z "$tgo_default" ] && log_it "tmux_get_option($tgo_option) - No default supplied"

    [ "$tgo_default" = "EMPTY" ] && {
        # a bit of a hack, supply something so the No default supplied isn't displayed
        # yet still set default to empty string
        tgo_default=""
    }

    # shellcheck disable=SC2154 # cfg_use_cache sourced or defined in other support scripts
    if [ -z "$tgo_no_cache" ] && $cfg_use_cache && [ -d "$d_cache" ]; then
        tgo_use_cache=true
    else
        tgo_use_cache=false
    fi

    if [ -z "$TMUX" ]; then
        # this is run standalone outside tmux, just report the defaults
        log_it "tmux_get_option() - no \$TMUX - using default"
        _line=""
    elif ! tmux_vers_check 1.8; then
        # before 1.8 no support for user options
        log_it "tmux_get_option() - tmux < 1.8 - User options not available, using default"
        _line=""
    elif $tgo_use_cache; then
        cache_save_options_defined_in_tmux

        if [ -d /proc/ish ]; then
            # much slower due to subshell, but iSH lacks /dev so the quick method
            # below can't be used
            _line=$(grep "$tgo_option " "$f_cached_tmux_options")
        else
            # more code, but noticeably faster than doing a grep on the file on slow systems
            _line=
            while IFS= read -r _cache_line; do
                # space after tgo_option needed in order to not find
                # @menus_simple_style_border when looking for @menus_simple_style
                case $_cache_line in
                "$tgo_option "*)
                    _line=$_cache_line
                    break
                    ;;
                *) ;;
                esac
            done <"$f_cached_tmux_options"
        fi
    else
        # log_it "tmux_get_option($tgo_option) - not using cache"
        _line="$($TMUX_BIN show-options -g "$tgo_option" 2>/dev/null)"
    fi

    if [ -z "$_line" ]; then
        # correctly captures undefined options, not getting confused if
        # option was empty ie "", which confuses tmux 3.0–3.2a returning success
        # if using show-options  on undefined options
        tgo_value="$tgo_default"
    else
        # shell built-in string splitting and unqoting avoids spawning external processes

        # Extract value (skip key)
        tgo_value=${_line#* }

        case $tgo_value in
        \"*\")
            # Remove outer double quotes, if present
            tgo_value=${tgo_value#\"}
            tgo_value=${tgo_value%\"}
            ;;
        *) ;;
        esac
    fi
    # log_it "tmux_get_option() - using [$tgo_value]"
    eval "$tgo_varname=\"\$tgo_value\""
}

fix_home_path() {
    #
    #  Normalizes plugin variables containing $HOME or ~, which may be passed
    #  as single-quoted strings in tmux.conf due to outdated HOWTOs and habits.
    #
    #  Tmux versions prior to 3.0 expanded $HOME and ~ even when quoted oddly,
    #  but from 3.0 onward, such values are treated literally. Version 3.4
    #  adds further inconsistency by escaping $HOME differently.
    #
    #  This function detects the tmux version and expands $HOME or ~ paths
    #  to full absolute paths. A sanity check ensures the result looks valid,
    #  guarding against future behavioral changes in tmux.
    #
    #  Usage:
    #    fix_home_path "$org_log_file" log_file    # Sets fixed path directly (faster)
    #    log_file=$(fix_home_path "$org_log_file") # Prints fixed path forking a sub-shell
    #
    fhp_path="$1"
    fhp_varname="$2"

    # log_it "fix_home_path($fhp_varname,$fhp_path)"

    if false; then
        # For performance reasons full variable name assessment when is disabled by default
        validate_varname "$fhp_varname" "fix_home_path()"
    else
        [ -z "$fhp_varname" ] && error_msg "fix_home_path() param 1 empty!"
    fi
    [ -z "$fhp_path" ] && error_msg "fix_home_path() param 2 empty!"

    # But of course tmux changed how they escpe options starting with ~ or $HOME...
    if tmux_vers_check 3.4 && ! tmux_vers_check 3.5; then
        # Special case for tmux 3.4
        case "$fhp_path" in
        \\~/*)
            fhp_path="${fhp_path#\\}"        # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\~}" # Expand ~ to $HOME
            ;;
        \\\\\$HOME/*)
            fhp_path="${fhp_path#\\\\}"          # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\$HOME}" # Expand $HOME
            ;;
        *) ;;
        esac
    elif tmux_vers_check 3.0; then
        case "$fhp_path" in
        \\~/*)
            fhp_path="${fhp_path#\\}"        # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\~}" # Expand ~ to $HOME
            ;;
        \\\$HOME/*)
            fhp_path="${fhp_path#\\}"            # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\$HOME}" # Expand ~ to $HOME
            ;;
        *) ;;
        esac
    else
        case "$fhp_path" in
        \~/*)
            fhp_path="${fhp_path#\\}"        # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\~}" # Expand ~ to $HOME
            ;;
        \$HOME/*)
            fhp_path="${fhp_path#\\}"            # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\$HOME}" # Expand $HOME
            ;;
        *) ;;
        esac
    fi

    echo "$fhp_path" | grep -q \~ && {
        error_msg "fix_home_path() - Failed to expand ~ in: $fhp_path"
    }
    echo "$fhp_path" | grep -q \$HOME && {
        error_msg "fix_home_path() - Failed to expand \$HOME in: $fhp_path"
    }

    if [ -n "$fhp_varname" ]; then
        eval "$fhp_varname=\"\$fhp_path\""
    else
        echo "$fhp_path"
    fi
}

tmux_get_plugin_options() { # new init
    #
    #  This only reads all plugin options from tmux env, any decisions based
    #  on debug variables etc are handled by create_param_cache()
    #
    #  Public variables
    #   cfg_  config variables, either read from tmux or the default
    #
    # log_it "tmux_get_plugin_options()"
    tmux_get_defaults

    tmux_get_option cfg_trigger_key "@menus_trigger" "$default_trigger_key"

    if normalize_bool_param "@menus_without_prefix" "$default_no_prefix"; then
        cfg_no_prefix=true
    else
        # shellcheck disable=SC2034 # variable used to define cache/plugin_params
        cfg_no_prefix=false
    fi

    if ! tmux_vers_check 3.0; then
        # if on next plugin_setup a menus able tmux is detected the relevant
        # additional settings will be cached
        if command -v whiptail >/dev/null; then
            cfg_alt_menu_handler=whiptail
        elif command -v dialog >/dev/null; then
            cfg_alt_menu_handler=dialog
        else
            error_msg "Neither whiptail or dialog found, plugin aborted"
        fi
        log_it "--- Activating cfg_use_whiptail [$cfg_alt_menu_handler] due to tmux < 3.0"
        cfg_use_whiptail=true
    else
        cfg_use_whiptail=false
        # shellcheck disable=SC2034 # variable used to define cache/plugin_params
        cfg_alt_menu_handler=""
    fi

    handle_env_variables # potential cfg_use_whiptail override

    if $cfg_use_whiptail; then
        # variables only used by whiptail
        # shellcheck disable=SC2034 # cfg_ variables used to define cache/plugin_params
        {
            cfg_display_cmds=false
            cfg_use_hint_overlays=false
            cfg_show_key_hints=false
            cfg_nav_next="$default_nav_next"
            cfg_nav_prev="$default_nav_prev"
            cfg_nav_home="$default_nav_home"

            # not a config variable as such, just used as paste bufferr for
            # missing keys and currencies
            wt_pasting="@tmp_menus_wt_paste_in_progress"
        }
    else
        tmux_get_option cfg_mnu_loc_x "@menus_location_x" "$default_location_x"
        tmux_get_option cfg_mnu_loc_y "@menus_location_y" "$default_location_y"
        tmux_get_option cfg_format_title "@menus_format_title" "$default_format_title"

        tmux_vers_check 3.4 && {
            tmux_get_option cfg_border_type "@menus_border_type" "$default_border_type"
            tmux_get_option cfg_simple_style_selected "@menus_simple_style_selected" \
                "$default_simple_style_selected"
            tmux_get_option cfg_simple_style "@menus_simple_style" \
                "$default_simple_style"
            tmux_get_option cfg_simple_style_border "@menus_simple_style_border" \
                "$default_simple_style_border"
        }
        tmux_get_option cfg_nav_next "@menus_nav_next" "$default_nav_next"
        tmux_get_option cfg_nav_prev "@menus_nav_prev" "$default_nav_prev"
        tmux_get_option cfg_nav_home "@menus_nav_home" "$default_nav_home"
        if normalize_bool_param "@menus_display_commands" "$default_display_commands"; then
            cfg_display_cmds=true
            tmux_get_option cfg_display_cmds_cols "@menus_display_cmds_cols" \
                "$default_display_cmds_cols"

            # SC2154: variable assigned dynamically by tmux_get_option using eval
            # shellcheck disable=SC2154
            is_int "$cfg_display_cmds_cols" || {
                error_msg "@menus_display_cmds_cols is not int: $cfg_display_cmds_cols"
            }
        else
            cfg_display_cmds=false
        fi
        if normalize_bool_param "@menus_use_hint_overlays" "$default_use_hint_overlays"; then
            cfg_use_hint_overlays=true
        else
            # shellcheck disable=SC2034 # variable used to define cache/plugin_params
            cfg_use_hint_overlays=false
        fi
        if normalize_bool_param "@menus_show_key_hints" "$default_show_key_hints"; then
            cfg_show_key_hints=true
        else
            cfg_show_key_hints=false
        fi
    fi

    tmux_get_option _tmux_conf "@menus_config_file" "$default_tmux_conf"
    # Handle the case of ~ or $HOME being wrapped in single quotes in tmux.conf
    if [ -n "$_tmux_conf" ]; then
        fix_home_path "$_tmux_conf" cfg_tmux_conf
    else
        # shellcheck disable=SC2034 # variable used to define cache/plugin_params
        cfg_tmux_conf=""
    fi

    # shellcheck disable=SC2154 # defined in helpers_minimal.sh
    [ "$log_file_forced" != 1 ] && {
        #  If a debug logfile has been set, the tmux setting will be ignored.
        # log_it "tmux will read cfg_log_file"
        tmux_get_option _log_file "@menus_log_file" "$default_log_file"
        # Handle the case of ~ or $HOME being wrapped in single quotes in tmux.conf
        if [ -n "$_log_file" ]; then
            fix_home_path "$_log_file" cfg_log_file
        else
            # shellcheck disable=SC2034 # variable used to define cache/plugin_params
            cfg_log_file=""
        fi
    }
    #
    #  Generic plugin setting I use to add Notes to keys that are bound
    #  This makes this key binding show up when doing <prefix> ?
    #  If not set to "Yes", no attempt at adding notes will happen
    #  bind-key Notes were added in tmux 3.1, so should not be used on
    #  older versions!
    #
    if tmux_vers_check 3.1 &&
        normalize_bool_param "@use_bind_key_notes_in_plugins" No; then
        cfg_use_notes=true
    else
        # shellcheck disable=SC2034 # variable used to define cache/plugin_params
        cfg_use_notes=false
    fi
}

use_whiptail_env() {
    # if this is moved to helpers_minimal, ensure to also
    # move the required defaults to that file
    # log_it "use_whiptail_env()"
    if $cfg_use_whiptail; then
        # shellcheck disable=SC2034 # variables used to define cache/plugin_params
        {
            cfg_display_cmds=false
            cfg_show_key_hints=false
        }
    fi
}

tmux_escape_for_display() {
    echo "$@" | sed "s/'/\`/g" | sed 's/#/##/g'
}

tmux_error_handler() {
    teh_store_result=false
    # fake assigning a variable in order to use the same func
    tmux_error_handler_assign _foo "$@"
}

tmux_error_handler_assign() { # cache references
    #
    #  Detects any errors reported by tmux commands and aborts displaying the error
    #
    #  Assigning the supplied variable name instead of printing output in a subshell,
    #  for better performance
    #
    #  If teh_debug is set to true, extensive debug logging will happen
    #  this will be set back to false at the end of this, so it needs to be
    #  enabled for each call specifically
    #
    varname="$1"
    shift
    #
    #  This will loose quotes etc, but since is doesn't cost any overhead to generate
    #  it is "good enough" for logging and error displays
    #
    cmd_simplified="$*"

    # # debug check that teh_debug is always set
    # case "$teh_debug" in
    # true | false) ;;
    # *) error_msg "tmux_error_handler_assign() = teh_debug invalid: [$teh_debug]" ;;
    # esac

    $teh_debug && {
        # in principle this should be done every time, but limited to when
        # logging, to minimize overhead
        validate_varname "$varname" "tmux_error_handler_assign()"

        if $teh_store_result; then
            log_it "tmux_error_handler_assign(\$TMUX_BIN $cmd_simplified) -> $varname"
        else
            log_it "tmux_error_handler(\$TMUX_BIN $cmd_simplified)"
        fi
    }

    # Define a location where to store the potentiall error output
    # and create a file name based on this location
    if $cfg_use_cache; then
        d_errors="$d_cache"
    else
        # shellcheck disable=SC2154 # defined in helpers_minimal.sh
        d_errors="$d_tmp"
    fi
    # ensure it exists
    [ ! -d "$d_errors" ] && mkdir -p "$d_errors"
    f_tmux_err="$d_errors"/tmux-errror-in-last-command-if-not-empty

    #
    # Run the actual command and save any error output. If the command succeeded
    # just ignore the empty error output file
    #
    if $teh_store_result; then
        value=$($TMUX_BIN "$@" 2>"$f_tmux_err")
    else
        $TMUX_BIN "$@" 2>"$f_tmux_err" >/dev/null
    fi
    ex_code="$?"
    $teh_debug && {
        if $teh_store_result; then
            log_it "tmux handler: cmd done - excode:$ex_code - output: >>$value<<"
        else
            log_it "tmux handler: cmd done - excode:$ex_code"
        fi
    }

    #
    # Parse any error output
    #
    if [ "$ex_code" != 0 ] || [ -s "$f_tmux_err" ]; then
        _err_output=$(cat "$f_tmux_err")

        #
        #  First save the error to a named file
        #
        f_error_base="$d_errors/error-"
        [ "$d_errors" != "$d_cache" ] && f_error_base="${f_error_base}tmux-menus-"
        f_error_base="${f_error_base}$(tr -cs '[:alnum:]._' '_' <"$f_tmux_err")"

        _idx=0
        f_error_log="$f_error_base"
        while [ -f "$f_error_log" ]; do
            _idx=$((_idx + 1))
            f_error_log="${f_error_base}-$_idx"
            [ "$_idx" -gt 1000 ] && error_msg "Aborting runaway loop - _idx=$_idx"
        done

        echo "\$TMUX_BIN $cmd_simplified" >"$f_error_log"
        rm "$f_tmux_err"

        if $teh_debug; then
            log_it "tmux cmd failed:\n\n$(cat "$f_error_log")\n"
            exit 1
        else
            log_it "saved error to: $f_error_log"
            #region tmux _e_msg
            _e_msg="$(
                cat <<EOF
tmux cmd failed ($ex_code):

-----  Error msg:   -----
$_err_output
-------------------------

-----   Failed tmux command   -----
$(cat "$f_error_log")
-----------------------------------

The error message has been saved in:
  $(relative_path "$f_error_log")

Full path: $f_error_log
EOF
            )"
            #endregion
            [ "$_e_msg" != "$(tmux_escape_for_display "$_e_msg")" ] && {
                # Something was escaped, emphasize that the error file is unmodified
                _s="The error file always contains the unmodified command"
                _e_msg="$_e_msg \n\n==>  $_s  <=="
            }
            error_msg "$_e_msg"
        fi
        return 1 # shouldn't get here, but at least return an error
    fi

    #
    # Depending on call type, potentially save output in caller supplied variable name
    #
    $teh_store_result && eval "$varname=\"\$value\""

    teh_store_result=true # reset this for the next call
    teh_debug=false       # This needs to be enabled on a per call basis
    return 0
}

#===============================================================
#
#   Main
#
#===============================================================

# The default for tmux_error_handler_assign() is to store result in a provided
# variable. When no output is needed call tmux_error_handler() this sets this
# to false then call tmux_error_handler_assign() with a dummy variable name
# that will be ignored. At the end of tmux_error_handler_assign() this will be set
# to true again. This is needed to initialize the variable so that a first call
# to tmux_error_handler_assign() will behave as expected
teh_store_result=true

#
# tmux_error_handler & tmux_error_handler_assign never log normally.
# If a specific call should be logged set this to true, it will be disabled again
# at the end of the call
#
teh_debug=false

#
# Since default_use_cache is needed early on, before tmux_get_defaults() can be
# called, it is defined here
#

# shellcheck disable=SC2034 # used in helpers_full.sh
default_use_cache=Yes

# log_it "===  Completed: scripts/utils/tmux.sh  =="
