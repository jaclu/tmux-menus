#!/bin/sh

# too many arguments (need at most 2) - fixed by eval

$TMUX_BIN resize-pane -Z \; run-shell '/Users/jaclu/git_repos/mine/tmux-menus/scripts/external_dialog_trigger.sh /Users/jaclu/git_repos/mine/tmux-menus/items/panes.sh'
