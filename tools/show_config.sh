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
    _si_label="$1"
    _si_value="$2"
    _si_default="$3"

    case "$(lowercase_it "$_si_default")" in
        true | yes) _si_default=true ;;
        false | no) _si_default=false ;;
        *) ;;
    esac

    # Handle special case explicit empty string default
    [ "$_si_default" = "$cfg_default_is_empty_string" ] && _si_default=""

    # Indicate if it is default or not
    if [ "$_si_value" = "$_si_default" ]; then
        _si_is_default="*"
    else
        _si_is_default=""
    fi

    printf '%-28s %-8s %s\n' "$_si_label" "$_si_is_default" "$_si_value"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/helpers.sh

tmux_get_defaults

echo "config variable              default  value"
echo "----------------------       -------  -----"
show_item @menus_trigger "$cfg_trigger_key" "$default_trigger_key"
show_item @menus_without_prefix "$cfg_no_prefix" "$default_no_prefix"
show_item @menus_use_cache "$cfg_use_cache" "$default_use_cache"
show_item @menus_display_commands "$cfg_display_cmds" "$default_display_commands"
show_item @@menus_main_menu "$cfg_main_menu" "$default_main_menu"
show_item @menus_config_file "$cfg_tmux_conf" "$default_tmux_conf"
echo
show_item @menus_log_file "$cfg_log_file" "$default_log_file"
show_item @menus_display_cmds_cols "$cfg_display_cmds_cols" "$default_display_cmds_cols"

$b_use_alt_handler || {
    printf '\n# Display-menu related config\n'
    show_item @menus_location_x "$cfg_mnu_loc_x" "$default_location_x"
    show_item @menus_location_y "$cfg_mnu_loc_y" "$default_location_y"
    show_item @menus_use_hint_overlays "$cfg_use_hint_overlays" "$default_use_hint_overlays"
    show_item @menus_show_key_hints "$cfg_show_key_hints" "$default_show_key_hints"
    show_item @menus_format_title "$cfg_format_title" "$default_format_title"
    show_item @menus_nav_next "$cfg_nav_next" "$default_nav_next"
    show_item @menus_nav_prev "$cfg_nav_prev" "$default_nav_prev"
    show_item @menus_nav_home "$cfg_nav_home" "$default_nav_home"
    tmux_vers_check 3.4 && {
        echo
        show_item @menus_border_type "$cfg_border_type" "$default_border_type"
        show_item @menus_simple_style_selected "$cfg_simple_style_selected" "$default_simple_style_selected"
        show_item @menus_simple_style "$cfg_simple_style" "$default_simple_style"
        show_item @menus_simple_style_border "$cfg_simple_style_border" "$default_simple_style_border"
    }
}

if tmux_vers_check 3.0; then
    default_use_whiptail=false
else
    default_use_whiptail=true
fi
echo
show_item "b_use_alt_handler" "$b_use_alt_handler" "$default_use_whiptail"

$b_use_alt_handler && show_item "alt_menu_handler" "$alt_menu_handler" "whiptail"
