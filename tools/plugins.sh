#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Can be used independent of tmux-menus
#  First checks TMUX_PLUGIN_MANAGER_PATH - typically set by tpm
#  Then checks XDG_CONFIG_HOME If defined and a folder named tmux-menus is found
#  inside this hierarchy, assume this to be the relevant plugin-path
#

extract_defined_plugins() {
    #
    # List of plugins defined in config file
    #
    [ -z "$cfg_tmux_conf" ] && {
        error_msg "tmux.conf not defined, can be set using @menus_config_file"
        return 1
    }

    defined_plugins=""
    while IFS= read -r line; do
        # shellcheck disable=SC2086 # line needs to be read word by word
        set -- $line
        plugin=$4
        plugin=${plugin%\"}
        plugin=${plugin#\"}
        plugin=${plugin%\'}
        plugin=${plugin#\'}
        [ -n "$plugin" ] && defined_plugins="$defined_plugins $plugin"
    done <<EOF
$(grep "set -g @plugin" "$cfg_tmux_conf")
EOF

    defined_plugins=${defined_plugins# }
}

find_plugin_path() {
    if [ -n "$TMUX_PLUGIN_MANAGER_PATH" ]; then
        # if TMUX_PLUGIN_MANAGER_PATH is defined and it exists, assume it to be valid
        if [ -d "$TMUX_PLUGIN_MANAGER_PATH" ]; then

            # log_it " <-- find_plugin_path() - found via TMUX_PLUGIN_MANAGER_PATH"
            d_plugins="$TMUX_PLUGIN_MANAGER_PATH"
            d_plugins="${d_plugins%/}" # Removes a trailing slash if present
            return 0
        else
            msg="Env variable TMUX_PLUGIN_MANAGER_PATH defined, but it does not point"
            msg="$msg to a valid path: $TMUX_PLUGIN_MANAGER_PATH"
            error_msg "$msg"
        fi
    else
        # msg="Failed to locate plugin folder\n\n"
        msg="Please set TMUX_PLUGIN_MANAGER_PATH in tmux conf (usually done by tpm)\n\n"
        msg="${msg}Something like:\n"
        msg="$msg  set-environment -g TMUX_PLUGIN_MANAGER_PATH \"/some/other/path/\""
        error_msg "$msg"
    fi
}

list_install_status() {
    if [ -n "$defined_plugins" ]; then
        echo "Defined plugins:"
    else
        echo "No plugins defined"
        return
    fi

    plugin_missing=false
    valid_items="tpm"

    for plugin in $defined_plugins; do
        d_name=$(printf '%s\n' "$plugin" | cut -d/ -f2)
        valid_items="$valid_items $d_name"
        if [ -d "$d_plugins/$d_name" ]; then
            echo "    $plugin"
        else
            echo "NOT INSTALLED: $plugin"
            plugin_missing=true
        fi
    done
}

check_unknown_items() {
    #
    # List all items in d_plugins not supposed to be there
    #
    undefined_item=false

    for file in "$d_plugins"/*; do
        # Strip leading path
        item=$(basename "$file")

        # Check if item is in valid_items (space-separated)
        found=false
        for valid in $valid_items; do
            [ "$item" = "$valid" ] && found=true && break
        done

        if [ "$found" = false ]; then
            [ "$undefined_item" = false ] && echo " "  # spacer before 1st entry
            echo "Undefined item: $d_plugins/$item"
            undefined_item=true
        fi
    done
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH=$(dirname "$(dirname -- "$(realpath "$0")")")

#  shellcheck source=/dev/null
. "$D_TM_BASE_PATH"/scripts/helpers.sh

tmux_vers_check 1.8 || {
    # shellcheck disable=SC2154 # defined in helpers_minimal.sh
    error_msg "$rn_current_script can't be used before tmux 1.8" 1
}

# defined_plugins=() #  plugins mentioned in config file
# valid_items=(tpm)  # additional folders expected to be in plugins folders

[ -n "$TMUX" ] || {
    echo "ERROR: This expects to run inside a tmux session!"
    exit 1
}

extract_defined_plugins
find_plugin_path

echo
echo "Extract defined plugins from: $cfg_tmux_conf"
echo "Plugin folder detected:       $d_plugins"
echo " "

list_install_status
check_unknown_items

if $plugin_missing || $undefined_item; then
    echo " " # spacers
    echo " "
fi

if $plugin_missing; then
    if tmux_vers_check 1.9; then
        echo "You can install plugins listed as NOT INSTALLED with <prefix> I"
    else
        echo "Follow the plugins instruction for manual install, and"
        echo "save it into: $d_plugins"
        echo " "
    fi
fi

if $undefined_item; then
    if tmux_vers_check 1.9; then
        echo "You can remove undefined items with <prefix> M-u"
    else
        echo "Please manually remove the listed items"
    fi
fi

wait_to_close_display
