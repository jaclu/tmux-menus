#!/bin/sh
#
#  Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Running whiptail from a tmux shortcut requires a rather different
#  aproach. First of all whiptail cant be run via run-shell, since that
#  is a non-interactive environment. One trick that works is to use
#  send-keys, and that way trigger the dialog in the currently active
#  pane. To prevent this from messing with running apps in the pane,
#  first a C-z is done to push the (potential) active thing into the
#  background. Then once the menu session is done,
#  a fg is called, to restore the screen if there was something running.
#  Slight drawback is that this will generate "fg: no current job"
#  output, if the current pane didn't have anything running.
#  This is harmless, but does look a bit annoying.
#
#  I have experimented both with "pstree -p $$" and "jobs", but have not
#  been able to come up with a way to render the required sequence with
#  send-keys, without making a mess of things, jobs cant be run from a
#  script, it needs to be run as a command line sequence but getting
#  send-keys to generate the intended sequence seems to be beyond me
#

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$SCRIPT_DIR")/items"

#  shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

# safety check to ensure it is defined
[ -z "$TMUX_BIN" ] && echo "ERROR: do_whiptail.sh - TMUX_BIN is not defined!"

#
#  This is run from the tmux env, so FORCE_WHIPTAIL_MENUS can not be
#  forced on here, or I guess it could, but it would not modify the env
#  where the menu is run
#

#  shellcheck disable=SC2154
"$TMUX_BIN" send-keys C-z "$ITEMS_DIR/main.sh ; fg" Enter

#"$TMUX_BIN" send-keys C-z $ITEMS_DIR/main.sh ' [ -n "$(jobs)" ] && fg ' Enter
