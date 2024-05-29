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
    em_msg="ERROR: $1"
    exit_code="${2:-0}"
    do_display_message=${3:-true}

    if $log_interactive_to_stderr && [ -t 0 ]; then
        echo "$em_msg" >/dev/stderr
    else
        log_it
        log_it "$em_msg"
        log_it

        #  display-message filters out \n
        em_msg="$(echo "$em_msg" | tr '\n' ' ')"

        $do_display_message && display_message_hold "$plugin_name $em_msg"
    fi

    [ "$exit_code" -gt -1 ] && exit "$exit_code"

    unset em_msg
    unset exit_code
    unset do_display_message
}

display_message_hold() {
    #
    #  Display a message and hold until key-press
    #  Can't use tmux_error_handler in this func, since that could
    #  trigger recursion
    #
    dmh_msg="$1"

    echo "><> display_message_hold($dmh_msg)" >/dev/stderr

    if tmux_vers_check 3.2; then
        # message will remain until key-press
        $TMUX_BIN display-message -d 0 "$dmh_msg"
    else
        # Manually make the error msg stay on screen a long time
        org_display_time="$($TMUX_BIN show-option -gv display-time)"
        $TMUX_BIN set -g display-time 120000 >/dev/null
        $TMUX_BIN display-message "$dmh_msg"

        posix_get_char >/dev/null # wait for keypress
        $TMUX_BIN set -g display-time "$org_display_time" >/dev/null
        unset org_display_time
    fi
    unset dmh_msg
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
    unset str pos
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

get_tmux_vers() {
    $TMUX_BIN -V | cut -d ' ' -f 2
}
define_tmux_vers_vars() {
    #
    #  Public variables
    #   tmux_vers - currently running tmux version
    #   tmux_i_ref - integer part, used by tmux_vers_check()
    #

    # log_it "define_tmux_vers_vars()"
    tmux_vers="$(get_tmux_vers)"
    tmux_i_ref=$(get_digits_from_string "$tmux_vers")
}

tmux_error_handler() {
    #
    #  Detects any errors reported by tmux commands and gives notification
    #
    cmd="$*"

    # log_it "tmux_error_handler($cmd)"

    if $cfg_use_cache; then
        mkdir -p "$d_cache"
        f_tmux_err="$d_cache"/tmux-err

        $TMUX_BIN "$@" 2>"$f_tmux_err"

        [ -s "$f_tmux_err" ] && {
            #
            #  First save the error to a n
            cuc_i=1
            _f="${f_tmux_err}-$cuc_i"
            while [ -f "$_f" ]; do
                cuc_i=$((cuc_i + 1))
                _f="${f_tmux_err}-$cuc_i"
                [ "$cuc_i" -gt 1000 ] && {
                    error_msg "Aborting runaway loop - cuc_i=$cuc_i"
                }
            done
            log_it "saved error to: [$_f]"
            mv "$f_tmux_err" "$_f"
            error_msg "$(cat "$_f")"
            unset cuc_i
        }
    else
        $TMUX_BIN "$@" || {
            error_msg "tmux cmd gave error: $?"
        }
    fi
    unset f_tmux_err
    return 0
}

do_write_tmux_vers_list() {
    log_it "do_write_tmux_vers_list()"
    $cfg_use_cache || {
        error_msg "do_write_tmux_vers_list() - called when not using cache"
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
    gtvl_changes="$1"

    log_it "generate_tmux_vers_list($gtvl_changes)"

    if [ "$gtvl_changes" = y ] && $cfg_use_cache; then
        # if an unrecognized tmux version was detected, add it to this list
        known_tmux_versions="$ok_tmux_versions $tmux_vers $bad_tmux_versions"
        do_write_tmux_vers_list
    else
        #
        #  0.0 is a custom version used by tmux-menus, to indicate an
        #      an action that should always be done
        #
        # log_it "><> -----  using all known versions"
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
        if $cfg_use_cache; then
            # only write it if missing...
            [ -s "$f_tmux_vers_list" ] || do_write_tmux_vers_list
        else
            all_tmux_versions="$known_tmux_versions"
        fi
    fi

    unset gtvl_changes known_tmux_versions
}

define_tmux_vers_check_env() {
    #
    #  public variables
    #   tmux_vers - tmux version for this tmux server
    #   tmux_i_ref - int part of tmux_vers, for tmux_vers_check
    #   ok_tmux_versions - known versions tmux_vers_check accepts
    #   bad_tmux_versions - known versions tmux_vers_check rejects
    #
    ptvcc_changes="$1"

    log_it "define_tmux_vers_check_env($ptvcc_changes) - defines tmux_vers"

    define_tmux_vers_vars

    [ "$ptvcc_changes" != y ] && {
        # make sure we dont end up using a previous instance of this
        unset all_tmux_versions

        generate_tmux_vers_list
    }
    # shellcheck disable=SC1090
    . "$f_tmux_vers_list"

    [ "$ptvcc_changes" = y ] || {
        ok_tmux_versions=""
        bad_tmux_versions=""
        for ptvcc_vers in $all_tmux_versions; do
            if [ "$(expr "$ptvcc_vers" \< "$tmux_vers")" -eq 1 ]; then
                ok_tmux_versions="$ok_tmux_versions $ptvcc_vers"
            elif [ "$ptvcc_vers" = "$tmux_vers" ]; then
                :
            else
                bad_tmux_versions="$bad_tmux_versions $ptvcc_vers"
            fi
        done
    }

    unset ptvcc_changes
    unset all_tmux_versions
    unset ptvcc_vers
}

tmux_vers_check() {
    #
    #  This returns true if v_comp <= v_ref
    #  If only one param is given it is compared vs version of running tmux
    #

    # log_it "><> tmux_vers_check($1,$2) tmux_vers[$tmux_vers]"
    [ -z "$2" ] && [ -z "$tmux_vers" ] && {
        tvc_msg="tmux_vers_check() called with neither \$2 or \$tmux_vers set"
        error_msg "$tvc_msg" -1 false
        unset tvc_msg
        exit 1
        # return 1
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
                if echo "$ok_tmux_versions" | grep -q "\b$v_comp\b"; then
                    # log_it "><> ---- ok match "
                    return 0
                elif echo "$bad_tmux_versions" | grep -q "\b$v_comp\b"; then
                    # log_it "><> ---- fail match"
                    return 1
                fi
            else
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
            fi

            i_ref="$tmux_i_ref"

            [ -f "$f_tmux_vers_list" ] && {
                #
                #  Dont try to save unknown versions
                #  during initial startup, before the vers list has been
                #  created, such changes would be overwritten anyhow
                #
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

    nbp_param="$1"
    _variable_name=""
    # log_it "><>"
    # log_it "normalize_bool_param($nbp_param, $2)"

    [ "${nbp_param%"${nbp_param#?}"}" = "@" ] && {
        #
        #  If it starts with "@", assume it is tmux variable name, thus
        #  read its value from the tmux environment.
        #  In this case $2 must be given as the default value!
        #
        [ -z "$2" ] && {
            error_msg "normalize_bool_param($nbp_param) - no default"
        }
        _variable_name="$nbp_param"
        # log_it "><> normalize_bool_param() found @ nbp_param: [$nbp_param]"
        nbp_param="$(get_tmux_option "$nbp_param" "$2")"
        # log_it "><> normalize_bool_param() got: [$nbp_param]"
    }

    nbp_param="$(lowercase_it "$nbp_param")"

    # error_msg "><> normalize_bool_param() found[$nbp_param]" 1 false

    case "$nbp_param" in
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
            prefix="$_variable_name=$nbp_param"
        else
            prefix="$nbp_param"
        fi
        error_msg "$prefix - should be yes/true or no/false"
        ;;

    esac

    # Should never get here...
    return 2
}

escape_tmux_special_chars() {
    etsc_str="$1"
    etsc_idx=0
    while true; do
        etsc_idx=$((etsc_idx + 1))
        char="$(extract_char "$etsc_str" "$etsc_idx")"
        [ -n "$char" ] || break
        [ "$char" = \\ ] && {
            # maintain \ prefixes
            etsc_idx=$((etsc_idx + 1))
            char="$char$(extract_char "$etsc_str" "$etsc_idx")"
        }
        # echo "><> etsc_idx[$etsc_idx] etsc_str[$etsc_str] char[$char]" >/dev/stderr
        case "$char" in
        \\)
            # echo "><> found double bslash" >/dev/stderr
            etsc_escaped_str="${etsc_escaped_str}\\\\"
            sleep 1
            ;;
        \")
            # echo "><> found bslash dquote" >/dev/stderr
            etsc_escaped_str="${etsc_escaped_str}\\\""
            sleep 1
            ;;
        \$)
            # echo "><> found bslash dollar" >/dev/stderr
            etsc_escaped_str="${etsc_escaped_str}\\$"
            sleep 1
            ;;
        \#)
            # echo "><> found bslash dash" >/dev/stderr
            etsc_escaped_str="${etsc_escaped_str}\\#"
            sleep 1
            ;;
        *)
            etsc_escaped_str="${etsc_escaped_str}${char}"
            sleep 0.1
            ;;
        esac

    done
    printf '%s\n' "$etsc_escaped_str"
    unset etsc_str etsc_idx etsc_escaped_str
}

get_plugin_params() {
    #
    #  Public variables
    #   cfg_  config variables, either read from tmux or the default
    #

    # log_it "get_plugin_params()"

    get_defaults

    cfg_trigger_key=$(get_tmux_option "@menus_trigger" \
        "$default_trigger_key")
    normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
        cfg_no_prefix=true || cfg_no_prefix=false
    normalize_bool_param "@menus_use_cache" "$default_use_cache" &&
        cfg_use_cache=true || cfg_use_cache=false

    #
    #  Setup env depending on if cache is used or not
    #
    # log_it "><> use_cache: $cfg_use_cache"
    if $cfg_use_cache; then
        mkdir -p "$d_cache"
        [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && touch "$f_using_whiptail"
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
    if tmux_vers_check 3.1 &&
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

clear_cache() {
    #
    #  Clear cache related files, since this only removes files if found
    #  it can be called also when cache is disabled.
    #

    # log_it "clear_cache($1)"

    rm -rf "$d_cache"
    rm -f "$f_tmux_vers_list"
    b_clear_cache_has_been_called=true
}

param_cache_write() {
    pcw_tmux_vers_changes="$1"

    log_it "param_cache_write($pcw_tmux_vers_changes)"
    $cfg_use_cache || {
        error_msg "param_cache_write() - called when not using cache" 1 false
    }

    mkdir -p "$d_cache"

    [ "$pcw_tmux_vers_changes" = y ] && {
        generate_tmux_vers_list "$pcw_tmux_vers_changes"
    }
    define_tmux_vers_check_env "$pcw_tmux_vers_changes"
    #region param cache file
    cat <<EOF >"$f_param_cache"
#!/bin/sh
# Autogenerated always sourced file - Fake bang path to help editors/linters

#  This is a cache of all tmux options, and some other configs.
#  By sourcing this instead of gathering it each time, tons of time
#  is saved

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

#  If logging is enabled, sourcing this will be logged
# log_it "><> param cache was sourced"

EOF
    #endregion
    unset pcw_tmux_vers_changes
}

generate_param_cache() {
    #
    #  will also ensure current tmux conf is used, even if other
    #  settings has already been sourced
    #     tmux_conf should have been defined before calling this
    #

    # log_it "generate_param_cache() - defines tmux_vers"
    define_tmux_vers_vars
    get_plugin_params
    $cfg_use_cache && param_cache_write
}

cache_validation() {
    #
    #  Clear (and recreate) cache if it was not created with current
    #  tmux version and WHIPTAIL settings
    #
    #  Public variables that might be altered
    #   b_clear_cache_has_been_called
    #   b_cache_has_been_validated
    #

    # log_it "cache_validation()"

    if [ -s "$f_param_cache" ]; then
        vers_actual="$(get_tmux_vers)"
        vers_cached="$(grep tmux_vers "$f_param_cache" |
            sed 's/"//g' | cut -d'=' -f2)"

        #  compare actual vs cached
        if [ "$vers_actual" != "$vers_cached" ]; then
            clear_cache \
                "Was made for tmux: $vers_cached now using: $vers_actual"
        else
            [ -f "$f_using_whiptail" ] &&
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

    #  Ensure param cache is current
    $b_clear_cache_has_been_called && generate_param_cache

    # hint for menus.tmux that it does not need to repeat the action
    b_cache_has_been_validated=true

    unset vers_actual vers_cached was_whiptail
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

    if [ -f "$f_no_cache_hint" ]; then
        define_tmux_vers_vars
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

get_defaults() {
    #
    #  Defaults for plugin params
    #
    #  Public variables
    #   default_  defaults for tmux config options
    #

    # log_it "get_defaults()"

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

safe_now() {
    #
    #  MacOS date only display whole seconds, if gdate (GNU-date) is
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

# log_it "><> sourcing utils.sh"

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
f_using_whiptail="$d_cache"/using-whiptail

#
#  this is created with a list of all known versions of tmux, if an
#  unknown version is encountered, it is added to this file, and will
#  thus be cached for all future runs of any menu
#  It is saved outside the cache dir, in order not to disapear if
#  cache is purged by running a different version of tmux
#  it is in .gitignore, so shouldnt create git pull issues
#
f_tmux_vers_list="$d_scripts"/tmux_vers_list.sh

#
#  To indicate that cache should not be used, without writing anything
#  inside the plugin folder, a file in $TMPDIR or /tmp is used
#
# shellcheck disable=SC2086
tmpdir="${TMPDIR:-/tmp}"
tmux_pid="$(echo $TMUX | cut -d',' -f2)"

f_no_cache_hint="${tmpdir}/${plugin_name}-no_cache_hint-${tmux_pid}"

b_cache_has_been_validated=false
b_clear_cache_has_been_called=false

#
#  at this point plugin_params is trusted if found, menus.tmux will
#  allways always replace it with current tmux conf during plugin init
#
get_config

min_tmux_vers="1.7"
if ! tmux_vers_check 3.0; then
    if ! tmux_vers_check "$min_tmux_vers"; then
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
    f_wt_reload_script="${tmpdir}/${plugin_name}-reload-${tmux_pid}"
    reload_in_runshell=" ; echo $f_current_script > $f_wt_reload_script"

else
    menu_reload="; run-shell \"$f_current_script\""
    reload_in_runshell=" ; $f_current_script"
fi

# [ "$(basename "$0")" = "menus.tmux" ] && return

log_it "-----   end of utils"
# error_msg "><> Aborting at end of utils" 1 false
