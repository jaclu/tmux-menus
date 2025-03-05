#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  tmux env is read each time this plugin init script is run, so changes
#  in tmux version or your tmux conf file will be detected and trigger
#  a cache replacement.
#
#  tpm will call this during a tmux source-file call, so this cache can
#  be trusted by the menu items to contain current tmux env variables.
#
#  One thing to be aware of - If multiple tmux instances of the same version
#  use the same folder for this plugin, this cache approach might not work
#  as intended, since the tmux env is just read once then this cache is used.
#
#  If those tmux instances do not have identical tmux-menus configuration,
#  thing will not work as intended.
#
#  Therefore each instance using tmux-menus should use a separate folder
#  for the plugin, not using soft-links to the same folder!
#

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH="$(dirname -- "$(realpath "$0")")"

#
# tell helpers.sh to replace (potentially) cached params
# if tmux version and env variables have not been changed,
# cached menus are not purged.
#
initialize_plugin=1

# shellcheck source=/dev/null  # can't read source when mixing bah & posix
. "$D_TM_BASE_PATH"/scripts/helpers.sh

if $cfg_use_cache; then
    cache_add_ok_vers "$tpt_current_vers"

    if [[ -f "$f_update_custom_inventory" ]]; then
        $f_update_custom_inventory
    else
        log_it "config file missing: $f_update_custom_inventory"
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

# teh_debug=true
# shellcheck disable=SC2086
$TMUX_BIN $cmd || {
    error_msg "Failed to bind trigger"
}

log_it "$trigger_sequence"
