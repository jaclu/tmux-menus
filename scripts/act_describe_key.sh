#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  List key note (if defined) and key binding if any
#

#===============================================================
#
#   Main
#
#===============================================================

TMUX_MENUS_LOCATION=$(cd "${0%/*}/.." && pwd)
# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
all_helpers=1 . "$TMUX_MENUS_LOCATION"/scripts/helpers.sh

if [ -n "$1" ]; then
    key="$1"
    log_it "key as param found"
else
    if tmux_vers_check 3.3; then
        tmux_error_handler_assign key command-prompt -k -p key "display -p %%%"
        # log_it "><> [$key] new tmux command-prompt is complete"
    else
        # command-prompt seems to fork, either way it returns directly as soon
        # as the prompt is presented on older tmux versions,
        # so simplest is to run this again with key as parameter
        if tmux_vers_check 2.4; then
            tmux_error_handler command-prompt -p key "run-shell '$0 \"%%%\"'"
        else
            tmux_error_handler command-prompt -p key "run-shell '$0 \"%%\"'"
        fi
        exit 0
    fi
fi

echo "key: [$key]"

if [ -n "$key" ]; then
    tmux_vers_check 3.0 && {
        if note=$($TMUX_BIN list-keys -N "$key" 2>/dev/null | cut -d' ' -f3-); then
            [ -n "$note" ] && echo "Note: [$note]"
        else
            echo "No note found for key"
        fi
    }

    $TMUX_BIN list-keys -T prefix | grep "prefix $key " 2>/dev/null || {
        echo "Key not used"
        log_it "key not used"
    }
else
    echo "No key selected"
fi

exit 0
