#!/bin/sh
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Since there is a limitation of only two levels of quoting when
#   using scripts/dialog_handling.sh this intermittent script is used to avoid
#   this limit
# ok 1.8

param_check() {
    item_type="$1"

    case "$item_type" in
    "w" | "p") : ;; # Valid first parameter
    *)
        error_msg "$rn_current_script First param must be w or p - was: [$item_type]"
        ;;
    esac

    action="$2"

    case "$action" in
    "m") ;; # No further checking needed
    "l")
        if [ "$item_type" = "p" ]; then
            error_msg "$rn_current_script - Panes can't be linked!"
        fi
        ;;
    *)
        set -- "$rn_current_script 2nd param must be l or m" \
            "Indicating link or move action - was: $action"
        error_msg "$*"
        ;;
    esac
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

log_it "><> ==> $rn_current_script params: $*"

tmux_vers_check 1.8 || {
    error_msg "$rn_current_script - needs tmux 1.8"
}

param_check "$1" "$2"

# log_it "><> $rn_current_script params: $* - whiptail: $cfg_use_whiptail"

if $cfg_use_hint_overlays && ! $cfg_use_whiptail; then
    "$d_hints"/choose-tree.sh skip-oversized &
fi

if tmux_vers_check 2.7; then
    flags="-GwZ"
else
    flags="-sw"
fi
case "$item_type" in
p) template="$d_scripts/relocate_pane.sh" ;;
w) template="$d_scripts/relocate_window.sh $action" ;;
*)
    # param_check should have flagged this issue already, but it seems odd
    # to just let an error pass through without aborting if it ever happened
    error_msg "$rn_current_script: param 1 must be p or w"
    ;;
esac

tmux_error_handler choose-tree "$flags" "run-shell '$template %%'"
