#!/usr/bin/env bash

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
. "$CURRENT_DIR/utils.sh"

echo

#  shellcheck disable=SC2154
if [[ "$TMUX_CONF" = "$HOME/.tmux.conf" ]]; then
    plugins_dir="$HOME/.tmux/plugins"
else
    plugins_dir="$(dirname "$TMUX_CONF")/plugins"
fi

names=(tpm)  # plugin manager

plugin_missing=false
#  shellcheck disable=SC2207
plugins=( $(grep "set -g @plugin" "$TMUX_CONF" | awk '{ print $4 }' | sed s/\"//g) )
if [[ ${#plugins[@]} -gt 0 ]]; then
    echo "Defined plugins:"
else
    echo "No plugins defined"
fi
for plugin in "${plugins[@]}" ; do
    name="$(echo "$plugin" | cut -d/ -f2)"
    names+=("$name")  # add item supposed to be in plugins dir
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
echo
for file in "$plugins_dir"/*; do
    item="$(echo "$file" | sed s/'plugins'/\|/ | cut -d'|' -f2 | sed s/.//)"
    # if [[ ! " ${names[*]} " =~ " ${item} " ]]; then
    if [[ ! ${names[*]} =~ ${item} ]]; then
        # whatever you want to do when array doesn't contain value
        echo "Undefined item: $plugins_dir/$item"
    fi
done

if $plugin_missing ; then
    if [[ -d "$plugins_dir/tpm" ]]; then
        echo
        echo "Install missing plugins with <prefix> I"
    fi
fi

echo
echo "Press <Escape> to clear this output"
