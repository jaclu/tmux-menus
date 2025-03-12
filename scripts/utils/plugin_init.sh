#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Try to init the cache if allowed

D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

initialize_plugin=1

# shellcheck source=/dev/null  # can't read source when mixing bah & posix
. "$D_TM_BASE_PATH"/scripts/helpers.sh

$all_helpers_sourced || source_all_helpers "always done by menus.tmux"

# Create a LF in log_file to easier separate runs
# log_it
rm -f "$f_cached_tmux_options"
get_config_refresh


echo "D_TM_BASE_PATH [$D_TM_BASE_PATH]"

# tell helpers.sh to replace (potentially) cached params
# if tmux version and env variables have not been changed,
# cached menus are not purged.
#
# shellcheck disable=SC2034

# shellcheck source=/dev/null  # can't read source when mixing bah & posix
. "$D_TM_BASE_PATH"/scripts/helpers.sh


if $cfg_use_cache; then
    cache_add_ok_vers "$tpt_current_vers"

    if [[ -d "$d_custom_items" ]]; then
        $f_update_custom_inventory
    fi
else
    log_it "-->  cache is disabled!  <--"
fi

if $cfg_use_whiptail; then
    bind_cmd="$d_scripts/external_dialog_trigger.sh"
    log_it "alternate menu handler: $cfg_alt_menu_handler"
else
    bind_cmd="$d_items/main.sh"
fi
cmd="bind-key"
$cfg_use_notes && {
    # And why can't space be used in this note?
    cmd+=" -N plugin_${plugin_name}_trigger"
}
if $cfg_no_prefix; then
    cmd+=" -n"
    trigger_sequence="Menus bound to: $cfg_trigger_key"
else
    trigger_sequence="Menus bound to: <prefix> $cfg_trigger_key"
fi
cmd+=" $cfg_trigger_key  run-shell $bind_cmd"

[[ "$TMUX_MENUS_NO_DISPLAY" = "1" ]] && {
    # used for debugging menu builds
    log_it "Due to TMUX_MENUS_NO_DISPLAY terminating before binding trigger key"
    exit 0
}

# shellcheck disable=SC2086 # in this case we want the variable to unpack
$TMUX_BIN $cmd || {
    error_msg_safe "Failed to bind trigger: $trigger_sequence"
}

log_it "$trigger_sequence"
