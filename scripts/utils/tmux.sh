#!/bin/sh
# Always sourced file - Fake bang path to help editors
# shellcheck disable=SC2034,SC2154
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

tmux_get_defaults() {
    #
    #  Defaults for plugin params
    #
    #  Public variables
    #   default_  defaults for tmux config options
    #

    # log_it "tmux_get_defaults()"

    default_trigger_key=\\
    default_no_prefix=No

    default_display_cmds_cols=75

    default_simple_style_selected=default
    default_simple_style=default
    default_simple_style_border=default
    default_format_title="'#[align=centre]  #{@menu_name} '"

    default_nav_next="-->"
    default_nav_prev="<--"
    default_nav_home="<=="

    if tmux_vers_check 3.2; then
        default_location_x=C
        default_location_y=C
    else
        default_location_x=P
        default_location_y=P
    fi

    default_use_cache=Yes

    default_use_hint_overlays=Yes
    default_show_key_hints=No

    if [ -n "$TMUX_CONF" ]; then
        default_tmux_conf="$TMUX_CONF"
    elif [ -n "$XDG_CONFIG_HOME" ]; then
        default_tmux_conf="$XDG_CONFIG_HOME/tmux/tmux.conf"
    else
        default_tmux_conf="$HOME/.tmux.conf"
    fi

    default_log_file=""
}

cache_save_options_defined_in_tmux() {
    [ -f "$f_cached_tmux_options" ] && return
    # log_it "cache_save_options_defined_in_tmux()"
    $TMUX_BIN show-options -g | grep ^@menus_ >"$f_cached_tmux_options"
    $TMUX_BIN show-options -g | grep @use_bind_key_notes_in_plugins \
        >>"$f_cached_tmux_options"
    # log_it "  <-- cache_save_options_defined_in_tmux() - wrote: $f_cached_tmux_options"
}

tmux_get_option() {
    tgo_varname="$1" # The variable name to store the result in
    tgo_option="$2"
    tgo_default="$3"
    tgo_no_cache="$4" # if non-empty, prevent cache from being used - for odd variables

    # log_it "tmux_get_option($tgo_varname, $tgo_option, $tgo_default, $tgo_no_cache)"

    [ -z "$tgo_varname" ] && error_msg "tmux_get_option() param 1 empty!"
    [ -z "$tgo_option" ] && error_msg "tmux_get_option() param 2 empty!"
    if [ -z "$tgo_no_cache" ] && $cfg_use_cache && [ -d "$d_cache" ]; then
        tgo_use_cache=true
    else
        tgo_use_cache=false
    fi

    if [ -z "$TMUX" ]; then
        # this is run standalone, just report the defaults
        log_it "tmux_get_option() - no \$TMUX - using default"
        echo "$tgo_default"
        return
    elif ! tmux_vers_check 1.8; then
        # before 1.8 no support for user params
        log_it "tmux_get_option() - tmux < 1.8 - using default"
        echo "$tgo_default"
        return
    fi

    if $tgo_use_cache; then
        cache_save_options_defined_in_tmux

        tgo_value="$(awk -v option="$tgo_option" \
            '$1 == option { gsub(/^"|"$/, "", $2); print $2 }' "$f_cached_tmux_options")"

        if [ -f "$f_cached_tmux_options" ] && [ -z "$tgo_value" ] &&
            ! grep -q "$tgo_option" "$f_cached_tmux_options" 2>/dev/null; then

            tgo_was_found=1 # option not found
        else
            tgo_was_found=0
        fi
    else
        # log_it "tmux_get_option($tgo_option) - not using cache"

        # tmux_error_handler is not used, since errors are handled in place
        tgo_value="$($TMUX_BIN show-options -gv "$tgo_option" 2>/dev/null)"
        tgo_was_found="$?"
        [ "$tgo_was_found" = 0 ] && [ -z "$tgo_value" ] && {
            #
            # tmux 3.0 - 3.2a exits 0 even if variable was not found,
            # so the value being set to "" vs not being defined can't be detected
            # via exit code for those versions. Thus this extra check, if the option
            # isn't defined use the default. This allows a variable to be set to ""
            #
            $TMUX_BIN show-options -g | grep -q "$tgo_option" || {
                # log_it " value unset, using default
                tgo_value="$tgo_default"
            }
        }
    fi

    if [ "$tgo_was_found" != 0 ]; then
        #
        #  Since tmux doesn't differentiate between the variable being absent
        #  and being assigned to "", use not found to select the default
        #
        tgo_value="$tgo_default"
    fi
    # log_it "tmux_get_option() - using [$tgo_value]"
    eval "$tgo_varname=\$tgo_value"
}

tmux_get_plugin_options() { # cache references
    #
    #  Public variables
    #   cfg_  config variables, either read from tmux or the default
    #
    # log_it "tmux_get_plugin_options()"
    $plugin_options_have_been_read && {
        error_msg "tmux_get_plugin_options() has already been called"
    }
    tmux_get_defaults
    if normalize_bool_param "@menus_use_cache" "$default_use_cache"; then
        cfg_use_cache=true
        safe_remove "$f_no_cache_hint" skip-path-check
        # do it as early as possible, so that further tmux options are cached
        cache_create_folder "@menus_use_cache is true"
    else
        cfg_use_cache=false
        # log_it "><> touching: $f_no_cache_hint"
        touch "$f_no_cache_hint"
    fi

    select_menu_handler

    # [ "$bn_current_script" = "plugin_init.sh" ] && {
    #     # Since this is only needed by plugin_init.sh, save some time
    #     # when @menus_use_cache is No and skip this one for menu items
    tmux_get_option cfg_trigger_key "@menus_trigger" "$default_trigger_key"
    # }

    if normalize_bool_param "@menus_without_prefix" "$default_no_prefix"; then
        cfg_no_prefix=true
    else
        cfg_no_prefix=false
    fi
    if normalize_bool_param "@menus_use_hint_overlays" "$default_use_hint_overlays"; then
        cfg_use_hint_overlays=true
    else
        cfg_use_hint_overlays=false
    fi
    if normalize_bool_param "@menus_show_key_hints" "$default_show_key_hints"; then
        cfg_show_key_hints=true
    else
        cfg_show_key_hints=false
    fi

    if $cfg_use_whiptail; then
        _whiptail_ignore_msg="not used with whiptail"

        cfg_simple_style_selected="$_whiptail_ignore_msg"
        cfg_simple_style="$_whiptail_ignore_msg"
        cfg_simple_style_border="$_whiptail_ignore_msg"
        cfg_format_title="$_whiptail_ignore_msg"
        cfg_mnu_loc_x="$_whiptail_ignore_msg"
        cfg_mnu_loc_y="$_whiptail_ignore_msg"

        # Whiptail skips any styling
        cfg_nav_next="$default_nav_next"
        cfg_nav_prev="$default_nav_prev"
        cfg_nav_home="$default_nav_home"
    else
        if normalize_bool_param "@menus_display_commands" "$default_show_key_hints"; then
            cfg_display_cmds=true
            tmux_get_option cfg_display_cmds_cols "@menus_display_cmds_cols" \
                "$default_display_cmds_cols"
            is_int "$cfg_display_cmds_cols" || {
                error_msg "@menus_display_cmds_cols is not int: $cfg_display_cmds_cols"
            }
        else
            cfg_display_cmds=false
            # No point reading tmux for this if it isn't going to be used anyhow
            cfg_display_cmds_cols="$default_display_cmds_cols"
        fi

        tmux_get_option cfg_simple_style_selected "@menus_simple_style_selected" \
            "$default_simple_style_selected"

        tmux_get_option cfg_simple_style "@menus_simple_style" \
            "$default_simple_style"
        tmux_get_option cfg_simple_style_border "@menus_simple_style_border" \
            "$default_simple_style_border"
        tmux_get_option cfg_format_title "@menus_format_title" \
            "$default_format_title"

        tmux_get_option cfg_mnu_loc_x "@menus_location_x" "$default_location_x"
        tmux_get_option cfg_mnu_loc_y "@menus_location_y" "$default_location_y"
        tmux_get_option cfg_nav_next "@menus_nav_next" "$default_nav_next"
        tmux_get_option cfg_nav_prev "@menus_nav_prev" "$default_nav_prev"
        tmux_get_option cfg_nav_home "@menus_nav_home" "$default_nav_home"
    fi

    tmux_get_option cfg_tmux_conf "@menus_config_file" "$default_tmux_conf"
    [ "$log_file_forced" != 1 ] && {
        #  If a debug logfile has been set, the tmux setting will be ignored.
        # log_it "tmux will read cfg_log_file"
        tmux_get_option cfg_log_file "@menus_log_file" "$default_log_file"
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
        cfg_use_notes=false
    fi
    plugin_options_have_been_read=true
}

tmux_error_handler() {
    # fake assigning a variable in order to use the same func
    tmux_error_handler_assign _dont_store_result_ "$@"
}

tmux_error_handler_assign() { # cache references
    #
    #  Detects any errors reported by tmux commands and gives notification
    #
    varname="$1"
    shift
    the_cmd="$*"
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
            error_msg "$(
                printf "tmux cmd failed:\n\n%s\n
                \nThe full error message has been saved in:\n%s
                \nFull path:\n%s\n" \
                    "$(cat "$f_error_log")" \
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
    eval "$varname=\$value"
    return 0
}

#===============================================================
#
#   Main
#
#===============================================================

#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf, to pick the version matching the server running.
#  This is needed when checking backward compatibility with various versions.
#  If not found, it is set to whatever is in the path, so should have no negative
#  impact. In all calls to tmux I use TMUX_BIN instead in the rest of this
#  plugin.
#

if [ -n "$TMUX" ]; then
    tmux_pid="$(echo "$TMUX" | cut -d',' -f2)"
else
    # was run outside tmux
    tmux_pid="-1"
fi

teh_debug=false

# log_it "===  Completed: scripts/utils/tmux.sh  =="
