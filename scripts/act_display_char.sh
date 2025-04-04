#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Simulating a key-press sending one key
#
#  Especially when using tablets with keyboards, the number row might
#  be mapped to function keys, thus blocking several keys.
#  For some, me included. It is often quicker to use a menu to generate
#  missing keys, vs fiddling with cut and paste from some other source
#  for such keys.
#

#  Function to display a character, considering Whiptail limitations
display_char() {
    #
    #  Normally the char is just sent into the current buffer
    #  If whiptail is used, this can't be done, since whatever was
    #  running was suspended. Instead selected chars are saved into a
    #  buffer, that can later be pasted.
    #
    c="$1"
    # log_it "display_char($c)"
    [ -z "$c" ] && error_msg_safe "display_char() - no param"
    if $cfg_use_whiptail; then
        if normalize_bool_param "$wt_pasting" false no_cache; then
            #     pending_paste=true
            # else
            #     pending_paste=false
            # fi

            # if $pending_paste; then
            #  prefix with pending paste buffer
            tmux_error_handler_assign b show-buffer
            # shellcheck disable=SC2154
            c="$b$c"
        else
            tmux_error_handler set-option -g "$wt_pasting" 'yes'
        fi

        tmux_error_handler set-buffer "$c"
    else
        tmux_error_handler send-keys "$c"
    fi
}

#
#  Function to handle a character, mainly used when script has a command
#  line parameter
#
handle_char() {
    s_in="$1"
    [ -z "$s_in" ] && error_msg_safe "handle_char() - no param"
    # log_it "handle_char($s_in)"
    $all_helpers_sourced || source_all_helpers "act_display_char:handle_char()"

    case "$s_in" in
    0x*)
        # handle it as a hex code
        # shellcheck disable=SC2059
        s="$(printf "\\$(printf "%o" "0x${s_in#0x}")")"
        ;;
    *) s="$s_in" ;;
    esac
    display_char "$s"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers_minimal.sh
. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

if [ -n "$1" ]; then
    handle_char "$1"
else
    error_msg_safe "$0 - no param"
fi
