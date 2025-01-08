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

    [ -z "$cached_ok_tmux_versions" ] && [ -f "$f_cache_known_tmux_vers" ] && {
        #
        # get known good/bad versions if this hasn't been sourced yet
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
        case "$cached_ok_tmux_versions $tvc_v_ref " in
        *"$tvc_v_cmp "*) return 0 ;;
        *) ;;
        esac
        case "$cached_bad_tmux_versions" in
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

tmux_set_running_vers() {
    # Filter out devel prefix and release candidate suffix
    tmux_vers="$(tmux_error_handler -V | cut -d ' ' -f 2)"
    case "$tmux_vers" in
    next-*)
        # Remove "next-" prefix
        tmux_vers="${tmux_vers#next-}"
        ;;
    *-rc*)
        # Remove "-rcX" suffix
        tmux_vers="${tmux_vers%-rc*}"
        ;;
    *) ;;
    esac
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

    if [ "$TMUX" = "" ]; then
        # this is run standalone, just report the defaults
        echo "$tgo_default"
        return
    elif ! tmux_vers_check 1.8; then
        # before 1.8 no support for user params
        echo "$tgo_default"
        return
    fi

    # don't use tmux_error_handler here
    if tgo_value="$($TMUX_BIN show-options -gv "$tgo_option" 2>/dev/null)"; then
        #
        #  I haven't figured out if it is my asdf builds that have issues
        #  or something else, since I never heard of this issue before.
        #  On the other side, I don't think I have ever tried to assign ""
        #  to a user-option that has a non-empty default, so it might be
        #  an actual bug in tmux 3.0 - 3.2a
        #
        #  The problem is that with these versions tmux will will not
        #  report an error if show-options -gv is used on an undefined
        #  option starting with the char "@" as you should with
        #  user-options. For options starting with other chars,
        #  the normal error is displayed also with these versions.
        #
        [ -z "$tgo_value" ] && ! tmux_is_option_defined "$tgo_option" && {
            #
            #  This is a workaround, checking if the variable is defined
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

    tmux_get_defaults
    cfg_trigger_key="$(tmux_escape_special_chars "$(tmux_get_option "@menus_trigger" \
        "$default_trigger_key")")"
    normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
        cfg_no_prefix=true || cfg_no_prefix=false
    normalize_bool_param "@menus_use_cache" "$default_use_cache" &&
        cfg_use_cache=true || cfg_use_cache=false

    #
    #  Setup env depending on if cache is used or not
    #
    if $cfg_use_cache; then
        rm -f "$f_cache_not_used_hint"
    else
        # indicate that cache should not be used
        log_it "touching: $f_cache_not_used_hint"
        touch "$f_cache_not_used_hint"
    fi

    if $cfg_use_whiptail; then
        _whiptail_ignore_msg="not used with whiptail"

        cfg_simple_style_selected="$_whiptail_ignore_msg"
        cfg_simple_style="$_whiptail_ignore_msg"
        cfg_simple_style_border="$_whiptail_ignore_msg"
        cfg_format_title="$_whiptail_ignore_msg"
        cfg_mnu_loc_x="$_whiptail_ignore_msg"
        cfg_mnu_loc_y="$_whiptail_ignore_msg"
        unset _whiptail_ignore_msg

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

        cfg_nav_next="$(tmux_get_option "@menus_nav_next" \
            "$default_nav_next")"
        cfg_nav_prev="$(tmux_get_option "@menus_nav_prev" \
            "$default_nav_prev")"
        cfg_nav_home="$(tmux_get_option "@menus_nav_home" \
            "$default_nav_home")"
        cfg_mnu_loc_x="$(tmux_get_option "@menus_location_x" \
            "$default_location_x")"
        cfg_mnu_loc_y="$(tmux_get_option "@menus_location_y" \
            "$default_location_y")"
    fi

    cfg_tmux_conf="$(tmux_get_option "@menus_config_file" \
        "$default_tmux_conf")"
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
        cfg_use_notes=true
    else
        cfg_use_notes=false
    fi
    # log_it "  tmux_get_plugin_options() - done"
}

tmux_is_option_defined() {
    tmux_vers_check 1.8 && tmux_error_handler show-options -g | grep -q "^$1"
}

tmux_escape_special_chars() {
    #
    #  Will iterate over each character, and populate tesc_esc_str
    #  with either the escaped version or the original char
    #
    # log_it "tmux_escape_special_chars()"

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
        \`)
            tesc_esc_str="${tesc_esc_str}\\\`"
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

    # log_it "tmux_error_handler($1 $2 $3)"

    if $cfg_use_cache; then
        d_errors="$d_cache"
    else
        d_errors="$d_tmp"
    fi
    # ensure it exists
    [ ! -d "$d_errors" ] && mkdir -p "$d_errors"
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

tmux_select_menu_handler() {
    # support old env variable, cam be deleted eventually 241220
    [ -n "$FORCE_WHIPTAIL_MENUS" ] && TMUX_MENU_HANDLER="$FORCE_WHIPTAIL_MENUS"

    #
    # If an older version is used, or TMUX_MENU_HANDLER is 1/2
    # set cfg_use_whiptail true
    #
    if ! tmux_vers_check 3.0; then
        if command -v whiptail >/dev/null; then
            cfg_alt_menu_handler=whiptail
            log_it "tmux below 3.0 - using: whiptail"
        elif command -v dialog >/dev/null; then
            cfg_alt_menu_handler=dialog
            log_it "tmux below 3.0 - using: dialog"
        else
            error_msg "Neither whiptail or dialog found, plugin aborted"
        fi
        cfg_use_whiptail=true
    elif [ "$TMUX_MENU_HANDLER" = 1 ]; then
        _cmd=whiptail
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "$_cmd is selected due to TMUX_MENU_HANDLER=1"
        unset _cmd
    elif [ "$TMUX_MENU_HANDLER" = 2 ]; then
        _cmd=dialog
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "$_cmd is selected due to TMUX_MENU_HANDLER=2"
        unset _cmd
    else
        cfg_use_whiptail=false
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

if [ -n "$TMUX" ]; then
    tmux_pid="$(echo "$TMUX" | cut -d',' -f2)"
else
    # was run outside tmux
    tmux_pid="-1"
fi

cfg_alt_menu_handler=""

#
#  Define env needed for this
#
tmux_set_running_vers
i_tmux_vers=$(get_digits_from_string "$tmux_vers")

tmux_select_menu_handler
