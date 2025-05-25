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
    empty) default="" ;;
    *) ;;
    esac

    [ "$value" = "$default" ] && is_default="*" || is_default=""

    printf "%-28s %-8s %s\n" "$label" "$is_default" "$value"
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

echo "config variable              default  value"
echo "----------------------       -------  -----"
show_item @menus_trigger "$cfg_trigger_key" "$default_trigger_key"
show_item @menus_without_prefix "$cfg_no_prefix" "$default_no_prefix"
show_item @menus_use_cache "$cfg_use_cache" "$default_use_cache"
show_item @menus_use_hint_overlays "$cfg_use_hint_overlays" "$default_use_hint_overlays"
show_item @menus_show_key_hints "$cfg_show_key_hints" "$default_show_key_hints"

show_item @menus_log_file "$cfg_log_file" "$default_log_file"
show_item @menus_display_commands "$cfg_display_cmds" "$default_display_commands"
show_item @menus_display_cmds_cols "$cfg_display_cmds_cols" "$default_display_cmds_cols"
show_item @menus_format_title "$cfg_format_title" "$default_format_title"
tmux_vers_check 3.4 && {
    show_item @menus_border_type "$cfg_border_type" "$default_border_type"
    show_item @menus_simple_style_selected "$cfg_simple_style_selected" "$default_simple_style_selected"
    show_item @menus_simple_style "$cfg_simple_style" "$default_simple_style"
    show_item @menus_simple_style_border "$cfg_simple_style_border" "$default_simple_style_border"
}
show_item @menus_nav_next "$cfg_nav_next" "$default_nav_next"
show_item @menus_nav_prev "$cfg_nav_prev" "$default_nav_prev"
show_item @menus_nav_home "$cfg_nav_home" "$default_nav_home"
show_item @menus_config_file "$cfg_tmux_conf" "$default_tmux_conf"
show_item @menus_location_x "$cfg_mnu_loc_x" "$default_location_x"
show_item @menus_location_y "$cfg_mnu_loc_y" "$default_location_y"

[ -n "$cfg_log_file" ] && {
    echo
    echo "@menus_log_file: $cfg_log_file"
}
