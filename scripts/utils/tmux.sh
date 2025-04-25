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

    # shellcheck disable=SC2034
    default_use_cache=Yes

    if tmux_vers_check 3.2; then
        default_location_x=C
        default_location_y=C
    else
        default_location_x=P
        default_location_y=P
    fi

    default_format_title="'#[align=centre]  #{@menu_name} '"
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
    # shellcheck disable=SC2154
    [ -f "$f_cached_tmux_options" ] && return
    # log_it "cache_save_options_defined_in_tmux()"
    # shellcheck disable=SC2154
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

    validate_varname "$tgo_varname" "tmux_get_option()"
    # [ -z "$tgo_varname" ] && error_msg "tmux_get_option() param 1 empty!"
    [ -z "$tgo_option" ] && error_msg "tmux_get_option() param 2 empty!"
    [ -z "$tgo_default" ] && log_it "tmux_get_option($tgo_option) - No default supplied"

    [ "$tgo_default" = "EMPTY" ] && {
        # a bit of a hack, supply something so the No default supplied isn't displayed
        # yet still set default to empty string
        tgo_default=""
    }

    # shellcheck disable=SC2154
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
        log_it "tmux_get_option() - tmux < 1.8 - using default"
        _line=""
    elif $tgo_use_cache; then
        cache_save_options_defined_in_tmux
        # more code, but noticeably faster than doing a grep on the file on slow systems
        _line=
        while IFS= read -r _cache_line; do
            case $_cache_line in
            "$tgo_option"*)
                _line=$_cache_line
                break
                ;;
            *) ;;
            esac
        done <"$f_cached_tmux_options"
    else
        # log_it "tmux_get_option($tgo_option) - not using cache"
        _line="$($TMUX_BIN show-options -g "$tgo_option" 2>/dev/null)"
    fi

    if [ -z "$_line" ]; then
        tgo_value="$tgo_default"
    else
        # shell built-in string splitting and unqoting avoids spawning external processes

        # shellcheck disable=SC2086
        set -- $_line
        tgo_value=${2#\"}         # get rid of pottential ""
        tgo_value=${tgo_value%\"} # wrapping
    fi
    # log_it "tmux_get_option() - using [$tgo_value]"
    eval "$tgo_varname=\"\$tgo_value\""
}

fix_home_path() {
    #
    #  If a variable with ~ or $HOME is wrapped in single quotes in tmux.conf,
    #  those will be prefixed with \ and thus unusable, this removes such backslashes
    #  and expands $HOME
    #
    #  Assigning the supplied variable name instead of printing output in a subshell,
    #  for better performance
    #
    fhp_varname="$1"
    fhp_path="$2"
    # log_it "fix_home_path($fhp_varname,$fhp_path)"

    validate_varname "$fhp_varname" "fix_home_path()"
    # [ -z "$fhp_varname" ] && error_msg "fix_home_path() param 1 empty!"

    # But of course tmux changed how they escpe options starting with ~ or $HOME...
    if tmux_vers_check 3.0; then
        case "$fhp_path" in
        \\~/*)
            fhp_path="${fhp_path#\\}"        # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\~}" # Expand ~ to $HOME
            # log_it " - found \\~ - changed into: $fhp_path"
            ;;
        \\\$HOME/*)
            fhp_path="${fhp_path#\\}"            # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\$HOME}" # Expand ~ to $HOME
            # log_it " - found \\\$HOME - changed into: $fhp_path"
            ;;
        *) ;;
        esac
    else
        case "$fhp_path" in
        \~/*)
            fhp_path="${fhp_path#\\}"        # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\~}" # Expand ~ to $HOME
            # log_it " - found \\~ - changed into: $fhp_path"
            ;;
        \$HOME/*)
            fhp_path="${fhp_path#\\}"            # Remove leading backslash
            fhp_path="${HOME}${fhp_path#\$HOME}" # Expand ~ to $HOME
            # log_it " - found \\\$HOME - changed into: $fhp_path"
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
    # log_it "><> fix_home_path() result:[$fhp_path]"
    eval "$fhp_varname=\"\$fhp_path\""
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
        # shellcheck disable=SC2034
        cfg_no_prefix=false
    fi

    if ! tmux_vers_check 3.0; then
        # if on next plugin_setup a menus able tmux is detected the relevant
        # additional settings will be cached
        if command -v whiptail >/dev/null; then
            cfg_alt_menu_handler=whiptail
            log_it "NOTICE: tmux below 3.0 - using: whiptail"
        elif command -v dialog >/dev/null; then
            cfg_alt_menu_handler=dialog
            log_it "NOTICE: tmux below 3.0 - using: dialog"
        else
            error_msg_safe "Neither whiptail or dialog found, plugin aborted"
        fi
        log_it "--- Activating cfg_use_whiptail due to tmux < 3.0"
        cfg_use_whiptail=true
    else
        cfg_use_whiptail=false
        # shellcheck disable=SC2034
        cfg_alt_menu_handler=""
    fi

    handle_env_variables # potential cfg_use_whiptail override

    if $cfg_use_whiptail; then
        # variables only used by whiptail
        # shellcheck disable=SC2034
        {
            wt_pasting="@tmp_menus_wt_paste_in_progress"
            cfg_display_cmds=false
            cfg_use_hint_overlays=false
            cfg_show_key_hints=false
            cfg_nav_next="$default_nav_next"
            cfg_nav_prev="$default_nav_prev"
            cfg_nav_home="$default_nav_home"
        }
    else
        tmux_get_option cfg_mnu_loc_x "@menus_location_x" "$default_location_x"
        tmux_get_option cfg_mnu_loc_y "@menus_location_y" "$default_location_y"
        tmux_get_option cfg_format_title "@menus_format_title" \
            "$default_format_title"

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
            # shellcheck disable=SC2154
            is_int "$cfg_display_cmds_cols" || {
                error_msg "@menus_display_cmds_cols is not int: $cfg_display_cmds_cols"
            }
        else
            # shellcheck disable=SC2034
            cfg_display_cmds=false
        fi
        if normalize_bool_param "@menus_use_hint_overlays" "$default_use_hint_overlays"; then
            cfg_use_hint_overlays=true
        else
            # shellcheck disable=SC2034
            cfg_use_hint_overlays=false
        fi
        if normalize_bool_param "@menus_show_key_hints" "$default_show_key_hints"; then
            cfg_show_key_hints=true
        else
            # shellcheck disable=SC2034
            cfg_show_key_hints=false
        fi
    fi

    # if ! $cfg_use_whiptail &&
    # else
    #     # shellcheck disable=SC2034
    #     cfg_display_cmds=false
    #     # No point reading tmux for this if it isn't going to be used anyhow
    #     cfg_display_cmds_cols="$default_display_cmds_cols"
    # fi

    tmux_get_option _tmux_conf "@menus_config_file" "$default_tmux_conf"
    # Handle the case of ~ or $HOME being wrapped in single quotes in tmux.conf
    # shellcheck disable=SC2154
    fix_home_path cfg_tmux_conf "$_tmux_conf"

    # shellcheck disable=SC2154
    [ "$log_file_forced" != 1 ] && {
        #  If a debug logfile has been set, the tmux setting will be ignored.
        # log_it "tmux will read cfg_log_file"
        tmux_get_option _log_file "@menus_log_file" "$default_log_file"
        # Handle the case of ~ or $HOME being wrapped in single quotes in tmux.conf
        fix_home_path cfg_log_file "$_log_file"
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
        # log_it "><> using notes"
        cfg_use_notes=true
    else
        # log_it "><> ignoring notes"
        # shellcheck disable=SC2034
        cfg_use_notes=false
    fi
}

use_whiptail_env() {
    # if this is moved to helpers_minimal, ensure to also
    # move the required defaults to that file
    # log_it "use_whiptail_env()"
    if $cfg_use_whiptail; then
        # shellcheck disable=SC2034
        {
            cfg_display_cmds=false
            cfg_show_key_hints=false
        }
    fi
}

tmux_error_handler() {
    # fake assigning a variable in order to use the same func
    tmux_error_handler_assign _dont_store_result_ "$@"
}

tmux_error_handler_assign() { # cache references
    #
    #  Detects any errors reported by tmux commands and gives notification
    #
    #
    #  Assigning the supplied variable name instead of printing output in a subshell,
    #  for better performance
    #
    varname="$1"
    shift
    the_cmd="$*"

    validate_varname "$varname" "tmux_error_handler_assign()"
    $teh_debug && {
        if [ "$varname" = "_dont_store_result_" ]; then
            log_it "tmux_error_handler($the_cmd)"
        else
            log_it "tmux_error_handler_assign($the_cmd) -> $varname"
        fi
    }
    if $cfg_use_cache; then
        d_errors="$d_cache"
    else
        # shellcheck disable=SC2154
        d_errors="$d_tmp"
    fi
    # ensure it exists
    [ ! -d "$d_errors" ] && mkdir -p "$d_errors"
    f_tmux_err="$d_errors"/tmux-err
    $teh_debug && {
        log_it "teh: $TMUX_BIN $the_cmd"
    }
    # shellcheck disable=SC2068  # intentional to keep params seeparate here
    value=$($TMUX_BIN "$@" 2>"$f_tmux_err") && safe_remove "$f_tmux_err" skip-path-check
    $teh_debug && log_it "teh: cmd done [$?] >>$value<<"
    [ -s "$f_tmux_err" ] && {
        #
        #  First save the error to a named file
        #
        _f_name="$(tr -cs '[:alnum:]._' '_' <"$f_tmux_err")"
        [ -z "$_f_name" ] && _f_name="tmux-error"
        f_error_log="$d_errors/error-$_f_name"

        [ -f "$f_error_log" ] && {
            _idx=1
            f_error_log="${f_error_log}-$_idx"
            while [ -f "$f_error_log" ]; do
                _idx=$((_idx + 1))
                f_error_log="${f_tmux_err}-$_idx"
                [ "$_idx" -gt 1000 ] && {
                    error_msg "Aborting runaway loop - _idx=$_idx"
                }
            done
        }
        (
            echo "\$TMUX_BIN $the_cmd"
            echo
            cat "$f_tmux_err"
        ) >"$f_error_log"

        if $teh_debug; then
            log_it "$(
                printf "tmux cmd failed:\n\n%s\n" "$(cat "$f_error_log")"
            )"
        else
            log_it "saved error to: $f_error_log"
            _err_frame_line="--------------------\n"
            error_msg "$(
                printf 'tmux cmd failed:\n\n%s%s\n%s\n%s: %s\n\nFull path: %s' \
                    "$_err_frame_line" \
                    "$(cat "$f_error_log")" \
                    "$_err_frame_line" \
                    "The error message has been saved in" \
                    "$(relative_path "$f_error_log")" \
                    "$f_error_log"
            )"
        fi
        return 1
    }

    $teh_debug && {
        if [ "$varname" = "_dont_store_result_" ]; then
            [ -n "$value" ] && {
                # since it's not an assignment, just output it
                echo "$value"
                log_it "  <--  tmux_error_handler() got: >>$value<<"
            }
        else
            log_it "  <--  tmux_error_handler_assign() got: >>$value<<"
        fi
    }
    teh_debug=false
    eval "$varname=\"\$value\""
    return 0
}

#===============================================================
#
#   Main
#
#===============================================================

#
# tmux_error_handler & tmux_error_handler_assign neve log normally
# if a specific call should be logged set this to true, it will be disabled again
# at the end of the call
#
teh_debug=false

# log_it "===  Completed: scripts/utils/tmux.sh  =="
