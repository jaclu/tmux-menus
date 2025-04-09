#!/usr/bin/env bash
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Can be used independent of tmux-menus
#

find_plugin_path() {
    [[ -n "$TMUX_PLUGIN_MANAGER_PATH" ]] && {
        # if TMUX_PLUGIN_MANAGER_PATH is defined and it exists, assume it to be valid
        if [[ -d "$TMUX_PLUGIN_MANAGER_PATH" ]]; then
            d_plugins="$TMUX_PLUGIN_MANAGER_PATH"
            log_it " <-- find_plugin_path() - found via TMUX_PLUGIN_MANAGER_PATH"
            return 0
        else
            msg="Env variable TMUX_PLUGIN_MANAGER_PATH defined, but it does not point"
            msg+=" to a valid path: $TMUX_PLUGIN_MANAGER_PATH"
            error_msg "$msg"
        fi
    }
    [[ -n "$XDG_CONFIG_HOME" ]] && {
        # if XDG_CONFIG_HOME is defined and pligin_name can be found, use that path
        if [[ -d "$XDG_CONFIG_HOME" ]]; then
            # check if tmux-menus is inside this file tree, if found assume it to
            # be the plugin folder
            # shellcheck disable=SC2154
            _d_this_plugin="$(find "$XDG_CONFIG_HOME" | grep "$plugin_name\$")"
            if [[ -n "$_d_this_plugin" ]]; then
                d_plugins="$(dirname "$_d_this_plugin")"
                log_it " <-- find_plugin_path() - found via XDG_CONFIG_HOME"
                return 0
            else
                msg="$XDG_CONFIG_HOME defined, but no folder ending in $plugin_name"
                msg+=" found therein"
                error_msg "$msg"
            fi
        else
            msg="$XDG_CONFIG_HOME defined, but not pointing to a folder: $XDG_CONFIG_HOME"
            error_msg "$msg"
        fi
    }
    return 1
}

gather_plugins() {
    #
    #  List of plugins defined in config file
    #
    if [[ -z "$(command -v mapfile)" ]] || [[ -d /proc/ish ]]; then
        # iSH has very limited /dev impl, doesn't support mapfile
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
        if [[ -d "$d_plugins/$d_name" ]]; then
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
            echo "save it into: $d_plugins"
        fi
    fi
}

check_unknown_items() {
    #
    #  List all items in d_plugins not supposed to be there
    #
    undefined_item=false
    echo
    for file in "$d_plugins"/*; do
        item="$(echo "$file" | sed s/'plugins'/\|/ | cut -d'|' -f2 | sed s/.//)"
        if [[ ! ${valid_items[*]} =~ ${item} ]]; then
            # whatever you want to do when array doesn't contain value
            echo "Undefined item: $d_plugins/$item"
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

defined_plugins=() #  plugins mentioned in config file
valid_items=(tpm)  # additional folders expected to be in plugins folders

# shellcheck disable=SC2154
[[ -n "$TMUX" ]] || {
    echo "ERROR: This expects to run inside a tmux session!"
    exit 1
}

find_plugin_path || {
    msg="Failed to locate plugin folder\n\n"
    msg+="Please set TMUX_PLUGIN_MANAGER_PATH in tmux conf\n\n"
    msg+="Something like:\n"
    msg+="  TMUX_PLUGIN_MANAGER_PATH=/path/to/plugins"
    error_msg "$msg"
}
# Removes a trailing slash if present - sometimes set in TMUX_PLUGIN_MANAGER_PATH...
d_plugins="${d_plugins%/}"

gather_plugins
list_install_status
check_uninstalled
check_unknown_items

#  Busybox ps has no -x and will throw error, so send to /dev/null
#  pgrep does not provide the command line, so ignore SC2009
#  shellcheck disable=SC2009,SC2154
if ps -x "$PPID" 2>/dev/null | grep -q tmux-menus && $cfg_use_whiptail; then
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
