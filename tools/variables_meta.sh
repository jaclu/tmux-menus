#!/bin/sh
#
# Shellcheck Variable & Function Reference File
#
# PURPOSE:
#   This file declares all variables (and functions - not yet) that are shared across sourced
#   files in this project. It exists solely for shellcheck validation and is never
#   executed by the actual application.
#
# USAGE:
#   In any script that sources other files, use the shellcheck directive:
#
#     # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
#     . "$D_TM_BASE_PATH"/scripts/menu_handling.sh
#
#   This tells shellcheck to use THIS file (variables_meta.sh) as the reference
#   for variable and function definitions when analyzing the sourcing statement,
#   even though the actual source statement sources menu_handling.sh.
#
# WHY:
#   This project has complex sourcing chains where variables and functions are
#   defined in sourced files but used in many different contexts. Without this
#   reference:
#   - Shellcheck would recursively parse all sourced files (slow)
#   - False positives for "variable not assigned" would be common
#   - Large sourcing chains would be re-analyzed for every file
#
#   By using a lightweight reference file, shellcheck:
#   - Validates variables instantly (cached by filesystem)
#   - Catches actual typos and undefined variables
#   - Avoids recursive parsing overhead
#
# MAINTENANCE:
#   When adding new variables or functions to sourced files, add them here:
#   - Variables: use the pattern VAR="${VAR:-}" (assigns AND uses in one statement)
#   - Functions: define as no-op, then call it (to satisfy shellcheck)
#
#   This ensures shellcheck sees them as both declared and used.
#
#  Below the dummies should be grouped per where they are originating,
#  not where they are referred
#
# NON SOURCING SCRIPTS:
#   In script that does not source anything, shellcheck can be tricked to read this
#   using the below snippet:
#
# # if false; then
#     # Shellcheck analyzes this code path but it never executes at runtime
#     . tools/variables_meta.sh
# fi
#

#===============================================================
# scripts/helpers_minimal.sh
#===============================================================

D_TM_BASE_PATH="${D_TM_BASE_PATH:-}"
TMUX_BIN="${TMUX_BIN:-tmux}"

bn_current_script="${bn_current_script:-}"
cfg_alt_menu_handler="${cfg_alt_menu_handler:-}"

# shellcheck disable=SC2031 # needed since cache.sh redefines it in a subshell
cfg_log_file="${cfg_log_file:-}"

cfg_use_cache="${cfg_use_cache:-}"
cfg_use_whiptail="${cfg_use_whiptail:-}"
current_tmux_vers="${current_tmux_vers:-}"
current_tmux_vers_i="${current_tmux_vers_i:-}"
current_tmux_vers_suffix="${current_tmux_vers_suffix:-}"
d_cache="${d_cache:-}"
d_cache_main_menu="${d_cache_main_menu:-}"
d_items="${d_items:-}"
d_safe_tmp_folder="${d_safe_tmp_folder:-}"
d_scripts="${d_scripts:-}"
d_tmp="${d_tmp:-}"
env_unmame="${env_unmame:-}"
f_cache_params="${f_cache_params:-}"
f_cached_tmux_key_binds="${f_cached_tmux_key_binds:-}"
f_ext_dlg_trigger="${f_ext_dlg_trigger:-}"
f_main_menu="${f_main_menu:-}"
f_no_cache_hint="${f_no_cache_hint:-}"
initialize_plugin="${initialize_plugin:-}"
log_file_forced="${log_file_forced:-}" # debug variable, normally not defined
plugin_name="${plugin_name:-}"
rn_current_script="${rn_current_script:-}"
t_minimal_display_time="${t_minimal_display_time:-}"
t_script_start="${t_script_start:-}"
t_time_span="${t_time_span:-}"
validate_menu_cache="${validate_menu_cache:-}"

#===============================================================
# scripts/menu_handling.sh
#===============================================================

d_odd_chars="${d_odd_chars:-}"
dh_t_start="${dh_t_start:-}" # time when menu is displayed
menu_width="${menu_width:-}"
mnu_reload_direct="${mnu_reload_direct:-}"
nav_home="${nav_home:-}"
nav_next="${nav_next:-}"
nav_prev="${nav_prev:-}"
runshell_reload_mnu="${runshell_reload_mnu:-}"
show_cmds_state="${show_cmds_state:-}" # current state for displaying cmds
skip_oversized="${skip_oversized:-}"
t_show_cmds="${t_show_cmds:-}" # time when cmds generation starts

#===============================================================
# scripts/utils/cache.sh
#===============================================================

cached_bad_tmux_versions="${cached_bad_tmux_versions:-}"
cfg_border_type="${cfg_border_type:-}"
cfg_display_cmds="${cfg_display_cmds:-}"
cfg_display_cmds_cols="${cfg_display_cmds_cols:-}"
cfg_format_title="${cfg_format_title:-}"
cfg_main_menu="${cfg_main_menu:-}"
cfg_mnu_loc_x="${cfg_mnu_loc_x:-}"
cfg_mnu_loc_y="${cfg_mnu_loc_y:-}"
cfg_nav_home="${cfg_nav_home:-}"
cfg_nav_next="${cfg_nav_next:-}"
cfg_nav_prev="${cfg_nav_prev:-}"
cfg_no_prefix="${cfg_no_prefix:-}"
cfg_show_key_hints="${cfg_show_key_hints:-}"
cfg_simple_style="${cfg_simple_style:-}"
cfg_simple_style_border="${cfg_simple_style_border:-}"
cfg_simple_style_selected="${cfg_simple_style_selected:-}"
cfg_tmux_conf="${cfg_tmux_conf:-}"
cfg_trigger_key="${cfg_trigger_key:-}"
cfg_use_hint_overlays="${cfg_use_hint_overlays:-}"
cfg_use_notes="${cfg_use_notes:-}"
f_cache_known_tmux_vers="${f_cache_known_tmux_vers:-}"
wt_pasting="${wt_pasting:-}"

#===============================================================
# scripts/utils/helpers_full.sh
#===============================================================

_idx_next="${_idx_next:-}"
_lbl="${_lbl:-}"
_lbl_next="${_lbl_next:-}"
cur_ses="${cur_ses:-}"
d_custom_items="${d_custom_items:-}"
d_help="${d_help:-}"
d_hints="${d_hints:-}"
dest_pane_idx="${dest_pane_idx:-}"
dest_ses="${dest_ses:-}"
dest_win_idx="${dest_win_idx:-}"
f_cached_tmux_options="${f_cached_tmux_options:-}"
f_chksum_custom="${f_chksum_custom:-}"
f_custom_items_index="${f_custom_items_index:-}"
f_min_display_time="${f_min_display_time:-}"

#===============================================================
# scripts/utils/tmux.sh
#===============================================================

default_border_type="${default_border_type:-}"
default_display_cmds_cols="${default_display_cmds_cols:-}"
default_display_commands="${default_display_commands:-}"
default_format_title="${default_format_title:-}"
default_location_x="${default_location_x:-}"
default_location_y="${default_location_y:-}"
default_log_file="${default_log_file:-}"
default_nav_home="${default_nav_home:-}"
default_nav_next="${default_nav_next:-}"
default_nav_prev="${default_nav_prev:-}"
default_no_prefix="${default_no_prefix:-}"
default_show_key_hints="${default_show_key_hints:-}"
default_simple_style="${default_simple_style:-}"
default_simple_style_border="${default_simple_style_border:-}"
default_simple_style_selected="${default_simple_style_selected:-}"
default_tmux_conf="${default_tmux_conf:-}"
default_trigger_key="${default_trigger_key:-}"
default_use_cache="${default_use_cache:-}"
default_use_hint_overlays="${default_use_hint_overlays:-}"

#===============================================================
# items/*.sh - Menu definitions (exported for logging/external use)
#===============================================================

menu_key="${menu_key:-}" # When Custom Menus are used
menu_min_vers="${menu_min_vers:-}"
menu_name="${menu_name:-}"
no_auto_menu_handling="${no_auto_menu_handling:-}"

#===============================================================
# env settings probed for inside app
#===============================================================

TMUX_MENUS_HANDLER="${TMUX_MENUS_HANDLER:-}"
TMUX_MENUS_LOGGING_MINIMAL="${TMUX_MENUS_LOGGING_MINIMAL:-}"
TMUX_MENUS_NO_DISPLAY="${TMUX_MENUS_NO_DISPLAY:-}"
TMUX_MENUS_PROFILING="${TMUX_MENUS_PROFILING:-}"
