#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

calculate_about_box_content() {
    cd "$D_TM_BASE_PATH" || error_msg "Failed to cd into $D_TM_BASE_PATH"

    git_repo="$(git config --get remote.origin.url)"

    td_current_rev="$(git log -1 --format=%cd --date=iso)"
    current_tag="$(git describe --tags --abbrev=0 2>/dev/null || echo "No tag found")"
    [ -n "$current_tag" ] && {
        td_tag="$(git for-each-ref --format="%(taggerdate:iso)" "refs/tags/$current_tag")"
    }
    [ -n "$td_tag" ] && [ -n "$td_current_rev" ] && {
        # remove tz, since they might differ
        td_tag_no_tz=${td_tag% *}
        td_current_rev_no_tz=${td_current_rev% *}

        case "$td_current_rev_no_tz" in
        "$td_tag_no_tz") td_current_rev="" ;;
        *)
            # only keep td_current_rev if it is newer than td_tag
            td_current_rev="$(printf '%s\n%s\n' "$td_tag_no_tz" "$td_current_rev_no_tz" |
                sort | tail -1 | grep -qx "$td_current_rev_no_tz" && echo "$td_current_rev")"
            ;;
        esac
    }

    branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)"
    case "$branch" in
    main | master) branch="" ;;
    *) ;;
    esac
}

dynamic_content() {
    # Things that change dependent on various states

    if [ -z "$prev_menu" ]; then
        error_msg_safe "$bn_current_script was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" main.sh
    menu_generate_part 1 "$@"

    calculate_about_box_content
    set -- # since it is unclear what item is first, do a reset here and then just add
    [ -n "$current_tag" ] && set -- "$@" 0.0 T "-#[nodim]Latest Tag:    $current_tag"
    [ -n "$td_tag" ] && set -- "$@" 0.0 T "-#[nodim]Tag date:      $td_tag"
    [ -n "$branch" ] && set -- "$@" 0.0 T "-#[nodim]Branch:        $branch"
    [ -n "$td_current_rev" ] && set -- "$@" 0.0 T "-#[nodim]Latest commit: $td_current_rev"
    menu_generate_part 3 "$@"
}

static_content() {
    set -- \
        0.0 S \
        0.0 T "-#[nodim] $nav_next#[default]  #[nodim]Open a new menu." \
        0.0 T "-#[nodim] $nav_prev#[default]  #[nodim]Back to previous menu." \
        0.0 T "-#[nodim] $nav_home#[default]  #[nodim]Back to start menu." \
        0.0 S \
        0.0 T "-#[nodim]Shortcut keys are usually upper case" \
        0.0 T "-#[nodim]for menus, and lower case for actions." \
        0.0 T " " \
        0.0 T "-#[align=centre,nodim]--------  About this plugin  -------"
    menu_generate_part 2 "$@"

    calculate_about_box_content
    set -- 0.0 T "-#[nodim]Repo: $git_repo"

    ! $cfg_use_whiptail && {
        set -- "$@" \
            0.0 S \
            0.0 T "-#[nodim]Exit menus with ESC or Ctrl-C"
    }
    menu_generate_part 4 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -n "$1" ] && prev_menu="$(realpath "$1")"
menu_name="Help summary"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
