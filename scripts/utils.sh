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
    #  If $2 is set to 0, process is not exited
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
    rm -f "$f_tmux_err" # remove if no error
    return 0
}

parse_tmux_version() {
    _v="$1"
    v_maj=$(echo "$_v" | cut -d. -f1)
    v_min=$(echo "$_v" | cut -d. -f2 | sed 's/[^0-9]//g')
    v_suffix=$(echo "$_v" | cut -d. -f2 | sed 's/[0-9]//g')
    unset _v

    if [ -z "$v_min" ]; then
        v_min=0
    fi

    if [ -n "$v_suffix" ]; then
        v_suffix=$(echo "$v_suffix" | tr '[:lower:]' '1-26')
    else
        v_suffix=0
    fi
}

tmux_vers_compare() {
    #
    #  This returns true if v_comp <= v_ref
    #  If only one param is given it is compared vs version of running tmux
    #
    v_comp="$1"
    v_ref="${2:-$tmux_vers}"
    # log_it "[$current_script] tmux_vers_chek($v_comp, $v_ref) tmux_vers[$tmux_vers]"

    [ -z "$v_ref" ] && {
        error_msg "tmux_vers_compare() - Neither param 2 or tmux_vers defined"
    }

    parse_tmux_version "$v_comp"
    comp_maj=$v_maj
    comp_min=$v_min
    comp_suf=$v_suffix

    parse_tmux_version "$v_ref"
    ref_maj=$v_maj
    ref_min=$v_min
    ref_suf=$v_suffix

    # echo "><> comp_maj[$comp_maj] comp_min[$comp_min]comp_suf[$comp_suf]" >/dev/stderr
    # echo "><> ref_maj[$ref_maj] ref_min[$ref_min]ref_suf[$ref_suf]" >/dev/stderr
    unset v_maj v_min v_suffix

    if [ "$comp_maj" -lt "$ref_maj" ]; then
        return 0
    elif [ "$comp_maj" -gt "$ref_maj" ]; then
        return 1
    fi

    if [ "$comp_min" -lt "$ref_min" ]; then
        return 0
    elif [ "$comp_min" -gt "$ref_min" ]; then
        return 1
    fi

    if [ "$comp_suf" -le "$ref_suf" ]; then
        return 0
    else
        return 1
    fi
}

get_tmux_option() {
    gto_option="$1"
    gto_default="$2"

    # log_it "get_tmux_option($gto_option, $gto_default)"

    [ -z "$gto_option" ] && error_msg "get_tmux_option() param 1 empty!"
    # shellcheck disable=SC215
    [ "$TMUX" = "" ] && {
        # this is run standalone, just report the defaults
        echo "$gto_default"
        return
    }

    if tmux_vers_compare 1.8; then
        gto_value="$(tmux_error_handler show-options -gqv "$gto_option")"
    else
        # pre 1.8 user variables cant be read
        gto_value=""
    fi

    if [ -z "$gto_value" ]; then
        echo "$gto_default"
    else
        echo "$gto_value"
    fi

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
        param="$(get_tmux_option "$param" "$2")"
    }

    param="$(lowercase_it "$param")"

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
    # log_it "get_plugin_params()"

    #
    #  Generic plugin setting I use to add Notes to keys that are bound
    #  This makes this key binding show up when doing <prefix> ?
    #  If not set to "Yes", no attempt at adding notes will happen
    #  bind-key Notes were added in tmux 3.1, so should not be used on
    #  older versions!
    #
    get_defaults

    cfg_trigger_key=$(get_tmux_option "@menus_trigger" "$default_trigger_key")
    normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
        cfg_no_prefix=true || cfg_no_prefix=false
    normalize_bool_param "@menus_use_cache" "$default_use_cache" &&
        cfg_use_cache=true || cfg_use_cache=false
    cfg_mnu_loc_x="$(get_tmux_option "@menus_location_x" "$default_location_x")"
    cfg_mnu_loc_y="$(get_tmux_option "@menus_location_y" "$default_location_y")"
    cfg_tmux_conf="$(get_tmux_option "@menus_config_file" "$default_tmux_conf")"

    if [ -z "$cfg_log_file" ]; then
        #
        #  would only be set in debug mode, in that case ignore
        #  tmux setting and defuault
        #
        cfg_log_file="$(get_tmux_option "@menus_log_file" "$default_log_file")"
    fi

    #
    #  Generic plugin setting I use to add Notes to keys that are bound
    #  This makes this key binding show up when doing <prefix> ?
    #  If not set to "Yes", no attempt at adding notes will happen
    #  bind-key Notes were added in tmux 3.1, so should not be used on
    #  older versions!
    #
    if tmux_vers_compare 3.1 && normalize_bool_param "@use_bind_key_notes_in_plugins" No; then
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
    #  Create and tag cachedir with current tmux version
    #
    log_it "clear_cache() - $1"

    rm -rf "$d_cache"
    mkdir -p "$d_cache"
    echo "$tmux_vers" >"$f_cached_tmux"
    [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && touch "$d_cache"/using-whiptail
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

    if [ -s "$f_cached_tmux" ]; then
        tmux_vers_in_cache="$(cat "$f_cached_tmux")"
        [ "$tmux_vers" != "$tmux_vers_in_cache" ] && {
            clear_cache \
                "Was made for tmux: $tmux_vers_in_cache now using: $tmux_vers"
        }
        [ -f "$d_cache"/using-whiptail ] &&
            was_whiptail=true || was_whiptail=false

        if $was_whiptail && [ "$FORCE_WHIPTAIL_MENUS" != 1 ]; then
            clear_cache "No longer using whiptail"
        elif ! $was_whiptail && [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
            clear_cache "Now using whiptail"
        fi
    else
        clear_cache "failed to verify"
    fi

    # Ensure param cache is current
    generate_param_cache
}

param_cache_write() {
    # log_it "param_cache_write()"
    mkdir -p "$d_cache"

    #region param cache file
    cat <<EOF >"$f_param_cache"
#!/bin/sh
# Always sourced file - Fake bang path to help editors
cfg_trigger_key="$(escape_tmux_special_chars "$cfg_trigger_key")"
cfg_no_prefix="$cfg_no_prefix"
cfg_use_cache="$cfg_use_cache"
cfg_mnu_loc_x="$cfg_mnu_loc_x"
cfg_mnu_loc_y="$cfg_mnu_loc_y"
cfg_tmux_conf="$cfg_tmux_conf"

cfg_log_file="$cfg_log_file"
cfg_use_notes="$cfg_use_notes"
EOF
    #endregion
}

generate_param_cache() {
    # log_it "generate_param_cache()"
    get_plugin_params
    param_cache_write
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
    log_it "get_config()"
    if [ ! -s "$f_param_cache" ]; then
        # param_cache missing, dont trust current cache, replace it
        cache_validation
    fi

    # shellcheck source=/dev/null
    . "$f_param_cache"
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
cfg_log_file="$HOME/tmp/$plugin_name.log"

log_interactive_to_stderr=false

[ -z "$D_TM_BASE_PATH" ] && error_msg "D_TM_BASE_PATH undefined"

log_it "><> sourcing utils.sh"

#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf, to pick the version matching the server running.
#  This is needed when checking backward compatibility with various versions.
#  If not found, it is set to whatever is in the path, so should have no negative
#  impact. In all calls to tmux I use $TMUX_BIN instead in the rest of this
#  plugin.
#
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"
min_tmux_vers="1.7"

current_script="$(basename "$0")" # name without path
#
#  Convert script name to full actual path notation the path is used
#  for caching, so save it to a variable as well

d_current_script="$(realpath -- "$(dirname -- "$0")")"
f_current_script="$d_current_script/$current_script"

if ! tmux_vers_compare 3.0; then
    if ! tmux_vers_compare "$min_tmux_vers"; then
        error_msg "need at least tmux $min_tmux_vers to work!"
    fi
    FORCE_WHIPTAIL_MENUS=1
fi

#
#  Define variables that can be used as suffix on commands in dialog
#  items, to reload the same menu
#
d_cache="$D_TM_BASE_PATH"/cache
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

#
#  in some cases, like Move Window, the menu is exited
#  during destination selection.
#  This hint can be used to re-start the last one displayed
#
f_last_menu_displayed="$d_cache/last_menu_displayed"

#
#  The plugin init script checks this at startup
#  if the running tmux version is not the same as the one that created
#  the cache, the cache is deleted
#
f_cached_tmux="$d_cache"/tmux-vers

#
#  This is for shells checking status.
#  In tmux code #{?@menus_config_overrides,,} can be used
#

#
#  All calling scripts must provide
#

d_items="$D_TM_BASE_PATH"/items
d_scripts="$D_TM_BASE_PATH"/scripts

f_param_cache="$D_TM_BASE_PATH"/cache/plugin_params

# [ "$(basename "$0")" = "menus.tmux" ] && return

get_config
