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
# shellcheck disable=SC2034,SC2154

tmux_vers_check_do_compare() {
    # Called fomh helpers.sh:tmux_vers_check if checked version was not cached
    _v_comp="$1"
    # log_it "tmux_vers_check_do_compare($_v_comp)"

    # Compare numeric parts first for quick decisions.
    _i_comp="$(tpt_digits_from_string "$_v_comp")"
    [ "$_i_comp" -lt "$tpt_current_vers_i" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    [ "$_i_comp" -gt "$tpt_current_vers_i" ] && {
        cache_add_bad_vers "$_v_comp"
        return 1
    }

    # Compare suffixes only if numeric parts are equal.
    _suf="$(tpt_tmux_vers_suffix "$_v_comp")"
    # - If no suffix is required or suffix matches, return success
    [ -z "$_suf" ] || [ "$_suf" = "$tpt_current_vers_suffix" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    # If the desired version has a suffix but the running version doesn't, fail
    [ -n "$_suf" ] && [ -z "$tpt_current_vers_suffix" ] && {
        cache_add_bad_vers "$_v_comp"
        return 1
    }
    # Perform lexicographical comparison of suffixes only if necessary
    [ "$(printf '%s\n%s\n' "$_suf" "$tpt_current_vers_suffix" |
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

    log_it "tmux_get_defaults()"

    default_trigger_key=\\
    default_no_prefix=No

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
    # log_it "><>   tmux_get_defaults() - done"
}

cache_tmux_options() {
    [ -f "$f_cached_tmux_options" ] && return
    # log_it "cache_tmux_options()"
    profiling_display "[tmux] cache_tmux_options()"
    tmux_error_handler show-options -g | grep ^@menus_ >"$f_cached_tmux_options"
    profiling_display "[tmux] cache_tmux_options() - done"
}

tmux_get_option() {
    tgo_option="$1"
    tgo_default="$2"

    # log_it "tmux_get_option($tgo_option, $tgo_default)"

    [ -z "$tgo_option" ] && error_msg "tmux_get_option() param 1 empty!"

    if [ "$TMUX" = "" ]; then
        # this is run standalone, just report the defaults
        echo "$tgo_default"
        return
    elif ! tmux_vers_check 1.8; then
        # before 1.8 no support for user params
        echo "$tgo_default"
        return
    fi
    if $cfg_use_cache && [ -d "$d_cache" ]; then
        cache_tmux_options
        # profiling_display "[tmux] cache_tmux_options done"

        tgo_value="$(awk -v option="$tgo_option" \
            '$1 == option { gsub(/^"|"$/, "", $2); print $2 }' "$f_cached_tmux_options")"
        # profiling_display "[tmux] tgo_value defined"
        # tgo_value="$(grep "$tgo_option" "$f_cached_tmux_options" 2>/dev/null |
        #     cut -d' ' -f2)"

        if [ -z "$tgo_value" ] &&
            ! grep -q "$tgo_option" "$f_cached_tmux_options" 2>/dev/null; then

            tgo_was_found=1 # option not found
        else
            tgo_was_found=0
        fi
        # profiling_display "[tmux] missing value checked"
    else
        tgo_value="$($TMUX_BIN show-options -gv "$tgo_option" 2>/dev/null)"
        tgo_was_found="$?"
        # profiling_display "[tmux] show-options used"
    fi
    if [ "$tgo_was_found" != 0 ]; then
        #
        #  Since tmux doesn't differentiate between the variable being absent
        #  and being assigned to "", use not found to select the default
        #
        tgo_value="$tgo_default"
    fi
    echo "$tgo_value"
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
    profiling_display "[tmux] tmux_get_plugin_options()"
    tmux_get_defaults
    profiling_display "[tmux] tmux_get_defaults done"

    if normalize_bool_param "@menus_use_cache" "$default_use_cache"; then  # TODO: Profile
        cfg_use_cache=true
        log_it "><> removing: $f_no_cache_hint"
        rm -f "$f_no_cache_hint"
        # do it as early as possible, so that further tmux options are cached
        cache_create_folder
    else
        cfg_use_cache=false
        log_it "><> touching: $f_no_cache_hint"
        touch "$f_no_cache_hint"
    fi
    profiling_display "[tmux] normalize_bool_param done"

    cfg_trigger_key="$(tmux_get_option "@menus_trigger" "$default_trigger_key")"
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

    profiling_display "[tmux] whiptail part starts"

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
        cfg_simple_style_selected="$(tmux_get_option "@menus_simple_style_selected" \
            "$default_simple_style_selected")"
        cfg_simple_style="$(tmux_get_option "@menus_simple_style" \
            "$default_simple_style")"
        cfg_simple_style_border="$(tmux_get_option "@menus_simple_style_border" \
            "$default_simple_style_border")"
        cfg_format_title="$(tmux_get_option "@menus_format_title" \
            "$default_format_title")"

        cfg_mnu_loc_x="$(tmux_get_option "@menus_location_x" "$default_location_x")"
        cfg_mnu_loc_y="$(tmux_get_option "@menus_location_y" "$default_location_y")"
        cfg_nav_next="$(tmux_get_option "@menus_nav_next" "$default_nav_next")"
        cfg_nav_prev="$(tmux_get_option "@menus_nav_prev" "$default_nav_prev")"
        cfg_nav_home="$(tmux_get_option "@menus_nav_home" "$default_nav_home")"
    fi
    profiling_display "[tmux] whiptail part done"

    cfg_tmux_conf="$(tmux_get_option "@menus_config_file" "$default_tmux_conf")"
    _f="$(tmux_get_option "@menus_log_file" "$default_log_file")"
    [ -z "$cfg_log_file" ] && [ -n "$_f" ] && {
        #  If a debug logfile has been set, the tmux setting will be ignored.
        cfg_log_file="$_f"
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
    profiling_display "[tmux] tmux_get_plugin_options() - done"
    # log_it "  tmux_get_plugin_options() - done"
}

tmux_error_handler() { # cache references
    #
    #  Detects any errors reported by tmux commands and gives notification
    #
    the_cmd="$*"
    # $teh_debug && log_it "><> tmux_error_handler($the_cmd)"
    # log_it "><> tmux_error_handler($the_cmd)"

    if $cfg_use_cache; then
        d_errors="$d_cache"
    else
        d_errors="$d_tmp"
    fi
    # ensure it exists
    [ ! -d "$d_errors" ] && mkdir -p "$d_errors"
    f_tmux_err="$d_errors"/tmux-err
    $teh_debug && log_it "><>teh $TMUX_BIN $*"
    $TMUX_BIN "$@" 2>"$f_tmux_err" && rm -f "$f_tmux_err"
    $teh_debug && log_it "><>teh cmd done [$?]"
    [ -s "$f_tmux_err" ] && {
        #
        #  First save the error to a named file
        #
        base_fname="$(tr -cs '[:alnum:]._' '_' <"$f_tmux_err")"
        [ -z "$base_fname" ] && base_fname="tmux-error"
        f_error_log="$d_errors/error-$base_fname"
        unset base_fname

        [ -f "$f_error_log" ] && {
            _i=1
            f_error_log="${f_error_log}-$_i"
            while [ -f "$f_error_log" ]; do
                _i=$((_i + 1))
                f_error_log="${f_tmux_err}-$_i"
                [ "$_i" -gt 1000 ] && {
                    error_msg "Aborting runaway loop - _i=$_i"
                }
            done
            unset _i
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
        unset f_error_log
        return 1
    }
    unset the_cmd
    teh_debug=false
    return 0
}

#===============================================================
#
#   Main
#
#===============================================================

# profiling_display "[tmux] main"

#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf, to pick the version matching the server running.
#  This is needed when checking backward compatibility with various versions.
#  If not found, it is set to whatever is in the path, so should have no negative
#  impact. In all calls to tmux I use TMUX_BIN instead in the rest of this
#  plugin.
#

if [ -n "$TMUX" ]; then
    # profiling_display "[tmux] will set tmux_pid"
    tmux_pid="$(echo "$TMUX" | cut -d',' -f2)"
    # profiling_display "[tmux] set tmux_pid"
else
    # was run outside tmux
    tmux_pid="-1"
fi

teh_debug=false

# log_it "scripts/utils/tmux.sh - completed"
