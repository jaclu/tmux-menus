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

#  Run the plugin setup in the background to not slow down tpm on startup
#  On systems with "normal" performance init takes perhaps 0.5 seconds
#  On slower things like iSH or termux it might take 2-3 seconds, then the
#  long wait for tpm to complete becomes more apparent.
(
    "$D_TM_BASE_PATH"/scripts/plugin_init.sh || {
        # Report if init failed
        tmux display-message "tmux-menus - Failed to initialize"
        sleep 3
        }
) &
