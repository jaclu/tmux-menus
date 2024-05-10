#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
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
#  use the same folder for this plugin, this cache aproach might not work
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

D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$0")")"

# shellcheck source=scripts/utils.sh
. "$D_TM_BASE_PATH"/scripts/utils.sh

#
#  By printing a NL and date, its easier to keep separate runs apart
#
log_it
log_it "$(date)"
tmux_vers_compare 3.0 || log_it "tmux < 3.0 FORCE_WHIPTAIL_MENUS enabled"

cache_validation

params=""
# -N params cant have spaces in this plugin for reasons...
$cfg_use_notes && params="-N plugin:$plugin_name"

if $cfg_no_prefix; then
    params="$params -n"
    log_it "Menus bound to: $cfg_trigger_key"
else
    log_it "Menus bound to: <prefix> $cfg_trigger_key"
fi
if tmux_vers_compare 3.0 && [ "$FORCE_WHIPTAIL_MENUS" != "1" ]; then
    cmd="$d_items/main.sh"
else
    if [ -z "$(command -v whiptail)" ]; then
        error_msg "whiptail is not installed!" 1
    fi
    cmd="$d_scripts/do_whiptail.sh"
fi

if [ -n "$params" ]; then
    # works sans -N spaces
    $TMUX_BIN bind-key "$params" "$cfg_trigger_key" run-shell "$cmd"
else
    $TMUX_BIN bind-key "$cfg_trigger_key" run-shell "$cmd"
fi
