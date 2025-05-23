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
    c="$1"
    # log_it "display_char($c)"
    [ -z "$c" ] && error_msg_safe "display_char() - no param"

    if $cfg_use_whiptail; then
        #
        #  Normally the char is just sent into the current pane
        #  If whiptail is used, this can't be done, since whatever was
        #  running might have been suspended. Instead selected chars are saved
        #  into a buffer, that can later be pasted.
        #
        if normalize_bool_param "$wt_pasting" false no_cache; then
            tmux_error_handler_assign b show-buffer
            # SC2154: variable assigned dynamically by tmux_error_handler_assign
            #         using eval in display_menu()
            # shellcheck disable=SC2154
            c="$b$c"
        else
            # hint that the current selection should be appended to
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
    [ -z "$s_in" ] && error_msg "handle_char() - no param"
    # log_it "handle_char($s_in)"

    case "$s_in" in
    0x*)
        # handle it as a hex code

        s_in="0xC3"

        # Strip the '0x' and convert hex to raw byte using `printf`
        hex="${s_in#0x}"

        # Safely print the byte without using variable in format string
        # SC2059-safe, since format is a literal and argument is a variable
        s=$(printf "%b" "$(printf '\\%03o' "0x$hex")")

        # s="$(printf "\\$(printf "%o" "0x${s_in#0x}")")"
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

. "$D_TM_BASE_PATH"/scripts/helpers.sh

if [ -n "$1" ]; then
    handle_char "$1"
else
    error_msg "$0 - no param"
fi
