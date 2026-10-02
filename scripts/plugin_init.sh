#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Initiate plugin, should be run in background from .tmux file
#

#===============================================================
#
#   Main
#
#
#===============================================================

initialize_plugin=true

# Set up plugin location in tmux env
TMUX_BIN="${TMUX_BIN:-tmux}"
TMUX_MENUS_LOCATION=$(cd "${0%/*}/.." && pwd)
# export TMUX_MENUS_LOCATION
$TMUX_BIN set-environment -g TMUX_MENUS_LOCATION "$TMUX_MENUS_LOCATION"

_d_cache="$TMUX_MENUS_LOCATION"/cache
[ -d "$_d_cache" ] && {
    rm -rf "$_d_cache" || {
        echo "ERROR: tmux-menus innit, clearing previous cache: $_d_cache"
        exit 1
    }
}

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
all_helpers=1 . "$TMUX_MENUS_LOCATION"/scripts/helpers.sh

case "$1" in
    -z) safe_remove "$d_cache" "Clear cache" && echo "$d_cache cleared!" ;;
    "") ;;
    *)
        echo "$0 [-z to clear cache]"
        exit 0
        ;;
esac

# log_it "=====   plugin_init.sh starting   ====="

# Define cfg_use_cache as soon as possible, and importantly, don't cache this
# param since it is as of yet unknown if caching is enabled.
# Once this has been set, it defines if caching should be used or not

#
# These will only do something during debugging, if cfg_log_file was hardcoded
# in helpers.sh or similar...
# So normally silent, and really convenient when working on the code
#
log_it
log_it
log_it

config_setup
#
# Key is not bound until cache (if allowed) has been prepared, so normally
# no menus will be triggered by the user before this
#
log_it "cfg_trigger_key [$cfg_trigger_key]"
# select_alt_handler
set_plugin_key

# potentially will change plugin key
handle_env_variables # should have been checked set a breakpoint to verify
#
# If @menus_log_file was defined, it has now taken effect
# create a blank line in the log to separate tmux sessions
#
log_it

if ${cfg_use_cache:-false}; then
    #
    #  If custom inventory is used, update link to its main index
    #
    "$d_scripts"/update_custom_inventory.sh || {
        error_msg "update_custom_inventory.sh reported error: $?"
    }
else
    log_it "Will NOT use cached params and key bindings"
fi

exit 0 # ensure consider_secondary_default exit code doesn't indicate error exit
