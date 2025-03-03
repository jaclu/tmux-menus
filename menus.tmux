#!/bin/sh
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

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

$cfg_use_cache && {
    cache_add_ok_vers "$tmux_vers"

    if [ -f "$f_update_custom_inventory" ]; then
        $f_update_custom_inventory
    else
        log_it "config file missing: $f_update_custom_inventory"
    fi
}

if $cfg_use_whiptail; then
    cmd="$d_scripts/external_dialog_trigger.sh"
    log_it "alternate menu handler: $cfg_alt_menu_handler"
else
    cmd="$d_items/main.sh"
fi

# have to use "set --"" in order to send the selected params to tmux
set --
$cfg_use_notes && {
    set -- "$@" -N "plugin: $plugin_name trigger"
}

if $cfg_no_prefix; then
    set -- "$@" -n
    trigger_sequence="Menus bound to: $cfg_trigger_key"
else
    trigger_sequence="Menus bound to: <prefix> $cfg_trigger_key"
fi

tmux_error_handler bind-key "$@" "$cfg_trigger_key" run-shell "$cmd"
log_it "$trigger_sequence"
