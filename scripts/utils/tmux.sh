#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Handling tmux env
#
# shellcheck disable=SC2034,SC2154

tmux_vers_check() { # cache references
    #
    #  This returns true if tvc_v_cmp <= tvc_v_ref
    #  If only one param is given it is compared vs version of running tmux
    #
    [ -z "$2" ] && [ -z "$tmux_vers" ] && {
        tvc_msg="tmux_vers_check() called with neither par2 or tmux_vers set"
        error_msg "$tvc_msg"
    }

    [ -f "$f_cache_known_tmux_vers" ] && [ -z "$cache_ok_tmux_versions" ] && {
        #
        # get known good/bad versions
        #
        # shellcheck source=/dev/null
        . "$f_cache_known_tmux_vers"
    }

    tvc_v_cmp="$1"
    i_tvc_cmp=0 # indicating unset
    tvc_v_ref="${2:-$tmux_vers}"
    i_tvc_ref=0 # indicating unset

    # log_it "tmux_vers_check($tvc_v_cmp, $tvc_v_ref)"

    $cfg_use_cache && {
        case "$cache_ok_tmux_versions $tvc_v_ref " in
        *"$tvc_v_cmp "*) return 0 ;;
        *) ;;
        esac
        case "$cache_bad_tmux_versions" in
        *"$tvc_v_cmp "*) return 1 ;;
        *) ;;
        esac

        i_tvc_cmp=$(get_digits_from_string "$tvc_v_cmp")
        i_tvc_ref=$(get_digits_from_string "$tvc_v_ref")

        if [ "$i_tvc_cmp" -le "$i_tvc_ref" ]; then
            [ "$tvc_v_ref" = "$tmux_vers" ] && cache_add_ok_vers "$tvc_v_cmp"
            return 0
        else
            [ "$tvc_v_ref" = "$tmux_vers" ] && cache_add_bad_vers "$tvc_v_cmp"
            return 1
        fi
    }

    [ "$i_tvc_cmp" -eq 0 ] && i_tvc_cmp=$(get_digits_from_string "$tvc_v_cmp")
    [ "$i_tvc_ref" -eq 0 ] && i_tvc_ref=$(get_digits_from_string "$tvc_v_ref")
    [ "$i_tvc_cmp" -le "$i_tvc_ref" ]
}

tmux_get_vers() {
    # skip release candidate suffix and similar
    $TMUX_BIN -V | cut -d ' ' -f 2 | cut -d- -f1
}

tmux_define_vers_vars() {
    #
    #  Public variables
    #   tmux_vers - currently running tmux version
    #   i_tmux_vers - integer part, used by tmux_vers_check()
    #
    tmux_vers="$(tmux_get_vers)"
    i_tmux_vers=$(get_digits_from_string "$tmux_vers")
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

    if tmux_vers_check 3.2; then
        default_location_x=C
        default_location_y=C
    else
        default_location_x=P
        default_location_y=P
    fi

    default_use_cache=Yes

    if [ -n "$TMUX_CONF" ]; then
        default_tmux_conf="$TMUX_CONF"
    elif [ -n "$XDG_CONFIG_HOME" ]; then
        default_tmux_conf="$XDG_CONFIG_HOME/tmux/tmux.conf"
    else
        default_tmux_conf="$HOME/.tmux.conf"
    fi

    default_log_file=""
}

tmux_get_option() {
    tgo_option="$1"
    tgo_default="$2"

    # log_it "tmux_get_option($tgo_option, $tgo_default)"

    [ -z "$tgo_option" ] && error_msg "tmux_get_option() param 1 empty!"

    [ "$TMUX" = "" ] && {
        # this is run standalone, just report the defaults
        echo "$tgo_default"
        return
    }

    if tgo_value="$($TMUX_BIN show-options -gv "$tgo_option" 2>/dev/null)"; then
        #
        #  I havent figured out if it is my asdf builds that have issues
        #  or something else, since I never heard of this issue before.
        #  On the other side, I dont think I have ever tried to assign ""
        #  to a user-option that has a non-empty default, so it might be
        #  an actual bug in tmux 3.0 - 3.2a
        #
        #  The problem is that with these versions tmux will will not
        #  report an error if show-options -gv is used on an undefined
        #  option starting with the char "@" as you should with
        #  user-options. For options starting with other chars,
        #  the normal error is displayed also with theese versions.
        #
        [ -z "$tgo_value" ] && ! tmux_is_option_defined "$tgo_option" && {
            #
            #  This is a workarround, checking if the variable is defined
            #  before assigning the default, preserving intentional
            #  "" assignments
            #
            tgo_value="$tgo_default"
        }
    else
        #  All other versions correctly fails on unassigned @options
        tgo_value="$tgo_default"
    fi
    echo "$tgo_value"

    unset tgo_option
    unset tgo_default
    unset tgo_value
}

tmux_get_plugin_options() { # cache references
    #
    #  Public variables
    #   cfg_  config variables, either read from tmux or the default
    #

    # log_it "tmux_get_plugin_options()"
    tmux_define_vers_vars
    tmux_get_defaults

    cfg_trigger_key=$(tmux_get_option "@menus_trigger" \
        "$default_trigger_key")
    normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
        cfg_no_prefix=true || cfg_no_prefix=false
    normalize_bool_param "@menus_use_cache" "$default_use_cache" &&
        cfg_use_cache=true || cfg_use_cache=false

    #
    #  Setup env depending on if cache is used or not
    #
    if $cfg_use_cache; then
        mkdir -p "$d_cache"
        [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && touch "$f_using_whiptail"
        rm -f "$f_cache_not_used_hint"
    else
        # indicate that cache should not be used
        touch "$f_cache_not_used_hint"
    fi

    cfg_mnu_loc_x="$(tmux_get_option "@menus_location_x" \
        "$default_location_x")"
    cfg_mnu_loc_y="$(tmux_get_option "@menus_location_y" \
        "$default_location_y")"
    cfg_tmux_conf="$(tmux_get_option "@menus_config_file" \
        "$default_tmux_conf")"
    _f="$(tmux_get_option "@menus_log_file" "$default_log_file")"
    [ -n "$_f" ] && {
        #
        #  If a debug logfile was set early in helpers.sh, and no log_file
        #  is defined in settings, the debug log file will continue to
        #  be used, otherwise, from here on the log file defined in tmux conf
        #  will be used from this point.
        #
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

        cfg_use_notes=true
    else
        cfg_use_notes=false
    fi
}

tmux_is_option_defined() {
    tmux_error_handler show-options -g | grep -q "^$1"
}

normalize_bool_param() {
    #
    #  Take a boolean style text param and convert it into an actual boolean
    #  that can be used in your code. Example of usage:
    #
    #  normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
    #      cfg_no_prefix=true || cfg_no_prefix=false
    #
    #  $cfg_no_prefix && echo "Dont use prefix"
    #
    nbp_param="$1"
    nbp_default="$2" # only used for tmux options
    nbp_variable_name=""

    # log_it "normalize_bool_param($nbp_param, $nbp_default)"
    [ "${nbp_param%"${nbp_param#?}"}" = "@" ] && {
        #
        #  If it starts with "@", assume it is a tmux option, thus
        #  read its value from the tmux environment.
        #  In this case $2 must be given as the default value!
        #
        [ -z "$nbp_default" ] && {
            error_msg "normalize_bool_param($nbp_param) - no default"
        }
        nbp_variable_name="$nbp_param"
        nbp_param="$(tmux_get_option "$nbp_param" "$nbp_default")"
    }

    nbp_param="$(lowercase_it "$nbp_param")"

    case "$nbp_param" in
    #
    #  Handle the unfortunate tradition in the tmux community to use
    #  1 to indicate selected / active.
    #  This means 1 is 0 and 0 is 1, how Orwellian...
    #
    1 | yes | true)
        #  Be a nice guy and accept some common positive notations
        unset nbp_param nbp_default nbp_variable_name
        return 0
        ;;

    0 | no | false)
        #  Be a nice guy and accept some common false notations
        unset nbp_param nbp_default nbp_variable_name
        return 1
        ;;

    *)
        if [ -n "$nbp_variable_name" ]; then
            prefix="$nbp_variable_name=$nbp_param"
        else
            prefix="$nbp_param"
        fi
        error_msg "$prefix - should be yes/true or no/false"
        ;;

    esac

    # Should never get here...
    error_msg "normalize_bool_param() - failed to evaluate $nbp_param"
}

tmux_escape_special_chars() {
    #
    #  Will iterate over each character, and populate tesc_esc_str
    #  with either the escaped version or the original char
    #
    tesc_str="$1"
    tesc_idx=0
    while true; do
        tesc_idx=$((tesc_idx + 1))
        char="$(extract_char "$tesc_str" "$tesc_idx")"
        [ -n "$char" ] || break
        [ "$char" = \\ ] && {
            # maintain \ prefixes
            tesc_idx=$((tesc_idx + 1))
            char="$char$(extract_char "$tesc_str" "$tesc_idx")"
        }
        case "$char" in
        \\)
            tesc_esc_str="${tesc_esc_str}\\\\"
            ;;
        \")
            tesc_esc_str="${tesc_esc_str}\\\""
            ;;
        \$)
            tesc_esc_str="${tesc_esc_str}\\$"
            ;;
        \#)
            tesc_esc_str="${tesc_esc_str}\\#"
            ;;
        *)
            tesc_esc_str="${tesc_esc_str}${char}"
            ;;
        esac

    done
    printf '%s\n' "$tesc_esc_str"
    unset tesc_str tesc_idx tesc_esc_str
}

tmux_error_handler() { # cache references
    #
    #  Detects any errors reported by tmux commands and gives notification
    #
    the_cmd="$*"

    # log_it "tmux_error_handler($the_cmd)"

    if $cfg_use_cache; then
        d_errors="$d_cache"
    else
        d_errors="$d_tmp"
    fi
    f_tmux_err="$d_errors"/tmux-err

    $TMUX_BIN "$@" 2>"$f_tmux_err" && rm -f "$f_tmux_err"

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
        log_it "saved error to: $f_error_log"
        (
            echo "\$TMUX_BIN $the_cmd"
            echo
            cat "$f_tmux_err"
        ) >"$f_error_log"

        error_msg "$(
            printf "tmux cmd failed:\n\n%s\n
            \nThe full error message has been saved in:\n%s
            \nFull path:\n%s\n" \
                "$(cat "$f_error_log")" \
                "$(relative_path "$f_error_log")" \
                "$f_error_log"
        )"
        unset f_error_log
    }
    unset the_cmd
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
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

if [ -n "$TMUX" ]; then
    tmux_pid="$(echo "$TMUX" | cut -d',' -f2)"
else
    # was run outside tmux
    tmux_pid="-1"
fi
