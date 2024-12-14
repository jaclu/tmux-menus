#!/bin/sh
#
#  Copyright (c) 2024: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Sending currency symbolsx that might not always be accessible,
#  depending on keyboards or their mappings.
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
            #  doesn't work for some chars, like §
            #  This seems more resilient
            #
            # shellcheck disable=SC2308
            _check="$(expr length "$s_in")"
        fi
        ;;
    esac
    display_char "$s"
}

show_label() {
    # Some Currency symbols can't be printed in whiptail
    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        case "$1" in
        ₺ | ₴ | ₽ | ₹)
            echo "Send   ($2) - not printable in whiptail"
            ;;
        *)
            echo "Send $1 ($2)"
            ;;
        esac
    else
        echo "Send $1 ($2)"
    fi
}

static_content() {

    tmux_vers_check 2.0 || error_msg "needs tmux 2.0"

    set -- \
        0.0 M Home "Back to Main menu     $nav_home" main.sh \
        0.0 M Left "Back to Missing Keys  $nav_prev" missing_keys.sh \
        0.0 S

    # how to print?
    # ₿ (bitcoin)

    set -- "$@" \
        0.0 E b "$(show_label ฿ baht)" "$f_current_script ฿" \
        0.0 E c "$(show_label ¢ Cent)" "$f_current_script ¢" \
        0.0 E e "$(show_label € euro)" "$f_current_script €" \
        0.0 E h "$(show_label ₴ hryvnia)" "$f_current_script ₴" \
        0.0 E l "$(show_label ₺ lira)" "$f_current_script ₺" \
        0.0 E p "$(show_label £ pound)" "$f_current_script £" \
        0.0 E i "$(show_label ៛ riel)" "$f_current_script ៛" \
        0.0 E r "$(show_label ₽ rubel)" "$f_current_script ₽" \
        0.0 E R "$(show_label ₹ rupee)" "$f_current_script ₹" \
        0.0 E s "$(show_label ₪ shekel)" "$f_current_script ₪" \
        0.0 E w "$(show_label ₩ won)" "$f_current_script ₩" \
        0.0 E y "$(show_label ¥ yen/yuan)" "$f_current_script ¥" \
        0.0 E z "$(show_label zł zloty)" "$f_current_script zł" \
        0.0 S \
        0.0 M H "Help $nav_next" "$d_items/help_currencies.sh $f_current_script"

    menu_generate_part 1 "$@"

}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Currency symbols"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

tmux_vers_check 2.0 || error_msg "$(relative_path "$f_current_script") needs tmux 2.0"

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
        tmux_error_handler set-option -gqu "$wt_pasting"
    }
fi

# shellcheck source=scripts/dialog_handling.sh
. "$d_scripts"/dialog_handling.sh
