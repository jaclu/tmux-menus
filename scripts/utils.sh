#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
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

log_it() {
    [ -z "$cfg_log_file" ] && return #  early abort if no logging

    $log_interactive_to_stderr && [ -t 0 ] && {
        printf "log: %s\n" "$@" >/dev/stderr
        return
    }

    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$@" >>"$cfg_log_file"
}

error_msg() {
    #
    #  Display $1 as an error message in log and as a tmux display-message
    #  unless do_display_message is false
    #
    #  exit_code defaults to 0, which might seem odd for an error exit,
    #  but in combination with display-message it makes sense.
    #  If the script exits with something else than 0, the current pane
    #  will be temporary replaced by an error message mentioning the exit
    #  code. Wich is both redundant and much less informative than the
    #  display-message that is also printed.
    #  If display-message is not desired it would make sense to use a more
    #  normal positive exit_code to indicate error, making the 2 & 3
    #  params be something like: 1 false
    #
    #  If exit_code is set to -1, process is not exited
    #
    msg="ERROR: $1"
    exit_code="${2:-0}"
    do_display_message=${3:-true}

    if $log_interactive_to_stderr && [ -t 0 ]; then
        echo "$msg" >/dev/stderr
    else
        log_it
        log_it "$msg"
        log_it

        #  display-message filters out \n
        msg="$(echo "$msg" | tr '\n' ' ')"

        $do_display_message && display_message_hold "$plugin_name $msg"
    fi

    [ "$exit_code" -gt -1 ] && exit "$exit_code"

    unset msg
    unset exit_code
    unset do_display_message
}

display_message_hold() {
    #
    #  Display a message and hold until key-press
    #  Can't use tmux_error_handler in this func, since that could
    #  trigger recursion
    #
    msg="$1"

    if tmux_vers_compare 3.2; then
        # message will remain until key-press
        $TMUX_BIN display-message -d 0 "$msg"
    else
        # Manually make the error msg stay on screen a long time
        org_display_time="$($TMUX_BIN show-option -gv display-time)"
        $TMUX_BIN set -g display-time 120000 >/dev/null
        $TMUX_BIN display-message "$msg"

        posix_get_char >/dev/null # wait for keypress
        $TMUX_BIN set -g display-time "$org_display_time" >/dev/null
        unset org_display_time
    fi
}

#---------------------------------------------------------------
#
#   Handling of specific data types
#
#---------------------------------------------------------------

posix_get_char() {
    #
    #  Configure terminal to read a single character without echoing,
    #  restoring the terminal and returning the char
    #
    old_stty_cfg=$(stty -g)
    stty raw -echo
    dd bs=1 count=1 2>/dev/null
    stty "$old_stty_cfg"

    unset old_stty_cfg
}

extract_char() {
    str="$1"
    pos="$2"
    printf '%s\n' "$str" | cut -c "$pos"
    unset str
    unset pos
}

lowercase_it() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

get_digits_from_string() {
    # this is used to get "clean" integer version number. Examples:
    # `tmux 1.9` => `19`
    # `1.9a`     => `19`

    s="$1"
    i="$(echo "$s" | tr -dC '[:digit:]')"
    # log_it "get_digits_from_string($s) -> [$i]"
    echo "$i"
    unset s i
}

#---------------------------------------------------------------
#
#   tmux env handling
#
#---------------------------------------------------------------

tmux_error_handler() {
    #
    #  Detects any errors reported by tmux commands and gives notification
    #
    cmd="$*"
    # log_it "tmux_error_handler($cmd)"

    # only needed during debugging
    # if echo "$cmd" | grep -q "tmux_error_handler"; then
    #     error_msg "Recursive call to tmux_error_handler()"
    # fi

    if $cfg_use_cache; then
        mkdir -p "$d_cache"
        f_tmux_err="$d_cache"/tmux-err

        $TMUX_BIN "$@" 2>"$f_tmux_err"

        [ -s "$f_tmux_err" ] && {
            #
            #  First save the error to a n
            idx=1
            _f="${f_tmux_err}-$idx"
            while [ -f "$_f" ]; do
                idx=$((idx + 1))
                _f="${f_tmux_err}-$idx"
                [ "$idx" -gt 1000 ] && {
                    error_msg "Aborting runaway loop - idx=$idx"
                }
            done
            log_it "saved error to: [$_f]"
            mv "$f_tmux_err" "$_f"
            error_msg "$(cat "$_f")"
        }
    else
        $TMUX_BIN "$@" || {
            error_msg "tmux gave error: $?"
        }
    fi
    return 0
}

# save_verified_tmux_vers() {
#     svtv_vers="$1"
#     svtv_is_accepted=$2

#     # svtv_append_ok=""
#     # svtv_append_bad=""

#     log_it "><> save_verified_tmux_vers($svtv_vers, $svtv_is_accepted)"
#     if [ "$svtv_is_accepted" = "y" ]; then
#         ok_tmux_versions="$ok_tmux_versions $svtv_vers"
#         # svtv_append_ok="$svtv_vers"
#     else
#         bad_tmux_versions="$bad_tmux_versions $svtv_vers"
#         # svtv_append_bad="$svtv_vers"

#     fi
#     log_it "><> saving new ok/bad versions"
#     param_cache_write "y"
#     unset svtv_vers svtv_is_accepted # svtv_append_ok svtv_append_bad
# }

tmux_vers_compare() {
    #
    #  This returns true if v_comp <= v_ref
    #  If only one param is given it is compared vs version of running tmux
    #
    # log_it "><> tmux_vers_compare($1,$2) tmux_vers[$tmux_vers]"
    [ -z "$2" ] && [ -z "$tmux_vers" ] && {
        msg="tmux_vers_compare() called with neither \$2 or \$tmux_vers set"
        error_msg "$msg" -1
        return 1
    }
    v_comp="$1"
    v_ref="${2:-$tmux_vers}"

    i_comp=$(get_digits_from_string "$v_comp")

    if $cfg_use_cache; then
        if [ "$v_ref" = "$tmux_vers" ]; then

            # if echo "$ok_tmux_versions" | grep -q "\b$v_comp\b"; then
            #     # log_it "><> ---- ok match "
            #     return 0
            # elif echo "$bad_tmux_versions" | grep -q "\b$v_comp\b"; then
            #     # log_it "><> ---- fail match"
            #     return 1
            # fi

            case " $ok_tmux_versions $tmux_vers" in
            *" $v_comp "*)
                # log_it "><> ---- ok match "
                return 0
                ;;
            *) ;;
            esac
            case " $bad_tmux_versions " in
            *" $v_comp "*)
                # log_it "><> ---- fail match"
                return 1
                ;;
            *) ;;
            esac

            i_ref="$tmux_i_ref"

            [ -f "$f_tmux_vers_list" ] && {
                #
                #  Dont try to save unknown versions
                #  during initial startup, before the vers list has been
                #  created, such changes would be overwritten anyhow
                #
                # log_it
                # log_it "f_tmux_vers_list: $(ls -l $f_tmux_vers_list)"
                # log_it "ok_tmux_versions: $ok_tmux_versions"
                # log_it "bad_tmux_versions: $bad_tmux_versions"

                if [ "$i_comp" -le "$i_ref" ]; then
                    ok_tmux_versions="$ok_tmux_versions $v_comp"
                    log_it "Added ok tmux vers: $v_comp"
                else
                    bad_tmux_versions="$v_comp $bad_tmux_versions"
                    log_it "Added bad tmux vers: $v_comp"
                fi
                param_cache_write "y"
            }
        else
            log_it "><> v_ref[$v_ref] not tmux_vers[$tmux_vers]"
            i_ref=$(get_digits_from_string "$v_ref")
        fi
    else
        # not using cache
        i_ref=$(get_digits_from_string "$v_ref")
    fi

    unset v_comp v_ref
    [ "$i_comp" -le "$i_ref" ]
}

is_tmux_option_defined() {
    $TMUX_BIN show-options -g | grep -q "^$1"
}

get_tmux_option() {
    gto_option="$1"
    gto_default="$2"

    # log_it "get_tmux_option($gto_option, $gto_default)"

    [ -z "$gto_option" ] && error_msg "get_tmux_option() param 1 empty!"

    # shellcheck disable=SC2154
    [ "$TMUX" = "" ] && {
        # this is run standalone, just report the defaults
        echo "$gto_default"
        return
    }

    if gto_value="$($TMUX_BIN show-options -gv "$gto_option" 2>/dev/null)"; then
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
        [ -z "$gto_value" ] && ! is_tmux_option_defined "$gto_option" && {
            #
            #  This is a workarround, checking if the variable is defined
            #  before assigning the default, preserving intentional
            #  "" assignments
            #
            gto_value="$gto_default"
        }
    else
        #  All other versions correctly fails on unassigned @options
        gto_value="$gto_default"
    fi
    # log_it "><> gto_option[$gto_option] gto_default[$gto_default] gto_value[$gto_value]"
    echo "$gto_value"

    unset gto_option
    unset gto_default
    unset gto_value
}

normalize_bool_param() {
    #
    #  Take a boolean style text param and convert it into an actual boolean
    #  that can be used in your code. Example of usage:
    #
    #  normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
    #      cfg_no_prefix=true || cfg_no_prefix=false
    #

    param="$1"
    _variable_name=""
    # log_it "><>"
    # log_it "normalize_bool_param($param, $2)"

    [ "${param%"${param#?}"}" = "@" ] && {
        #
        #  If it starts with "@", assume it is tmux variable name, thus
        #  read its value from the tmux environment.
        #  In this case $2 must be given as the default value!
        #
        [ -z "$2" ] && {
            error_msg "normalize_bool_param($param) - no default"
        }
        _variable_name="$param"
        # log_it "><> normalize_bool_param() found @ param: [$param]"
        param="$(get_tmux_option "$param" "$2")"
        # log_it "><> normalize_bool_param() got: [$param]"
    }

    param="$(lowercase_it "$param")"

    # error_msg "><> normalize_bool_param() found[$param]" 1 false

    case "$param" in
    #
    #  First handle the unfortunate tradition by tmux to use
    #  1 to indicate selected / active.
    #  This means 1 is 0 and 0 is 1, how Orwellian...
    #
    1 | yes | true)
        #  Be a nice guy and accept some common positive notations
        return 0
        ;;

    0 | no | false)
        #  Be a nice guy and accept some common false notations
        return 1
        ;;

    *)
        if [ -n "$_variable_name" ]; then
            prefix="$_variable_name=$param"
        else
            prefix="$param"
        fi
        error_msg "$prefix - should be yes/true or no/false"
        ;;

    esac

    # Should never get here...
    return 2
}

escape_tmux_special_chars() {
    s_buffer="$1"
    escaped_str=""
    idx=0
    while true; do
        idx=$((idx + 1))
        char="$(extract_char "$s_buffer" "$idx")"
        [ -n "$char" ] || break
        [ "$char" = \\ ] && {
            # maintain \ prefixes
            idx=$((idx + 1))
            char="$char$(extract_char "$s_buffer" "$idx")"
        }
        # echo "><> idx[$idx] s_buffer[$s_buffer] char[$char]" >/dev/stderr
        case "$char" in
        \\)
            # echo "><> found double bslash" >/dev/stderr
            escaped_str="${escaped_str}\\\\"
            sleep 1
            ;;
        \")
            # echo "><> found bslash dquote" >/dev/stderr
            escaped_str="${escaped_str}\\\""
            sleep 1
            ;;
        \$)
            # echo "><> found bslash dollar" >/dev/stderr
            escaped_str="${escaped_str}\\$"
            sleep 1
            ;;
        \#)
            # echo "><> found bslash dash" >/dev/stderr
            escaped_str="${escaped_str}\\#"
            sleep 1
            ;;
        *)
            escaped_str="${escaped_str}${char}"
            sleep 0.1
            ;;
        esac

    done
    printf '%s\n' "$escaped_str"
}

get_defaults() {
    #
    #  Defaults for plugin params
    #
    default_trigger_key=\\
    default_no_prefix=No

    if tmux_vers_compare 3.2; then
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

get_plugin_params() {
    # tmux_vers must exist before calling this
    # log_it "get_plugin_params()"

    get_defaults

    # cfg_log_file="$(get_tmux_option "@menus_log_file" \
    #     "$default_log_file")"
    # exit 1

    cfg_trigger_key=$(get_tmux_option "@menus_trigger" \
        "$default_trigger_key")
    normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
        cfg_no_prefix=true || cfg_no_prefix=false
    normalize_bool_param "@menus_use_cache" "$default_use_cache" &&
        cfg_use_cache=true || cfg_use_cache=false
    log_it "><> use_cache: $cfg_use_cache"
    if $cfg_use_cache; then
        mkdir -p "$d_cache"
        [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && touch "$d_cache"/using-whiptail
    else
        # indicate that cache should not be used
        [ -f "$f_no_cache_hint" ] || touch "$f_no_cache_hint"
    fi

    cfg_mnu_loc_x="$(get_tmux_option "@menus_location_x" \
        "$default_location_x")"
    cfg_mnu_loc_y="$(get_tmux_option "@menus_location_y" \
        "$default_location_y")"
    cfg_tmux_conf="$(get_tmux_option "@menus_config_file" \
        "$default_tmux_conf")"

    if [ -z "$cfg_log_file" ]; then
        #
        #  would only be set in debug mode, in that case ignore
        #  tmux setting and defuault
        #
        cfg_log_file="$(get_tmux_option "@menus_log_file" \
            "$default_log_file")"
    fi

    #
    #  Generic plugin setting I use to add Notes to keys that are bound
    #  This makes this key binding show up when doing <prefix> ?
    #  If not set to "Yes", no attempt at adding notes will happen
    #  bind-key Notes were added in tmux 3.1, so should not be used on
    #  older versions!
    #
    if tmux_vers_compare 3.1 &&
        normalize_bool_param "@use_bind_key_notes_in_plugins" No; then

        cfg_use_notes=true
    else
        cfg_use_notes=false
    fi
}

#---------------------------------------------------------------
#
#   cache handling
#
#---------------------------------------------------------------

do_write_tmux_vers_list() {
    # log_it "do_write_tmux_vers_list()"
    $cfg_use_cache || {
        error_msg "do_write_tmux_vers_list() - called when not using cache" 1 false
    }

    #region known tmux versions
    cat <<EOF >"$f_tmux_vers_list"
#!/bin/sh
# Autogenerated always sourced file - Fake bang path to help editors/linters

#
#  This is a list of known tmux versions, given in incremental order
#  So that once the running tmux is found, all comming before can be assumed
#  to be prior, ie features depending on such versions should work on the
#  current version
#
all_tmux_versions="$known_tmux_versions"

EOF
    #endregion
    # log_it "wrote $f_tmux_vers_list"
}

generate_tmux_vers_list() {
    #
    #  Public variables
    #   all_tmux_versions
    #
    tmux_vers_changes="$1"

    # log_it "generate_tmux_vers_list($tmux_vers_changes)"

    if [ "$tmux_vers_changes" = y ]; then
        known_tmux_versions="$ok_tmux_versions $tmux_vers $bad_tmux_versions"
        do_write_tmux_vers_list
    else
        #
        #  0.0 is a custom version used by tmux-menus, to indicate an
        #      an action that should always be done
        #
        log_it "><> -----  using all known versions"
        known_tmux_versions="
            0.0
            0.8
            0.9
            1.0
            1.1
            1.2
            1.3
            1.4
            1.5
            1.6
            1.7
            1.8
            1.9
            1.9a
            2.0
            2.1
            2.2
            2.3
            2.4
            2.5
            2.6
            2.7
            2.8
            2.9
            2.9a
            3.0
            3.0a
            3.1
            3.1a
            3.1b
            3.1c
            3.2
            3.2a
            3.3
            3.3a
            3.4
        "
    fi

    if $cfg_use_cache; then
        [ -s "$f_tmux_vers_list" ] || do_write_tmux_vers_list
    else
        all_tmux_versions="$known_tmux_versions"
    fi
}

prepare_tmux_vers_check_cache() {
    #
    #  public variables
    #   tmux_vers - tmux version for this tmux server
    #   tmux_i_ref - int part of tmux_vers, for tmux_vers_compare
    #   ok_tmux_versions - known versions tmux_vers_compare accepts
    #   bad_tmux_versions - known versions tmux_vers_compare rejects
    tmux_vers_changes="$1"

    # log_it "prepare_tmux_vers_check_cache($tmux_vers_changes)"

    # log_it "><> assigning tmux_vers & tmux_i_ref"
    tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"
    tmux_i_ref=$(get_digits_from_string "$tmux_vers")

    [ "$tmux_vers_changes" != y ] && {
        # make sure we dont end up using a previous instance of this
        unset all_tmux_versions

        generate_tmux_vers_list
    }
    # shellcheck disable=SC1090
    . "$f_tmux_vers_list"

    [ "$tmux_vers_changes" = y ] || {
        ok_tmux_versions=""
        bad_tmux_versions=""
        for version in $all_tmux_versions; do
            if [ "$(expr "$version" \< "$tmux_vers")" -eq 1 ]; then
                ok_tmux_versions="$ok_tmux_versions $version"
            elif [ "$version" = "$tmux_vers" ]; then
                :
            else
                bad_tmux_versions="$bad_tmux_versions $version"
            fi
        done
    }

    unset all_tmux_versions
    unset version
}

clear_cache() {
    #
    #  Create and tag cachedir with current tmux version
    #
    log_it "clear_cache($1)"

    # $cfg_use_cache || {
    #     error_msg "clear_cache() - called when not using cache" 1 false
    # }

    rm -rf "$d_cache"
    rm -f "$f_tmux_vers_list"
    b_clear_cache_has_been_called=true
}

param_cache_write() {
    tmux_vers_changes="$1"

    log_it "param_cache_write($tmux_vers_changes)"
    $cfg_use_cache || {
        error_msg "param_cache_write() - called when not using cache" 1 false
    }

    mkdir -p "$d_cache"

    [ "$tmux_vers_changes" = "y" ] && {
        generate_tmux_vers_list "$tmux_vers_changes"
    }
    prepare_tmux_vers_check_cache "$tmux_vers_changes"
    #region param cache file
    cat <<EOF >"$f_param_cache"
#!/bin/sh
# Autogenerated always sourced file - Fake bang path to help editors/linters

cfg_trigger_key="$(escape_tmux_special_chars "$cfg_trigger_key")"
cfg_no_prefix="$cfg_no_prefix"
cfg_use_cache="$cfg_use_cache"
cfg_mnu_loc_x="$cfg_mnu_loc_x"
cfg_mnu_loc_y="$cfg_mnu_loc_y"
cfg_tmux_conf="$cfg_tmux_conf"

cfg_log_file="$cfg_log_file"
cfg_use_notes="$cfg_use_notes"

tmux_vers="$tmux_vers"
tmux_i_ref="$tmux_i_ref"
ok_tmux_versions="$ok_tmux_versions"
bad_tmux_versions="$bad_tmux_versions"

log_it "><> param cache was sourced"

EOF
    #endregion
}

generate_param_cache() {
    #
    #  will also ensure current tmux conf is used, even if other
    #  settings has already been sourced
    #     tmux_conf should have been defined before calling this
    #
    log_it "generate_param_cache()"

    # make sure current is the one being cached

    tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"
    tmux_i_ref=$(get_digits_from_string "$tmux_vers")
    get_plugin_params
    $cfg_use_cache && param_cache_write
}

cache_validation() {
    #
    #  Clear (and recreate) cache if it was not created with current
    #  tmux version and WHIPTAIL settings
    #
    #  If there was no cache, sourcing utils will have created a minimal
    #  one with just config params, this one will be disgarded as unidentified
    #
    log_it "cache_validation()"

    if [ -s "$f_param_cache" ]; then
        vers_actual="$($TMUX_BIN -V | cut -d ' ' -f 2)" # TODO: use cache
        vers_cached="$(grep tmux_vers "$f_param_cache" |
            sed 's/"//g' | cut -d'=' -f2)"

        #  compare actual vs cached
        if [ "$vers_actual" != "$vers_cached" ]; then
            clear_cache \
                "Was made for tmux: $vers_cached now using: $vers_actual"
        else
            [ -f "$d_cache"/using-whiptail ] &&
                was_whiptail=true || was_whiptail=false

            if $was_whiptail && [ "$FORCE_WHIPTAIL_MENUS" != 1 ]; then
                clear_cache "No longer using whiptail"
            elif ! $was_whiptail && [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                clear_cache "Now using whiptail"
            fi
        fi
    else
        clear_cache "failed to verify"
    fi

    # [ -n "$tmux_vers" ] || {
    #     # ensure it is defined, will be needed if there as no param_cache
    #     tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"
    # }

    #  Ensure param cache is current
    $b_clear_cache_has_been_called && generate_param_cache
    b_cache_has_been_validated=true
}

get_config() {
    #
    #  The plugin init .tmux script should NOT depend on this!
    #
    #  It should instead direcly call cache_validation to ensure
    #  the cached configs match current tmux configuration
    #
    #  This is used by everything else sourcing utils.sh, then trusting
    #  that the param cache is valid if found
    #
    # log_it "get_config()"

    tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"
    tmux_i_ref=$(get_digits_from_string "$tmux_vers")

    if [ -f "$f_no_cache_hint" ]; then
        get_plugin_params
    else
        if [ ! -s "$f_param_cache" ]; then
            # param_cache missing, dont trust current cache, replace it
            cache_validation
        fi

        # shellcheck source=cache/plugin_params
        # shellcheck disable=SC1091
        [ -f "$f_no_cache_hint" ] || . "$f_param_cache"
    fi
}

#---------------------------------------------------------------
#
#   Other
#
#---------------------------------------------------------------

safe_now() {
    #
    #  MacOS date only counts whole seconds, if gdate (GNU-date) is
    #  installed, it can  display times with more precission
    #
    if [ "$(uname)" = "Darwin" ]; then
        if [ -n "$(command -v gdate)" ]; then
            gdate +%s.%N
        else
            date +%s
        fi
    else
        #  On Linux the native date suports sub second precission
        date +%s.%N
    fi
}

wait_to_close_display() {
    #
    #  When a menu item writes to stdout, unfortunately how to close
    #  the output window differs depending on dialog method used...
    #  call this to display an apropriate suggestion, and in the
    #  whiptail case wait for that key
    #
    echo
    # shellcheck disable=SC2154
    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
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

plugin_name="tmux-menus"

#
#  Setting a cfg_log_file here overrides tmux config, should only
#  be used for debugging
#
cfg_log_file="$HOME/tmp/$plugin_name-t2.log"

#
#  Even if this one is used, a cfg_log_file must still be defined
#  since log_it quick aborts if that is undefined
#
log_interactive_to_stderr=false

[ -z "$D_TM_BASE_PATH" ] && error_msg "D_TM_BASE_PATH undefined"

log_it "><> sourcing utils.sh"

#
#  Convencience shortcuts
#
d_items="$D_TM_BASE_PATH"/items
d_scripts="$D_TM_BASE_PATH"/scripts
d_cache="$D_TM_BASE_PATH"/cache

#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf, to pick the version matching the server running.
#  This is needed when checking backward compatibility with various versions.
#  If not found, it is set to whatever is in the path, so should have no negative
#  impact. In all calls to tmux I use $TMUX_BIN instead in the rest of this
#  plugin.
#
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

#
#  Convert script name to full actual path notation the path is used
#  for caching, so save it to a variable as well
#
current_script="$(basename "$0")" # name without path
d_current_script="$(realpath -- "$(dirname -- "$0")")"
f_current_script="$d_current_script/$current_script"

#
#  in some cases, like Move Window, the menu is exited
#  during destination selection.
#  This hint can be used to re-start the last one displayed
#
f_last_menu_displayed="$d_cache/last_menu_displayed"

# cache plugin params
f_param_cache="$d_cache"/plugin_params
f_tmux_vers_list="$d_scripts"/tmux_vers_list.sh
# shellcheck disable=SC2086
f_no_cache_hint=/tmp/no_cache_hint-"$(echo $TMUX | cut -d',' -f2)"

b_cache_has_been_validated=false
b_clear_cache_has_been_called=false

#
#  at this point plugin_params is trusted if found, menus.tmux will
#  allways always replace it with current tmux conf during plugin init
#
get_config

min_tmux_vers="1.7"
if ! tmux_vers_compare 3.0; then
    if ! tmux_vers_compare "$min_tmux_vers"; then
        error_msg "need at least tmux $min_tmux_vers to work!"
    fi
    FORCE_WHIPTAIL_MENUS=1
fi

if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
    menu_reload="; $f_current_script"
    #
    #  in whiptail run-shell cant chain to another menu, so instead
    #  reload script is written to a tmp file, and if it is found
    #  it will be exeuted at the end of dialog_handling.sh
    #
    f_wt_reload_script="$d_cache"/reload
    reload_in_runshell=" ; echo $f_current_script > $f_wt_reload_script"

else
    menu_reload="; run-shell \"$f_current_script\""
    reload_in_runshell=" ; $f_current_script"
fi

# [ "$(basename "$0")" = "menus.tmux" ] && return

# log_it "-----   end of utils"
