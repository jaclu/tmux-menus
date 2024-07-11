#!/usr/bin/env bash
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Can be used independant of tmux-menus
#

_this="plugins.sh" # error prone if script name is changed :(
[[ "$(basename "$0")" != "$_this" ]] && {
    # mostly to ensure this file isn't accidentally sourced from a menu
    error_msg "$_this should NOT be sourced"
}

[[ -n "$TMUX" ]] || {
    echo "ERROR: This expects to run inside a tmux session!"
    exit 1
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

defined_plugins=() #  plugins mentioned in config file
valid_items=(tpm)  # additional folders expected to be in plugins folders
d_tpm="$plugins_dir"/tpm

#
#  List of plugins defined in config file
#
if [[ -d /proc/ish ]]; then
    # iSH has very limited /dev impl, doesnt support mapfile
    #  shellcheck disable=SC2207
    defined_plugins=($(grep "set -g @plugin" "$TMUX_CONF" |
        awk '{ print $4 }' | sed 's/"//g'))
else
    mapfile -t defined_plugins < <(grep "set -g @plugin" "$TMUX_CONF" |
        awk '{ print $4 }' | sed 's/"//g')
fi

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

if $plugin_missing; then
    echo
    if [[ -d "$d_tpm" ]]; then
        echo "You can install plugins listed as NOT INSTALLED with <prefix> I"
    else
        echo "Follow the plugins instruction for manual install, and"
        echo "save it into: $plugins_dir"
    fi
fi

if $undefined_item; then
    echo
    if [[ -d "$d_tpm" ]]; then
        echo "You can remove undefined items with <prefix> M-u"
    else
        echo "Please manually remove the listed items"
    fi
fi
echo

#  pgrep does not provide the command line, so ignore SC2009
#  shellcheck disable=SC2009,SC2154
if ps -x "$PPID" | grep -q tmux-menus &&
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
