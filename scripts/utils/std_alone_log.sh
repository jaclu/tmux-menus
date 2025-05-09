#!/bin/sh

sal_error() {
    echo "ERROR: std_alone_log.sh: $1" >/dev/stderr
    exit 1
}

log_msg="$1"

#  Full path to tmux-menus plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

f_plugin_params_cache="$D_TM_BASE_PATH"/cache/plugin_params

[ -f "$f_plugin_params_cache" ] && {
    # shellcheck source=/dev/null
    . "$f_plugin_params_cache" || sal_error "Failed to source: $f_plugin_params_cache"
    [ -n "$cfg_log_file" ] && {
        echo "sal: $log_msg" >>"$cfg_log_file"
        exit 0
    }
}

echo "sal [no log file]: $log_msg" >/dev/stderr
