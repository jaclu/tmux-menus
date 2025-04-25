#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

dynamic_content() {
    # Things that change dependent on various states

    if [ -z "$prev_menu" ]; then
        error_msg_safe "$bn_current_script was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" main.sh

    menu_generate_part 1 "$@"
}

static_content() {
    cd "$D_TM_BASE_PATH" || error_msg "Failed to cd into $D_TM_BASE_PATH"
    current_tag="$(git describe --tags --abbrev=0 2>/dev/null || echo "No tag found")"
    branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)"
    case "$branch" in
    main | master) branch="" ;;
    *) ;;
    esac
    # current_rev="$(git log -1 --format=%cd)"
    current_rev="$(git log -1 --format=%cd --date=format:'%Y-%m-%d %H:%M:%S')"
    git_repo="$(git config --get remote.origin.url)"

    # Once I start using Annotated tags, this should hopefully give the time when the
    # tag was created
    # TAG=$(git describe --tags --abbrev=0 2>/dev/null)
    # [ -n "$TAG" ] && git for-each-ref --format="%(taggerdate:iso)" "refs/tags/$TAG"

    set -- \
        0.0 S \
        0.0 T "-#[nodim] $nav_next#[default]  #[nodim]Open a new menu." \
        0.0 T "-#[nodim] $nav_prev#[default]  #[nodim]Back to previous menu." \
        0.0 T "-#[nodim] $nav_home#[default]  #[nodim]Back to start menu." \
        0.0 S \
        0.0 T "-#[nodim]Shortcut keys are usually upper case" \
        0.0 T "-#[nodim]for menus, and lower case for actions." \
        0.0 T " " \
        0.0 T "-#[align=centre,nodim]--------  About this plugin  -------" \
        0.0 T "-#[nodim]Latest Tag:   $current_tag"

    [ -n "$branch" ] && set -- "$@" 0.0 T "-#[nodim]Branch:       $branch"

    set -- \
        "$@" 0.0 T "-#[nodim]Last Updated: $current_rev" \
        0.0 T "-#[nodim]Repo: $git_repo"
    # 0.0 T "-#[nodim]$git_repo"

    ! $cfg_use_whiptail && {
        set -- "$@" \
            0.0 S \
            0.0 T "-#[nodim]Exit menus with ESC or Ctrl-C"
    }

    menu_generate_part 2 "$@"
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
