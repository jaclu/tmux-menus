#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Advanced options
#

dynamic_content() {
    # Things that change dependent on various states

    #
    #  Gather some info in order to be able to show states
    #
    if tmux_vers_check 2.1; then
        current_prefix="$(tmux_error_handler show-options -gv prefix)"
        current_mouse_status="$(tmux_error_handler show-options -gv mouse)"
        if [ "$current_mouse_status" = "on" ]; then
            new_mouse_status="off"
        else
            new_mouse_status="on"
        fi
    fi

    set -- \
        2.1 C M "Toggle mouse to: $new_mouse_status" "set-option -g mouse \
        $new_mouse_status $menu_reload" \
        2.4 C p "Change prefix (C-$current_prefix)" "command-prompt -1 -p \
            'prefix (will take effect imeditally)' \
            'run-shell \"$d_scripts/change_prefix.sh %1 $reload_in_runshell\"'" \
        0.0 S

    menu_generate_part 2 "$@"
}

static_content() {
    menu_segment=1
    $cfg_use_hint_overlays && ! $cfg_use_whiptail && {
        hint="\& $d_hints/choose-client.sh skip-oversized"
    }

    # 2.7 M M "Manage clients    $nav_next" advanced_manage_clients.sh \
    set -- \
        0.0 M Left "Back to Main menu $nav_home" main.sh \
        0.0 S

    menu_generate_part "$menu_segment" "$@"
    menu_segment=$((menu_segment + 2)) # increment past dynamic segment

    set --

    if $cfg_use_whiptail; then
        #
        #  The tmux output down to Customize options will be displayed
        #  then disappear instantly since whiptail restarts the foreground
        #  app. Avoid this by not switching away to the fg app
        #
        set -- "$@" \
            0.0 T "Most outputs for this dialog will disappear if this is run" \
            0.0 T "with another app put into the background, since it will" \
            0.0 T "reapear as soon as this menu is closed." \
            0.0 T "Recommended workaround is to run this from a pane" \
            0.0 T "with a prompt." \
            0.0 S
    fi

    set -- "$@" \
        3.1 C n "Key bindings with notes" "list-keys -N" \
        0.0 C a "All key bindings" "list-keys" \
        3.1 C k "Describe (prefix) key" "command-prompt -k \
            -p key 'list-keys -N \"%1\" ; list-keys -T prefix \"%1\"'" \
        0.0 C m "Tmux messages" 'show-messages' \
        1.9 C t "Tmux terminal bindings" 'show-messages -T' \
        0.0 C : "Enter a tmux command" command-prompt \
        0.0 C s "Toggle status line" "set status $menu_reload"

    menu_generate_part "$menu_segment" "$@"
    menu_segment=$((menu_segment + 1))

    # shellcheck disable=SC2154
    set -- \
        1.8 S \
        2.7 E c "Disconnect clients" \
        "$TMUX_BIN choose-client -Z $hint"

    menu_generate_part "$menu_segment" "$@"
    menu_segment=$((menu_segment + 1))

    $cfg_use_hint_overlays && $cfg_show_key_hints && tmux_vers_check 2.7 && {
	    # Only generate this segment if any content will be displayed
	    # i.e. tmux >= 2.7
        set -- \
            2.7 M K "Key hints - Disconnect $nav_next" \
            "$d_hints/choose-client.sh $f_current_script"

        menu_generate_part "$menu_segment" "$@"
        menu_segment=$((menu_segment + 1))
    }
    # shellcheck disable=SC2154
    set -- \
        1.8 C x "Kill server" "confirm-before -p \
            'kill tmux server defined in($TMUX_SOURCE) ? (y/n)' kill-server"

    menu_generate_part "$menu_segment" "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Advanced options"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
