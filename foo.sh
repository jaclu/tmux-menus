#!/bin/sh

_s4=" /data/data/com.termux/files/usr/bin/tmux -L 10194-serv2   customize-mode -Z "
sc_cmd=${_s4#"${_s4%%[![:space:]]*}"} # remove leading
echo "leadinig: [$sc_cmd]"

# remove trailing
sc_cmd=${sc_cmd%"${sc_cmd##*[![:space:]]}"}
echo "trailing: [$sc_cmd]"

# innwer ws
# shellcheck disable=SC2086 # intentional in this case
set -- $sc_cmd
sc_cmd=$*
echo "inner: [$sc_cmd]"
echo "  _s4: [$_s4]"
