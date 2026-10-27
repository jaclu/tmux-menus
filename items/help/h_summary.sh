#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

gather_about_box_variables() {
    # Release date from the CHANGELOG heading of the version in use
    # shellcheck disable=SC2154 # menus_version is set in scripts/helpers.sh, always sourced
    rel_date="$(sed -n "s/^## \[$menus_version\] - \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$/\1/p" \
        "$TMUX_MENUS_LOCATION/CHANGELOG.md" 2>/dev/null | head -1)"
    rel_date="${rel_date:-unreleased}"

    # Checkout details only exist when .git is present, checked by existence
    # so a copied plugin inside some other git repo is not mistaken for a checkout
    if [ -e "$TMUX_MENUS_LOCATION/.git" ]; then
        branch="$(git -C "$TMUX_MENUS_LOCATION" symbolic-ref --quiet --short HEAD 2>/dev/null)"
        sha="$(git -C "$TMUX_MENUS_LOCATION" rev-parse --short HEAD 2>/dev/null)"
        commit_date="$(git -C "$TMUX_MENUS_LOCATION" log -1 --format=%cs 2>/dev/null)"
        # Empty if the version tag does not exist yet, i.e. unreleased
        ahead="$(git -C "$TMUX_MENUS_LOCATION" rev-list --count "v$menus_version..HEAD" 2>/dev/null)"
        dirty="$(git -C "$TMUX_MENUS_LOCATION" status --porcelain 2>/dev/null)"
        repo_url="$(git -C "$TMUX_MENUS_LOCATION" config --get remote.origin.url 2>/dev/null)"
    fi
}

dynamic_content() {
    # Things that change dependent on various states
    gather_about_box_variables
    set -- # since it is unclear what item is first, do an init here and then just add
    set -- "$@" 0.0 T "Version:  $menus_version"
    set -- "$@" 0.0 T "Released: $rel_date"

    if [ -n "$sha" ]; then
        case "$branch" in
            main | master) checkout="$branch" ;;
            *) checkout="${branch:-detached} @ $sha ($commit_date)" ;;
        esac

        # Plain release checkout needs no line, only deviations are worth showing
        show_checkout=false
        case "$branch" in
            main | master) ;;
            *) show_checkout=true ;;
        esac
        [ "${ahead:-0}" -gt 0 ] && show_checkout=true
        [ -n "$dirty" ] && show_checkout=true

        [ "${ahead:-0}" -gt 0 ] && {
            [ "$ahead" -eq 1 ] && checkout="$checkout, 1 commit after v$menus_version" \
                || checkout="$checkout, $ahead commits after v$menus_version"
        }
        [ -n "$dirty" ] && checkout="$checkout + local changes"

        [ "$show_checkout" = true ] && {
            set -- "$@" \
                0.0 T "Checkout:" \
                0.0 T "$checkout"
        }
    fi

    # Only shown for non-official origins, e.g. forks, since that is what matters for support
    case "$repo_url" in
        "" | *github.com[:/]jaclu/tmux-menus | *github.com[:/]jaclu/tmux-menus.git) ;;
        *) set -- "$@" 0.0 T "Repo:     $repo_url" ;;
    esac

    menu_generate_part 4 "$@"
}

static_content() {
    set -- \
        0.0 M Left "Main Menu      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T " $nav_next#[default,nodim]  Open a new menu." \
        0.0 T " $nav_prev#[default,nodim]  Back to previous menu." \
        0.0 T " $nav_home#[default,nodim]  Back to start menu." \
        0.0 S \
        0.0 T "Shortcut keys are usually upper case" \
        0.0 T "for menus, and lower case for actions."
    menu_generate_part 1 "$@"

    [ -n "$alt_menu_handler" ] || {
        set -- \
            0.0 T "" \
            0.0 T "j & k can be used for menu scrolling" \
            0.0 T "      no items use either as shortcuts."
        menu_generate_part 2 "$@"
    }

    set -- \
        0.0 T "" \
        0.0 T "#[align=centre]--------  About this plugin  -------"
    menu_generate_part 3 "$@"

    set --
    [ -z "$alt_menu_handler" ] && {
        set -- "$@" \
            0.0 S \
            0.0 T "Exit menus with ESC or Ctrl-C"
    }
    menu_generate_part 5 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help summary"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
