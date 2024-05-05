#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Displays public IP
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/utils.sh
. "$D_TM_BASE_PATH"/scripts/utils.sh

_this="public_ip.sh" # error prone if script name is changed :(
[ "$current_script" != "$_this" ] && error_msg "$_this should NOT be sourced"

echo # Extra LF to avoid cursor placed over text
echo "Public IPv4: $(curl -4 https://ifconfig.me 2>/dev/null)"
echo "Public IPv6: $(curl -6 https://ifconfig.me 2>/dev/null)"

wait_to_close_display
