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
    [ -z "$c" ] && error_msg "display_char() - no param"

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

handle_char() {
    #  If needed convert hex chars into printable format
    s_in="$1"
    [ -z "$s_in" ] && error_msg "handle_char() - no param"
    # log_it "handle_char($s_in)"

    case "$s_in" in
    0x*)
        # Convert hex → decimal → octal escape → character (POSIX-compliant)
        s=$(printf '%b' "$(printf '\\%03o' "$(printf '%d' "$s_in")")")
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
