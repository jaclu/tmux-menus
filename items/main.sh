#!/bin/sh
#  shellcheck disable=SC2034
#
#  Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Main menu, the one popping up when you hit the trigger
#

generate_content() {
    #  Menu items definition
    set -- \
        0.0 M P "Handling Pane     -->" panes.sh \
        0.0 M W "Handling Window   -->" windows.sh \
        2.0 M S "Handling Sessions -->" sessions.sh \
        0.0 M L "Layouts           -->" layouts.sh \
        0.0 M V "Split view        -->" split_view.sh \
        0.0 M M "Missing Keys      -->" missing_keys.sh \
        0.0 M E "Extras            -->" extras.sh \
        0.0 M A "Advanced Options  -->" advanced.sh \
        0.0 S \
        0.0 C l "toggle status Line" "set status" \
        0.0 E i "public IP" public_ip.sh \
        0.0 E p "Plugins inventory" plugins.sh \
        0.0 S \
        0.0 C n "Navigate & select ses/win/pane" "choose-tree"

    if tmux_vers_compare 2.7; then
        #  adds ignore case
        #  shellcheck disable=SC2145
        set -- "$@ -Z"
    fi

    set -- "$@" \
        0.0 T "-#[nodim]Search in all sessions & windows" \
        0.0 C s "only visible part"

    if tmux_vers_compare 3.2; then
        #  adds ignore case
        # shellcheck disable=SC2145
        set -- "$@, ignores case"
    fi

    set -- "$@" \
        "command-prompt -p 'Search for:' 'find-window"

    if tmux_vers_compare 3.2; then
        #  adds ignore case, and zooms the pane
        # shellcheck disable=SC2145
        set -- "$@ -Zi"
    fi

    #  shellcheck disable=SC2154
    set -- "$@" \
        0.0 S \
        0.0 E r 'Reload configuration file' reload_conf.sh \
        0.0 S \
        0.0 C d '<P> Detach from tmux' detach-client \
        0.0 S \
        0.0 M H 'Help -->' "help.sh $current_script"

    menu_parse -c "$f_cache_file" "$@"
}

m_display_menu() {
    # log_it "reading menu from: $f_cache_file"

    # ---  works  ---

    # while IFS= read -r line; do
    #     set -- "$@" "$line"
    # done <"$f_cache_file"
    # eval "$@"

    IFS=$'\n'
    set -- $(cat "$f_cache_file")
    eval "$@"

    # IFS=$'\n'
    # menu_parse $(cat "$f_cache_file")

    # ---  testing  ---

    # IFS=$'\n'
    # menu_parse $(cat "$f_cache_file")

    #     IFS='
    # '
    #     menu_parse $(cat "$f_cache_file")

    # menu_parse $(cat "$f_cache_file")
    # set -- "$(IFS=$'\n' cat "$f_cache_file")"
    # menu_parse $@

    # menu_parse "$(cat "$f_cache_file")"

    # dbt_duration=$(echo "$(gdate +%s.%3N) - $t_parse" | bc)
    # echo "Duration: [$dbt_duration]"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Should point to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

#  Source dialog handling script
# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

menu_name="Main menu"

req_win_width=39
req_win_height=23

# t_parse="$(gdate +%s.%3N)"

# shellcheck disable=SC2154
if [ ! -f "$f_cache_file" ]; then
    generate_content
fi

if [ -f "$f_cache_file" ]; then
    m_display_menu
    ensure_menu_fits_on_screen
else
    error_msg "menu cache not found: [$f_cache_file]" 1
fi
