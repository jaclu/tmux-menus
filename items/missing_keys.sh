#!/bin/sh
#  shellcheck disable=SC2034,SC2154
#
#  Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Sending keys that might not always be accessible, depending on
#  keyboards or their mappings.
#
#  Especially when using tablets with keyboards, the number row might
#  be mapped to function keys, thus blocking several keys.
#  For some, me include. It is often quicker to use a menu to generate
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
        $TMUX_BIN send-keys "$c"
    else
        log_it "setting buffer to '$c'"
        if tmux_vers_compare 3.2; then
            #
            #  Also make the buffers content available for the normal
            #  paste method
            #
            $TMUX_BIN set-buffer -awb missing_keys "$c"
        else
            $TMUX_BIN set-buffer -ab missing_keys "$c"
        fi
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

dynamic_content() {
    #
    #  In this case this is just used to process any param - key to send
    #  by using the dynamic_content hook, no need to do includes in order
    #  to get access to log_it, $FORCE_WHIPTAIL_MENUS and $TMUX_BIN
    #
    if [ -n "$menu_param" ]; then
        handle_char "$menu_param"
    else
        if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
            log_it "clearing buffer missing_keys"
            $TMUX_BIN delete-buffer -b missing_keys
        fi
    fi
}

static_content() {
    menu_name="Missing Keys"
    req_win_width=35
    req_win_height=19

    tmux_vers_compare 2.0 || error_msg "needs tmux 2.0"
    
    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 S

    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        set -- "$@" \
            0.0 T "When using whiptail it is not possible to paste" \
            0.0 T "directly into the pane." \
            0.0 T "Instead a tmux buffer is used." \
            0.0 T "Once you have selected one or more keys to use" \
            0.0 T "Cancel this menu. Once back in your pane," \
            3.2 T "paste the key(-s). If normal paste doesn't" \
            3.2 T "work, you can instead" \
            0.0 T "use $()<prefix> ]$() to paste the key(-s)." \
            0.0 S
    else
        set -- "$@" \
            0.0 T "Use this to send keys that" \
            0.0 T "might not be available" \
            0.0 T " "
    fi

    set -- "$@" \
        0.0 E e " Send ESC" "$current_script  0x1b" \
        0.0 E t " Send ~ (tilde)" "$current_script  0x7e" \
        0.0 E b " Send $() (back-tick)" "$current_script  0x60" \
        0.0 S \
        0.0 E p " Send § (paragraph)" "$current_script §" \
        0.0 E a " Send @ (at)" "$current_script @" \
        0.0 E E " Send € (Euro sign)" "$current_script €" \
        0.0 E y " Send ¥ (Yen and yuan sign)" "$current_script ¥" \
        0.0 E P " Send £ (Pound sign)" "$current_script £" \
        0.0 E c " Send ¢ (Cent sign)" "$current_script ¢" \
        0.0 S \
        0.0 M H "Help -->" "$D_TM_ITEMS/help.sh $current_script"

    menu_generate_part 1 "$@"

}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH=$(dirname "$(dirname -- "$(readlink -f -- "$0")")")

menu_param="$1"

#  Generate and display the menu
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
