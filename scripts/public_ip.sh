#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Displays public IP
#

_this="public_ip.sh"
if [ "$(basename "$0")" != "$_this" ]; then
    echo "ERROR: $_this should NOT be sourced"
    exit 1
fi

D_TM_SCRIPTS="$(cd -- "$(dirname -- "$0")" && pwd)"

# shellcheck disable=SC1091
. "$D_TM_SCRIPTS/utils.sh"

# safety check to ensure it is defined
[ -z "$TMUX_BIN" ] && echo "ERROR: public_ip.sh - TMUX_BIN is not defined!"

echo # Extra LF to avoid cursor placed over text
echo "Public IPv4: $(curl -4 https://ifconfig.me 2>/dev/null)"
echo "Public IPv6: $(curl -6 https://ifconfig.me 2>/dev/null)"

wait_to_close_display
