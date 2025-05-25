#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

gather_about_box_variables() {
    cd "$D_TM_BASE_PATH" || error_msg "Failed to cd into $D_TM_BASE_PATH"

    td_pull="$(git log -1 --format=%cd --date=iso)"
    vers_no="$(git describe --tags --abbrev=0 2>/dev/null || echo "No tag found")"
    [ -n "$vers_no" ] && {
        td_vers="$(git for-each-ref --format="%(taggerdate:iso)" "refs/tags/$vers_no")"
    }
    [ -n "$td_vers" ] && [ -n "$td_pull" ] && {
        # remove tz, since they might differ
        td_tag_no_tz=${td_vers% *}
        td_current_rev_no_tz=${td_pull% *}

        case "$td_current_rev_no_tz" in
        "$td_tag_no_tz") td_pull="" ;;
        *)
            # only keep td_pull if it is newer than td_vers
            td_pull="$(printf '%s\n%s\n' "$td_tag_no_tz" "$td_current_rev_no_tz" |
                sort | tail -1 | grep -qx "$td_current_rev_no_tz" && echo "$td_pull")"
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
    gather_about_box_variables
    set -- # since it is unclear what item is first, do a init here and then just add
    [ -n "$vers_no" ] && set -- "$@" 0.0 T "-#[nodim]      Version: $vers_no"
    [ -n "$td_vers" ] && set -- "$@" 0.0 T "-#[nodim] Vers release: $td_vers"
    [ -n "$branch" ] && set -- "$@" 0.0 T "-#[nodim]       Branch: $branch"
    [ -n "$td_pull" ] && set -- "$@" 0.0 T "-#[nodim]Latest update: $td_pull"
    menu_generate_part 4 "$@"
}

static_content() {
    set -- \
        0.0 M Left "Back to Main menu      $nav_home" main.sh \
        0.0 S \
        0.0 T "-#[nodim] $nav_next#[default]  #[nodim]Open a new menu." \
        0.0 T "-#[nodim] $nav_prev#[default]  #[nodim]Back to previous menu." \
        0.0 T "-#[nodim] $nav_home#[default]  #[nodim]Back to start menu." \
        0.0 S \
        0.0 T "-#[nodim]Shortcut keys are usually upper case" \
        0.0 T "-#[nodim]for menus, and lower case for actions."
    menu_generate_part 1 "$@"

    $cfg_use_whiptail || {
        set -- \
            0.0 T "-" \
            0.0 T "-#[nodim]j & k can be used for menu scrolling" \
            0.0 T "-#[nodim]      no items use either as shortcuts."
        menu_generate_part 2 "$@"
    }

    set -- \
        0.0 T "-" \
        0.0 T "-#[align=centre,nodim]--------  About this plugin  -------"
    menu_generate_part 3 "$@"

    git_repo="$(git config --get remote.origin.url)"
    set --
    [ -n "$git_repo" ] && set -- "$@" 0.0 T "-#[nodim]Repo: $git_repo"
    ! $cfg_use_whiptail && {
        set -- "$@" \
            0.0 S \
            0.0 T "-#[nodim]Exit menus with ESC or Ctrl-C"
    }
    menu_generate_part 5 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help summary"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
