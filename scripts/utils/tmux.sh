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
# shellcheck disable=SC2034

tmux_get_vers() {
    $TMUX_BIN -V | cut -d ' ' -f 2
}

tmux_set_vers_vars() {
    #
    #  Public variables
    #   tmux_vers - currently running tmux version
    #   tmux_i_ref - integer part, used by tmux_vers_check()
    #
    tmux_vers="$(tmux_get_vers)"
    tmux_i_ref=$(get_digits_from_string "$tmux_vers")
}

tmux_is_option_defined() {
    tmux_error_handler show-options -g | grep -q "^$1"
}

tmux_get_option() {
    tgo_option="$1"
    tgo_default="$2"

    # log_it "tmux_get_option($tgo_option, $tgo_default)"

    [ -z "$tgo_option" ] && error_msg "tmux_get_option() param 1 empty!"

    # shellcheck disable=SC2154
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

tmux_error_handler() { # cache references
    #
    #  Detects any errors reported by tmux commands and gives notification
    #
    teh_cmd="$*"

    # log_it "tmux_error_handler($teh_cmd)"

    # shellcheck disable=SC2154
    if $cfg_use_cache; then
        d_errors="$d_cache"
    else
        d_errors="$d_tmp"
    fi
    f_tmux_err="$d_errors"/tmux-err

    $TMUX_BIN "$@" 2>"$f_tmux_err" && rm -f "$f_tmux_err"

    # shellcheck disable=SC2154
    [ -s "$f_tmux_err" ] && {
        #
        #  First save the error to a named file
        #
        base_fname="$(tr -cs '[:alnum:]._' '_' <"$f_tmux_err")"
        [ -z "$base_fname" ] && base_fname="tmux-error"
        f_error_log="$d_errors/error-$base_fname"

        [ -f "$f_error_log" ] && {
            teh_i=1
            f_error_log="${f_error_log}-$teh_i"
            while [ -f "$f_error_log" ]; do
                teh_i=$((teh_i + 1))
                f_error_log="${f_tmux_err}-$teh_i"
                [ "$teh_i" -gt 1000 ] && {
                    error_msg "Aborting runaway loop - teh_i=$teh_i"
                }
            done
            unset teh_i
        }
        log_it "saved error to: $f_error_log"
        (
            echo "\$TMUX_BIN $teh_cmd"
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
    }
    unset f_tmux_err
    unset teh_cmd
    return 0
}

tmux_vers_check() { # cache references
    #
    #  This returns true if v_comp <= v_ref
    #  If only one param is given it is compared vs version of running tmux
    #

    [ -z "$2" ] && [ -z "$tmux_vers" ] && {
        tvc_msg="tmux_vers_check() called with neither \$2 or \$tmux_vers set"
        error_msg "$tvc_msg"
    }
    v_comp="$1"
    v_ref="${2:-$tmux_vers}"

    i_comp=$(get_digits_from_string "$v_comp")

    if $cfg_use_cache; then
        if [ "$v_ref" = "$tmux_vers" ]; then
            #
            # two  methods to check for good/bad tmux vers, need
            #  to figure out which is better in this case
            #
            if false; then
                if echo "$cache_ok_tmux_versions" | grep -q "\b$v_comp\b"; then
                    return 0
                elif echo "$cache_bad_tmux_versions" | grep -q "\b$v_comp\b"; then
                    return 1
                fi
            else
                case " $cache_ok_tmux_versions $tmux_vers" in
                *" $v_comp "*) return 0 ;;
                *) ;;
                esac
                case " $cache_bad_tmux_versions " in
                *" $v_comp "*) return 1 ;;
                *) ;;
                esac
            fi

            i_ref="$tmux_i_ref"

            # shellcheck disable=SC2154
            [ -f "$f_cache_tmux_known_vers" ] && {
                #
                #  Dont try to save unknown versions
                #  during initial startup, before the initial file has been
                #  created, such changes would be overwritten anyhow
                #
                if [ "$i_comp" -le "$i_ref" ]; then
                    cache_ok_tmux_versions="$cache_ok_tmux_versions $v_comp"
                    log_it "Added ok tmux vers: $v_comp"
                else
                    cache_bad_tmux_versions="$v_comp $cache_bad_tmux_versions"
                    log_it "Added bad tmux vers: $v_comp"
                fi
                #
                # For performance reasons, dont save changes right away,
                # leave that for dialog_handling:handle_menu()
                # to do once all checks for the menu has completed
                #
                # shellcheck disable=SC2034
                b_cache_delayed_param_write=true
            }
        else
            i_ref=$(get_digits_from_string "$v_ref")
        fi
    else
        # not using cache
        i_ref=$(get_digits_from_string "$v_ref")
    fi

    unset v_comp v_ref
    [ "$i_comp" -le "$i_ref" ]
}

tmux_get_plugin_options() { # cache references
    #
    #  Public variables
    #   cfg_  config variables, either read from tmux or the default
    #

    # log_it "tmux_get_plugin_options()"
    tmux_set_vers_vars
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
        # shellcheck disable=SC2154
        [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && touch "$f_using_whiptail"
        # shellcheck disable=SC2154
        rm -f "$f_cache_not_used_hint"
    else
        # indicate that cache should not be used
        # shellcheck disable=SC2154
        [ -f "$f_cache_not_used_hint" ] || touch "$f_cache_not_used_hint"
    fi

    cfg_mnu_loc_x="$(tmux_get_option "@menus_location_x" \
        "$default_location_x")"
    cfg_mnu_loc_y="$(tmux_get_option "@menus_location_y" \
        "$default_location_y")"
    cfg_tmux_conf="$(tmux_get_option "@menus_config_file" \
        "$default_tmux_conf")"

    if [ -z "$cfg_log_file" ]; then
        #
        #  would only be set in debug mode, in that case ignore
        #  tmux setting and defuault
        #
        cfg_log_file="$(tmux_get_option "@menus_log_file" \
            "$default_log_file")"
    fi

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

tmux_pid="$(echo "$TMUX" | cut -d',' -f2)"
