#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.0 2022-04-14
#
#   Does shellcheck on all relevant scripts in this project
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

shellcheck "$CURRENT_DIR"/menus.tmux
shellcheck "$CURRENT_DIR"/shellchecker.sh
shellcheck "$CURRENT_DIR"/scripts/*.sh
shellcheck "$CURRENT_DIR"/items/*.sh
