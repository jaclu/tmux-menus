#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Some code snippets I don't yet use, but might come handy at some point
#

scope_selector() {
    f_theme_scope="$d_safe_tmp_folder"/theme_scope
    [ -f "$f_theme_scope" ] || {
        # If no scope found, default to window, to cause minimal unintended propagation
        # Since this would typically be done at first run of this,
        # it's enough to capture write errors here.
        # If this work, we can do dumb writes below assuming it will be ok
        echo "w" >"$f_theme_scope" || {
            error_msg "Failed writing to: $f_theme_scope"
        }
    }
    scp_current=$(cat "$f_theme_scope")

    scp_global="global"
    scp_session="session"
    scp_window="window"
    case "$scp_current" in
        # Disable the current scope from selection with the '-' prefix making the
        # item unselectable

        s) scp_session="-$scp_session" ;;
        w) scp_window="-$scp_window" ;;
        g) scp_global="-$scp_global" ;;
        *) scp_current=w ;; # set it to a valid option
    esac
    mrd="$mnu_reload_direct"
    set -- \
        0.0 T "" \
        0.0 T "#[align=centre]Select Scope" \
        3.8 C g "$scp_global" "run-shell 'echo g > $f_theme_scope $mrd'" \
        3.8 C s "$scp_session" "run-shell 'echo s > $f_theme_scope $mrd'" \
        3.8 C w "$scp_window" "run-shell 'echo w > $f_theme_scope $mrd'"
    menu_generate_part 3 "$@"
}

if false; then
    # Shellcheck analyzes this code path but it never executes at runtime
    . tools/variables_meta.sh
fi
