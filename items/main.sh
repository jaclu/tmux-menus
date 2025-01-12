#!/bin/sh
#
#  Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Main menu, the one popping up when you hit the trigger
#

static_content() {
    rld_cmd="command-prompt -I '$cfg_tmux_conf' -p 'Source file:' \
        'run-shell \"$d_scripts/reload_conf.sh %% $reload_in_runshell\"'"

    # 12.0 M S
    #  Menu items definition
    set -- \
        1.8 M N "Navigate & Search $nav_next" nav_search.sh \
        0.0 M P "Handling Pane     $nav_next" panes.sh \
        0.0 M W "Handling Window   $nav_next" windows.sh \
        0.0 M S "Handling Sessions $nav_next" sessions.sh \
        1.8 M B "Paste buffers     $nav_next" paste_buffers.sh \
        0.0 M L "Layouts           $nav_next" layouts.sh \
        0.0 M V "Split view        $nav_next" split_view.sh \
        2.0 M M "Missing Keys      $nav_next" missing_keys.sh \
        0.0 M A "Advanced Options  $nav_next" advanced.sh \
        0.0 M E "Extras            $nav_next" extras.sh \
        0.0 S \
        1.8 E p "Plugins inventory" "plugins.sh" \
        0.0 C r "Reload configuration file" "$rld_cmd" \
        0.0 E i "public IP" public_ip.sh \
        0.0 C d 'Detach from tmux' detach-client \
        0.0 S \
        0.0 M H "Help $nav_next" "$d_help/help_summary.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Main menu"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
