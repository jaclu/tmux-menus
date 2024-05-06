#!/usr/bin/env bash
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#

_this="plugins.sh" # error prone if script name is changed :(
[[ "$(basename "$0")" != "$_this" ]] && error_msg "$_this should NOT be sourced"

[[ -n "$TMUX" ]] || {
    echo "ERROR: This expects to run inside a tmux session!"
    exit 1
}

echo

#  shellcheck disable=SC2154
if [[ "$TMUX_CONF" = "$HOME/.tmux.conf" ]]; then
    plugins_dir="$HOME/.tmux/plugins"
else
    plugins_dir="$(dirname "$TMUX_CONF")/plugins"
fi

names=(tpm) # plugin manager

#
#  Generate list of plugins defined in config file
#
plugins=()
while IFS= read -r plugin; do
    plugins+=("$plugin")
done < <(grep "set -g @plugin" "$TMUX_CONF" | awk '{ print $4 }' | sed 's/"//g')

if [[ ${#plugins[@]} -gt 0 ]]; then
    echo "Defined plugins:"
else
    echo "No plugins defined"
fi

#
#  Check if they are installed or not
#
plugin_missing=false
for plugin in "${plugins[@]}"; do
    name="$(echo "$plugin" | cut -d/ -f2)"
    names+=("$name") # add item supposed to be in plugins dir
    if [[ -d "$plugins_dir/$name" ]]; then
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
    # if [[ ! " ${names[*]} " =~ " ${item} " ]]; then
    if [[ ! ${names[*]} =~ ${item} ]]; then
        # whatever you want to do when array doesn't contain value
        echo "Undefined item: $plugins_dir/$item"
        undefined_item=true
    fi
done

if $plugin_missing; then
    if [[ -d "$plugins_dir/tpm" ]]; then
        echo "You can install plugins listed as NOT INSTALLED with <prefix> I"
        echo
    fi
fi

if $undefined_item; then
    if [[ -d "$plugins_dir/tpm" ]]; then
        echo "You can remove undefined items with <prefix> M-u"
        echo
    fi
fi

[[ -t 0 ]] || {
    # not from command-line, ie most likely called from the menus
    #  shellcheck disable=SC2154
    if [[ "$FORCE_WHIPTAIL_MENUS" = 1 ]]; then
        echo "Press <Enter> to clear this output"
        read -r _
    else
        echo "Press <Escape> to clear this output"
    fi
}
