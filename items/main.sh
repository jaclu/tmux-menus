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
    menu_name="Main menu"

    #  Menu items definition
    set -- \
        0.0 M P "Handling Pane     -->" "$D_TM_ITEMS"/panes.sh \
        0.0 M W "Handling Window   -->" "$D_TM_ITEMS"/windows.sh \
        2.0 M S "Handling Sessions -->" "$D_TM_ITEMS"/sessions.sh \
        0.0 M L "Layouts           -->" "$D_TM_ITEMS"/layouts.sh \
        0.0 M V "Split view        -->" "$D_TM_ITEMS"/split_view.sh \
        0.0 M M "Missing Keys      -->" "$D_TM_ITEMS"/missing_keys.sh \
        0.0 M E "Extras            -->" "$D_TM_ITEMS"/extras.sh \
        0.0 M A "Advanced Options  -->" "$D_TM_ITEMS"/advanced.sh \
        0.0 S \
        0.0 C l "toggle status Line" "set status" \
        0.0 E i "public IP" "$D_TM_SCRIPTS/public_ip.sh" \
        0.0 E p "Plugins inventory" "$D_TM_SCRIPTS/plugins.sh" \
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
        0.0 E r 'Reload configuration file' "$D_TM_SCRIPTS/reload_conf.sh" \
        0.0 S \
        0.0 C d '<P> Detach from tmux' detach-client \
        0.0 S \
        0.0 M H 'Help -->' "$D_TM_ITEMS/help.sh $current_script"

    req_win_width=39
    req_win_height=23
    cache_it
    menu_parse -c "$f_cache_file_menu" "$@"
}

cache_it() {
    (
        echo "#$(date)"
        echo "menu_name='$menu_name'"
        echo "req_win_width='$req_win_width'"
        echo "req_win_height='$req_win_height'"
    ) >"$f_cache_file"

    # # clear it
    # rm -f "$f_cache_file_menu"
    # while [ -n "$1" ]; do
    #     echo "$1" >>"$f_cache_file_menu"
    #     shift
    # done
    log_it "><> updated cache: $f_cache_file"
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

f_cache_file_menu="${f_cache_file}-menu"

# t_parse="$(gdate +%s.%3N)"

# shellcheck disable=SC2154
if [ "$cache_was_read" != 1 ]; then
    generate_content
fi

if [ -f "$f_cache_file_menu" ]; then
    log_it "reading menu from: $f_cache_file_menu"

    # ---  works  ---

    # while IFS= read -r line; do
    #     set -- "$@" "$line"
    # done <"$f_cache_file_menu"
    # eval "$@"

    IFS=$'\n'
    set -- $(cat "$f_cache_file_menu")
    eval "$@"

    # IFS=$'\n'
    # menu_parse $(cat "$f_cache_file_menu")

    # ---  testing  ---

    # IFS=$'\n'
    # menu_parse $(cat "$f_cache_file_menu")

    #     IFS='
    # '
    #     menu_parse $(cat "$f_cache_file_menu")

    # menu_parse $(cat "$f_cache_file_menu")
    # set -- "$(IFS=$'\n' cat "$f_cache_file_menu")"
    # menu_parse $@

    # menu_parse "$(cat "$f_cache_file_menu")"

    # dbt_duration=$(echo "$(gdate +%s.%3N) - $t_parse" | bc)
    # echo "Duration: [$dbt_duration]"
else
    error_msg "menu cache not found: [$f_cache_file_menu]" 1
fi
exit 0
