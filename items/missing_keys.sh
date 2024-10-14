#!/bin/sh
#
#  Copyright (c) 2023-2024: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Sending keys that might not always be accessible, depending on
#  keyboards or their mappings.
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
    [ -z "$c" ] && error_msg "display_char() - no param"
    if [ "$FORCE_WHIPTAIL_MENUS" != 1 ]; then
        tmux_error_handler send-keys "$c"
    else
        normalize_bool_param "$wt_pasting" false &&
            pending_paste=true || pending_paste=false

        if $pending_paste; then
            #  prefix with pending paste buffer
            c="$(tmux_error_handler show-buffer)$c"
        else
            tmux_error_handler set-option -g "$wt_pasting" 'yes'
        fi

        log_it "setting buffer to '$c'"
        tmux_error_handler set-buffer "$c"
    fi
}

#
#  Function to handle a character, mainly used when script has a command
#  line parameter
#
handle_char() {
    s_in="$1"
    [ -z "$s_in" ] && error_msg "handle_char() - no param"

    case "$s_in" in
    0x*)
        # handle it as a hex code
        # shellcheck disable=SC2059
        s="$(printf "\\$(printf "%o" "0x${s_in#0x}")")"
        ;;
    *)
        s="$s_in"
        if [ "$(uname)" = "Darwin" ]; then
            _check="${#s_in}"
        else
            #
            #  On Linux, it seems checking str length the normal way
            #  doesnt work for some chars, like §
            #  This seems more resiliant
            #
            # shellcheck disable=SC2308
            _check="$(expr length "$s_in")"
        fi
        if [ "$_check" -gt 1 ]; then
            error_msg "param can only be single char! [$s]"
        fi
        ;;
    esac
    display_char "$s"
}

static_content() {
    #
    #  It doesnt seem possible to reliably display an actual backtick in menus...
    #  on some platforms it works, on others it breaks this menu
    #
    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 M C    "Currencies" currencies.sh \
        0.0 S \
        0.0 E e " Send ESC" "$f_current_script  0x1b" \
        0.0 E b " Send   (back-tick)" "$f_current_script  0x60" \
        0.0 E t " Send ~ (tilde)" "$f_current_script  0x7e" \
        0.0 E a " Send @ (at)" "$f_current_script @" \
        0.0 E p " Send § (paragraph)" "$f_current_script §" \
        0.0 E h " Send # (hash)" "$f_current_script 0x23" \
        0.0 S \
        0.0 M H "Help -->" "$d_items/help_missing_keys.sh $f_current_script"

    menu_generate_part 1 "$@"

}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

tmux_vers_check 2.0 || error_msg "$(relative_path "$f_current_script") needs tmux 2.0"

menu_name="Missing Keys"
wt_pasting="@menus_wt_paste_in_progress"

if [ -n "$1" ]; then
    handle_char "$1"
else
    [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && {
        #
        #  As long as this menu is restarted with a char param
        #  it is added  to the paste buffer, as soon as it is called
        #  without a param this buffer is reset
        #
        log_it "clearing pending paste buffer indicator"
        $TMUX_BIN set-option -gqu "$wt_pasting"
    }
fi

# shellcheck source=scripts/dialog_handling.sh
. "$d_scripts"/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
