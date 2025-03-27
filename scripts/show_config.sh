#!/bin/sh
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Displays current settings for plugin
#

show_item() {
    label="$1"
    value="$2"
    default="$3"

    case "$(lowercase_it "$default")" in
    true | yes) default=true ;;
    false | no) default=false ;;
    *) ;;
    esac

    [ "$value" = "$default" ] && is_default="*" || is_default=""

    printf "%-22s %-8s %s\n" "$label" "$is_default" "$value"
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH=$(dirname "$(dirname -- "$(realpath "$0")")")

#  shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

tmux_get_defaults

echo "config variable        default  value"
echo "---------------------- -------  -----"
show_item @menus_trigger "$cfg_trigger_key" "$default_trigger_key"
show_item @menus_without_prefix "$cfg_no_prefix" "$default_no_prefix"
show_item @menus_use_cache "$cfg_use_cache" "$default_use_cache"
show_item @menus_show_key_hints "$cfg_show_key_hints" "$default_show_key_hints"
show_item @menus_use_hint_overlays "$cfg_use_hint_overlays" "$default_use_hint_overlays"

# show_item cfg_log_file "$cfg_log_file" "$default_log_file"
show_item @menus_config_file "$cfg_tmux_conf" "$default_tmux_conf"
show_item @menus_location_x "$cfg_mnu_loc_x" "$default_location_x"
show_item @menus_location_y "$cfg_mnu_loc_y" "$default_location_y"

[ -n "$cfg_log_file" ] && {
    echo
    echo "@menus_log_file: $cfg_log_file"
}
