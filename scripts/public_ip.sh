#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Displays public IP
#

echo # Extra LF to avoid cursor placed over text
echo "Public IP: $(curl https://ifconfig.me 2>/dev/null)"

wait_to_close_display
