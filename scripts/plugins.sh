#!/usr/bin/env bash
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Can be used independant of tmux-menus
#

gather_plugins() {
    #
    #  List of plugins defined in config file
    #
    if [[ -z "$(command -v mapfile)" ]] || [[ -d /proc/ish ]]; then
        # iSH has very limited /dev impl, doesnt support mapfile
        #  shellcheck disable=SC2207
        defined_plugins=($(grep "set -g @plugin" "$TMUX_CONF" |
                               awk '{ print $4 }' | sed 's/"//g'))
    else
        mapfile -t defined_plugins < <(grep "set -g @plugin" "$TMUX_CONF" |
                                           awk '{ print $4 }' | sed 's/"//g')
    fi
}

list_install_status() {
    if [[ ${#defined_plugins[@]} -gt 0 ]]; then
        echo "Defined plugins:"
    else
        echo "No plugins defined"
    fi
    #
    #  Check if they are installed or not
    #
    plugin_missing=false
    for plugin in "${defined_plugins[@]}"; do
        d_name="$(echo "$plugin" | cut -d/ -f2)"
        valid_items+=("$d_name") # add item supposed to be in plugins dir
        if [[ -d "$plugins_dir/$d_name" ]]; then
            echo "    $plugin"
        else
            echo "NOT INSTALLED: $plugin"
            plugin_missing=true
        fi
    done
}

check_uninstalled() {
    if $plugin_missing; then
        echo
        if tmux_vers_check 1.9; then
            echo "You can install plugins listed as NOT INSTALLED with <prefix> I"
        else
            echo "Follow the plugins instruction for manual install, and"
            echo "save it into: $plugins_dir"
        fi
    fi
}

check_unknown_items() {
    #
    #  List all items in plugins_dir not supposed to be there
    #
    undefined_item=false
    echo
    for file in "$plugins_dir"/*; do
        item="$(echo "$file" | sed s/'plugins'/\|/ | cut -d'|' -f2 | sed s/.//)"
        if [[ ! ${valid_items[*]} =~ ${item} ]]; then
            # whatever you want to do when array doesn't contain value
            echo "Undefined item: $plugins_dir/$item"
            undefined_item=true
        fi
    done
    if $undefined_item; then
        echo
        if tmux_vers_check 1.9; then
            echo "You can remove undefined items with <prefix> M-u"
        else
            echo "Please manually remove the listed items"
        fi
        echo
    fi
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH=$(dirname "$(dirname -- "$(realpath "$0")")")

#  shellcheck source=/dev/null
. "$D_TM_BASE_PATH"/scripts/helpers.sh

_this="plugins.sh" # error prone if script name is changed :(
defined_plugins=() #  plugins mentioned in config file
valid_items=(tpm)  # additional folders expected to be in plugins folders

[[ -n "$TMUX" ]] || {
    echo "ERROR: This expects to run inside a tmux session!"
    exit 1
}

[[ "$(basename "$0")" != "$_this" ]] && {
    # mostly to ensure this file isn't accidentally sourced from a menu
    error_msg "$_this should NOT be sourced"
}

if [[ -n "$TMUX_CONF" ]]; then
    d_conf="$(dirname "$TMUX_CONF")"
    if [[ "$d_conf" = "$HOME" ]]; then
        plugins_dir="$HOME"/.tmux/plugins
    else
        plugins_dir="$d_conf"/plugins
    fi
elif [[ -n "$XDG_CONFIG_HOME" ]]; then
    plugins_dir="$(dirname "$XDG_CONFIG_HOME")/tmux/plugins"
else
    plugins_dir="$HOME/.tmux/plugins"
fi

gather_plugins
list_install_status
# exit 0

check_uninstalled
check_unknown_items

#  Busybox ps has no -x and will throw error, so send to /dev/null
#  pgrep does not provide the command line, so ignore SC2009
#  shellcheck disable=SC2009,SC2154 
if ps -x "$PPID" 2>/dev/null | grep -q tmux-menus &&
    [[ "$FORCE_WHIPTAIL_MENUS" = 1 ]]; then

    #  called using whiptail menus
    echo "Press <Enter> to clear this output"
    read -r _
else
    if [[ ! -t 0 ]]; then
        #
        #  Not from command-line, ie most likely called from the menus.
        #  Menu is already closed, so we can't check PPID or similar
        #
        echo "Press <Escape> to clear this output"
    fi
fi
