#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Displays public IP
#

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/helpers.sh

_this="public_ip.sh" # error prone if script name is changed :(
[ "$bn_current_script" != "$_this" ] && error_msg "$_this should NOT be sourced"

echo # Extra LF to avoid cursor placed over text
echo "Public IPv4: $(curl -4 https://ifconfig.me 2>/dev/null)"
echo "Public IPv6: $(curl -6 https://ifconfig.me 2>/dev/null)"

wait_to_close_display
