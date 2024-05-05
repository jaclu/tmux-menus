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
    #
    #  If @packet-loss-log_file is defined, it will be read into the
    #  cfg_log_file variable and used for logging.
    #
    #  Logging should normally be disabled, since it causes some overhead.
    #

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
    exit_code="${2:-1}"
    display_message=${3:-false}

    if $log_interactive_to_stderr && [ -t 0 ]; then
        echo "$msg" >/dev/stderr
    else
        log_it
        log_it "$msg"
        log_it
        $display_message && {
            # only display exit triggering errors on status bar
            $TMUX_BIN display-message -d 0 "tmux-menus:$msg"
        }
    fi
    [ "$exit_code" -gt 0 ] && exit "$exit_code"

    unset msg
    unset exit_code
    unset display_message
}

#---------------------------------------------------------------
#
#   tmux env handling
#
#---------------------------------------------------------------

tmux_vers_compare() {
    #
    #  This returns true if v1 <= v2
    #  If only one param is given it is compared vs version of running tmux
    #
    tvc_v1="$1"
    tvc_v2="${2:-$tmux_vers}"

    # log_it "tmux_vers_compare($v1, $v2)"

    # insert . between each char for consistent notation
    tvc_v1="$(echo "$tvc_v1" | sed 's/[^.]/.&/g' | sed 's/\.\././g' | sed 's/^\.//;s/\.$//')"
    tvc_v2="$(echo "$tvc_v2" | sed 's/[^.]/.&/g' | sed 's/\.\././g' | sed 's/^\.//;s/\.$//')"

    tvc_idx=1
    while true; do
        tvc_c="$(echo "$tvc_v1" | cut -d. -f "$tvc_idx")"
        tvc_i1="$(printf "%d" "'$tvc_c")"
        tvc_c="$(echo "$tvc_v2" | cut -d. -f "$tvc_idx")"
        tvc_i2="$(printf "%d" "'$tvc_c")"
        if [ "$tvc_i2" = 0 ] || [ "$tvc_i1" -lt "$tvc_i2" ]; then
            tvc_rslt=0
            break
        elif [ "$tvc_i1" = 0 ] || [ "$tvc_i1" -gt "$tvc_i2" ]; then
            tvc_rslt=1
            break
        fi
        tvc_idx=$((tvc_idx + 1))
    done

    # log_it "tmux_vers_compare: $v1 <= $v2 -  $tvc_rslt"

    unset tvc_v1
    unset tvc_v2
    unset tvc_idx
    unset tvc_c
    unset tvc_i1
    unset tvc_i2
    return "$tvc_rslt"
}

get_tmux_option() {
    gto_option="$1"
    gto_default="$2"

    [ -z "$gto_option" ] && error_msg "get_tmux_option() param 1 empty!"
    # shellcheck disable=SC2154
    [ "$TMUX" = "" ] && {
        # this is run standalone, just report the defaults
        echo "$gto_default"
        return
    }

    gto_value="$($TMUX_BIN show-option -gqv "$gto_option")"
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
    #  Ensure boolean style params use consistent states
    #
    param="$1"

    [ "${param%"${param#?}"}" = "@" ] && {
        # Assume tmux variable name, use $2 as default
        [ -z "$2" ] && {
            error_msg "normalize_bool_param($param) - no default" 1 true
        }
        param="$(get_tmux_option "$param" "$2")"
    }

    case "$param" in
    #
    #  First handle the unfortunate tradition by tmux to use
    #  1 to indicate selected / active.
    #  This means 1 is 0 and 0 is 1, how Orwellian...
    #
    1 | yes | Yes | YES | true | True | TRUE)
        #  Be a nice guy and accept some common positive notations
        return 0
        ;;

    0 | no | No | NO | false | False | FALSE)
        #  Be a nice guy and accept some common false notations
        return 1
        ;;

    *)
        error_msg \
            "normalize_bool_param($1) - should be yes/true/1 or no/false/0" \
            1 true
        ;;

    esac

    return 2
}

get_plugin_params() {
    #
    #  Generic plugin setting I use to add Notes to keys that are bound
    #  This makes this key binding show up when doing <prefix> ?
    #  If not set to "Yes", no attempt at adding notes will happen
    #  bind-key Notes were added in tmux 3.1, so should not be used on
    #  older versions!
    #
    log_it "><> get_plugin_params()"

    cfg_trigger_key=$(get_tmux_option "@menus_trigger" "$default_trigger_key")

    normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
        cfg_no_prefix=true || cfg_no_prefix=false

    normalize_bool_param "@menus_use_cache" "$default_use_cache" &&
        cfg_use_cache=true || cfg_use_cache=false

    cfg_log_file="$(get_tmux_option "@menus_log_file" "$default_log_file")"

    # log_it "get_plugin_params()"

    cfg_tmux_conf="$(get_tmux_option "@menus_config_file" "$default_tmux_conf")"

    cfg_mnu_loc_x="$(get_tmux_option "@menus_location_x" "$default_location_x")"
    cfg_mnu_loc_y="$(get_tmux_option "@menus_location_y" "$default_location_y")"

    normalize_bool_param "@use_bind_key_notes_in_plugins" No &&
        cfg_use_notes=true || cfg_use_notes=false
}

escape_tmux_special_chars() {
    str="$1"
    escaped_str=""
    while [ -n "$str" ]; do
        char="$(printf '%s' "$str" | cut -c1)"
        case "$char" in
        \\)
            escaped_str="${escaped_str}\\\\\\\\"
            ;;
        \")
            escaped_str="${escaped_str}\\\""
            ;;
        \$)
            escaped_str="${escaped_str}\\$"
            ;;
        \#)
            escaped_str="${escaped_str}\\#"
            ;;
        *)
            escaped_str="${escaped_str}${char}"
            ;;
        esac
        str="$(printf '%s' "$str" | cut -c2-)"
    done
    printf '%s\n' "$escaped_str"
}

#---------------------------------------------------------------
#
#   cache handling
#
#---------------------------------------------------------------

param_cache_write() {
    conf_file="${1:-$f_param_cache}"
    echo "param_cache_write($conf_file)"
    mkdir -p "$d_cache"
    echo "#!/bin/sh # Always sourced file - Fake bang path to help editors
    cfg_trigger_key=\"$(escape_tmux_special_chars "$cfg_trigger_key")\"
    cfg_no_prefix=\"$cfg_no_prefix\"
    cfg_use_cache=\"$cfg_use_cache\"
    cfg_use_notes=\"$cfg_use_notes\"
    cfg_mnu_loc_x=\"$cfg_mnu_loc_x\"
    cfg_mnu_loc_y=\"$cfg_mnu_loc_y\"
    cfg_tmux_conf=\"$cfg_tmux_conf\"
    cfg_log_file=\"$cfg_log_file\"
    " >"$conf_file"
}

generate_param_cache() {
    log_it "><> generate_param_cache()"
    get_plugin_params

    # echo "orig: [$cfg_trigger_key]"
    # echo "escaped: [$(escape_tmux_special_chars "$cfg_trigger_key")]"

    f_params_new="$f_param_cache".new
    param_cache_write "$f_params_new"

    if cmp -s "$f_params_new" "$f_param_cache"; then
        rm -f "$f_params_new"
    else
        echo "renaming $(basename "$f_params_new") > $(basename "$f_param_cache")"
        mv "$f_params_new" "$f_param_cache"
    fi
    unset f_params_new
}

get_config() {
    log_it "><> get_config()"
    #
    #  The plugin init .tmux script should NOT call this!
    #
    #  It should instead direcly call generate_param_cache to ensure
    #  the cached configs match current tmux env
    #
    #  Calls to this trusts the param cache to be valid if found
    #
    [ -s "$f_param_cache" ] || generate_param_cache

    log_it "><> sourcing $f_param_cache"
    # shellcheck source=/dev/null
    . "$f_param_cache"
}

#---------------------------------------------------------------
#
#   Other
#
#---------------------------------------------------------------

wait_to_close_display() {
    #
    #  When a menu item writes to stdout, unfortunately how to close
    #  the output window differs depending on dialog method used...
    #  call this to display an apropriate suggestion, and in the
    #  whiptail case wait for that key
    #
    echo
    # shellcheck disable=SC2154
    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ] || ! tmux_vers_compare 3.0; then
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

[ -z "$D_TM_BASE_PATH" ] && error_msg "D_TM_BASE_PATH undefined"

#
#  If log_file is empty or undefined, no logging will occur,
#  so comment it out for normal usage.
#
# log_file="/tmp/tmux-menus.log"

#
#  If @menus_config_overrides is 1, this file is used to store
#  custom settings. If it is missing, it will be re-created with defaults
#
custom_config_file="/tmp/tmux-menus.conf"

#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf, to pick the version matching the server running.
#  This is needed when checking backward compatibility with various versions.
#  If not found, it is set to whatever is in the path, so should have no negative
#  impact. In all calls to tmux I use $TMUX_BIN instead in the rest of this
#  plugin.
#
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

if ! tmux_vers_compare 1.7; then
    error_msg "This needs at least tmux 1.7 to work!"
fi

tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"

current_script="$(basename "$0")" # name without path
#
#  Convert script name to full actual path notation the path is used
#  for caching, so save it to a variable as well
#
d_current_script="$(cd -- "$(dirname -- "$0")" && pwd)"
f_current_script="$d_current_script/$current_script"

tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"

#
#  Define a variable that can be used as suffix on commands in dialog
#  items, to reload the same menu in calling scripts
#
if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
    menu_reload="; '$f_current_script'"
    d_cache="$D_TM_BASE_PATH"/cache/whiptail
else
    menu_reload="; run-shell '$f_current_script'"
    d_cache="$D_TM_BASE_PATH"/cache
fi

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

#
#  Defaults for plugin params
#

default_trigger_key=F9
default_use_cache=Yes
default_no_prefix=No
default_log_file=""
default_location_x=P
default_location_y=P
default_conf_overrides=No
default_tmux_conf="${TMUX_CONF:-~/.tmux.conf}"
log_interactive_to_stderr=false

log_it "><> utils calling get_config"
get_config
log_it "><> utils returned from get_config"
