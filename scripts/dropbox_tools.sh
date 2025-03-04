#!/bin/sh
# Always sourced file - Fake bangpath to help editors
#
#   Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Common tools for handling dropbox
#
is_dropbox_running() {
    #
    #  Convert to boolean status from the dropox (python?) status logic
    #  where 1 means running and 0 means not running
    #
    dropbox running && return 1
    if [ "$(dropbox status)" = "Syncing..." ]; then
        #  status is only this whilst terminating, during normal operations
        #  it also mentions what file (-s) is being synced.
        #  So this is a sure sign dropbox is about to shut down,
        #  so can be labeled asnot running
        return 1
    else
        # is running
        return 0
    fi
}
