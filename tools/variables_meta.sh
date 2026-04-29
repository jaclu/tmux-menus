#!/bin/sh
#
# Shellcheck Variable & Function Reference File
#
# PURPOSE:
#   This file declares all variables and functions that are shared across sourced
#   files in this project. It exists solely for shellcheck validation and is never
#   executed by the actual application.
#
# USAGE:
#   In any script that sources other files, use the shellcheck directive:
#
#     # shellcheck source=tools/variables_meta.sh
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

#===============================================================
# scripts/helpers_minimal.sh
#===============================================================

cfg_main_menu="${cfg_main_menu:-}"
cfg_use_whiptail="${cfg_use_whiptail:-}"

#===============================================================
# scripts/menu_handling.sh
#===============================================================

d_odd_chars="${d_odd_chars:-}"
nav_next="${nav_next:-}"
nav_prev="${nav_prev:-}"

menu_generate_part() { :; }
menu_generate_part "$@"

display_commands_toggle() { :; }
display_commands_toggle "$@"

do_menu_handling() { :; }
do_menu_handling "$@"

#===============================================================
# scripts/utils/tmux.sh
#===============================================================

nav_home="${nav_home:-}"
cfg_display_cmds="${cfg_display_cmds:-}"
wt_pasting="${wt_pasting:-}"

tmux_error_handler() { :; }
tmux_error_handler "$@"

#===============================================================
# scripts/utils/helpers_full.sh
#===============================================================

d_help="${d_help:-}"

#===============================================================
# items/*.sh - Menu definitions (exported for logging/external use)
#===============================================================

menu_name="${menu_name:-}"
no_auto_menu_handling="${no_auto_menu_handling:-}"
menu_min_vers="${menu_min_vers:-}"
