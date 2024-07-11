#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
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
        current_prefix="$(tmux_error_handler show-option -g prefix | cut -d'-' -f2)"
        current_mouse_status="$(tmux_error_handler show-option -g mouse | cut -d' ' -f2)"
        if [ "$current_mouse_status" = "on" ]; then
            new_mouse_status="off"
        else
            new_mouse_status="on"
        fi
    fi

    set -- \
        2.1 C m "Toggle mouse to: $new_mouse_status" "set-option -g mouse \
        $new_mouse_status $menu_reload" \
        2.4 C p "Change prefix <$current_prefix>" "command-prompt -1 -p \
            'prefix (will take effect imeditally)' \
            'run-shell \"$d_scripts/change_prefix.sh %1 $reload_in_runshell\"'"

    menu_generate_part 2 "$@"

}

static_content() {
    menu_name="Advanced options"

    fw_span="Windows"
    tmux_vers_check 2.6 && fw_span="Sessions & $fw_span"
    fw_lbl_line2=" only visible part"
    if tmux_vers_check 3.2; then
        #  adds ignore case, and zooms the pane
        fw_lbl_line2="$fw_lbl_line2, ignores case"
        fw_flags="-Zi"
    elif tmux_vers_check 2.9; then
        #  zooms the pane
        fw_flags="-Z"
    else
        fw_flags=""
    fi
    fw_cmd="command-prompt -p 'Search for:' 'find-window $fw_flags %%'"

    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        2.7 M M "Manage clients    -->" advanced_manage_clients.sh \
        0.0 S

    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        #
        #  The tmux output down to Customize options will be displayed
        #  then disapear instantly since whiptail restarts the foreground
        #  app. Avoid this by not switching away to the fg app
        #
        set -- "$@" \
            0.0 T "Most outputs for this dialog will disapear if this is run" \
            0.0 T "with another app put into the background, since it will" \
            0.0 T "reapear as soon as this menu is closed." \
            0.0 T "Recomended workarround is to run this from a pane" \
            0.0 T "with a prompt." \
            0.0 S
    fi

    set -- "$@" \
        0.0 C b " List all key bindings" "list-keys" \
        3.1 C n " List key bindings with notes" "list-keys -N" \
        3.1 C / "<P> Describe (prefix) key" "command-prompt -k \
            -p key 'list-keys -N \"%%%\"'" \
        0.0 C "\~" "<P> Show messages" show-messages \
        0.0 C : "<P> Prompt for a command" command-prompt \
        1.7 T "-#[nodim]Search in all $fw_span" \
        1.7 C s "$fw_lbl_line2" "$fw_cmd" \
        0.0 S

    # 3.2 C C "<P> Customize options" "customize-mode -Z"

    menu_generate_part 1 "$@"

    # shellcheck disable=SC2154
    set -- \
        1.8 S \
        1.8 C x "Kill server" "confirm-before -p \
            'kill tmux server defined in($TMUX_SOURCE) ? (y/n)' kill-server" \
        0.0 S \
        0.0 M H "Help -->" "$d_items/help.sh $f_current_script"

    menu_generate_part 3 "$@"
    #
    #  Disabled until I have time to investigate
    #
    # plugin_conf_prompt="#{?@menus_config_overrides,Plugin configuration  -->,-Configuration disabled}"
    # 0.0 M P "$plugin_conf_prompt" config.sh \
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
