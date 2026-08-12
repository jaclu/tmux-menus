#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Initiate plugin, should be run in background from .tmux file
#

is_key_enter_available() {
    # Clunky but version independent approach
    _ikea_found=0
    if tmux_vers_check 2.1; then
        "$TMUX_BIN" list-keys -T prefix | awk '{ print $4 }' | grep -q Enter && _ikea_found=1
    else
        "$TMUX_BIN" list-keys | awk '{ print $2 }' | grep -q Enter && _ikea_found=1
    fi
    [ "$_ikea_found" = 1 ] && {
        log_it "><> Enter Already used"
        return 1
    }
    log_it "><> Enter is Available"
    return 0
}

consider_secondary_default() {
    # Secondary default: <prefix> Enter for non-US keyboards where \ is impractical
    # Only if @menus_trigger not defined and Enter is available
    _csd_skip=0
    if [ -f "$f_cached_tmux_options" ]; then
        grep -q @menus_trigger "$f_cached_tmux_options" && _csd_skip=1
    else
        # assume cachless state
        $TMUX_BIN show-option -gv @menus_trigger >/dev/null 2>&1 && _csd_skip=1
    fi
    [ "$_csd_skip" = 1 ] && {
        # since a @menus_trigger is defined in tmux.conf, assume user knows how
        # to configure things, and skip secondary default
        return 1
    }
    is_key_enter_available && {
        cfg_no_prefix=false # disable skip prefix for this secondary default
        echo "><> binding Enter" >/dev/stderr
        bind_plugin_key Enter
    }
}

bind_plugin_key() {
    _bpk_key="$1"
    [ -z "$_bpk_key" ] && error_msg "bind_plugin_key() - No param"
    # log_it "bind_plugin_key($_bpk_key)"

    # shellcheck disable=SC1003 # false positive: this is a literal backslash pattern, not an escape attempt
    case "$_bpk_key" in
        '\') _bpk_key='\\' ;; # needs to be escaped
        *) ;;
    esac

    bind_cmd="$cfg_main_menu"
    if $cfg_use_whiptail; then
        bind_cmd="$f_ext_dlg_trigger"
        [ "$alt_menu_handler_announced" != 1 ] && {
            alt_menu_handler_announced=1 # avoid logging it twice if secondary default is used
            log_it "Will use alternate menu handler: $cfg_alt_menu_handler"
        }
    fi
    cmd="bind-key"
    # cfg_use_notes=false
    $cfg_use_notes && {
        cmd="$cmd -N \"plugin ${plugin_name}\""
    }

    u=$(cache_unescape_special_chars "$_bpk_key")
    if $cfg_no_prefix; then
        cmd="$cmd -n"
        trigger_announce="Menus will be bound to: $u"
    else
        trigger_announce="Menus will be bound to: <prefix> $u"
    fi
    cmd="$cmd \"$_bpk_key\" run-shell $bind_cmd"

    tmux_get_option _f_main_menu_override "@menus_main_menu" "-"
    # SC2154: variable assigned dynamically by tmux_get_option using eval
    # shellcheck disable=SC2154
    [ "$_f_main_menu_override" != "-" ] && {
        log_it "Using alternate main menu: $_f_main_menu_override"
    }

    [ "$TMUX_MENUS_NO_DISPLAY" = "1" ] && {
        # used for debugging menu builds
        log_it "Due to TMUX_MENUS_NO_DISPLAY terminating before binding trigger _bpk_key"
        exit 0
    }

    [ ! -f "$f_skip_low_tmux_version_warning" ] && ! tmux_vers_check 1.8 && {
        msg="Due to tmux($current_tmux_vers) < 1.8 user options can not be processed.\n\n"
        msg="${msg}The tmux-menus plugin will be bound to its default key: $_bpk_key"
        msg="${msg} \n\nAll other options will also use their defaults.\n\n"
        msg="${msg}  tools/show_config.sh will display current settings.\n\n"
        msg="${msg}To avoid seeing this message again - do:\n"
        msg="${msg}  touch $f_skip_low_tmux_version_warning"
        display_formatted_message "$msg"
    }

    eval "$TMUX_BIN" "$cmd" || {
        error_msg "Failed to bind trigger: $_bpk_key"
    }

    log_it_minimal "$trigger_announce"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

initialize_plugin=1

f_skip_low_tmux_version_warning="$D_TM_BASE_PATH"/.skip_old_tmux_warning

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/helpers.sh

# log_it "=====   plugin_init.sh starting   ====="

# Define cfg_use_cache as soon as possible, and importantly, don't cache this
# param since it is as of yet unknown if caching is enabled.
# Once this has been set, it defines if caching should be used or not

if normalize_bool_param "@menus_use_cache" "$default_use_cache" "no-cache"; then
    cfg_use_cache=true
else
    cfg_use_cache=false
fi

if [ "$cfg_use_cache" = true ] && [ -d "$d_cache" ]; then
    # clear out potentially obsolete cache items
    safe_remove "$f_cached_tmux_options" "plugin_init.sh"
    safe_remove "$f_cached_tmux_key_binds" "plugin_init.sh" external_path_ok
    # Clear any errors from previous runs
    safe_remove "$d_cache"/error-* "plugin_init.sh"
    safe_remove "$d_cache"/cmd_output "plugin_init.sh"
    #
    # If these are removed, it can't be detected if config changed, so
    # there is no hint if cached items should be dropped or not
    #
    # "$f_cache_params"  "$f_chksum_custom"  "$f_min_display_time"
fi

#
# These will only do something during debugging, if cfg_log_file was hardcoded
# in helpers_minimal.sh or similar...
# So normally silent, and really convenient when working on the code
#
log_it
log_it
log_it

config_setup

#
# If @menus_log_file was defined, it has now taken effect
# create a blank line in the log to separate tmux sessions
#
log_it

if $cfg_use_cache; then
    #
    #  If custom inventory is used, update link to its main index
    #
    "$d_scripts"/update_custom_inventory.sh || {
        error_msg "update_custom_inventory.sh reported error: $?"
    }
else
    log_it "Will NOT use cached params and key bindings"
fi

#
# Key is not bound until cache (if allowed) has been prepared, so normally
# no menus will be triggered by the user before this
#
bind_plugin_key "$cfg_trigger_key"
consider_secondary_default

exit 0 # ensure consider_secondary_default exit code doesn't indicate error exit
