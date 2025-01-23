#!/bin/sh
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  This is triggered by menus.tmux as plugin is initiated.
#  But can also be run manually, to trigger the re-examination of items/additional/
#
#  If any changes in the files found in items/additional/is observed, either
#  an index menu items/additional/_index.sh is created or updated,
#  listing each additional menu.
#
#  If no other files are found there, the items/additional/_index.sh is removed.
#
#  If the _index.sh is created/removed the cache for the Main Menu is purged.
#  Next time the Main Menu is run, it will check if items/additional/_index.sh
#  is present. If it is, then a menu pointer to this menu is included.
#
# Menus plaed in items/additional can provide two additional hints
# 1. menu label - this will be used in _index.sh to describe the menu.
# 2. shortcut   - what shortcut to use for this menu in _index.sh
#
# If either is missing, a tmux notification will be presented mentioning the issue
# and _index.sh will not be updated to lst the flawed additional menu.
# Once the additional menu has been updated, the next run of this script will
# notice that something changed and will try again to generate a _index.sh pointing
# to all present additional menus.

clear_addditional_items_cache() {
    [ -z "$d_cache" ] && error_msg "variable d_cache was unexpectedly undefined!"
    # clear cache for main menu, so that next time its run it will not include
    # the alternate items index
    rm -rf "$d_cache"/items_main
    # remove all cached additional items
    rm -rf "$d_cache"/additional_items_*/
}

remove_additional_index() {
    # make sure its gone
    rm -f "$f_additional_items_index"
    clear_addditional_items_cache # just to be sure its not pointing this file
}

read_previous_content_checksum() {
    [ -f "$f_chksum_additional" ] && cat "$f_chksum_additional"
}

generate_current_content_checksum() {
    find "$d_additional_items" -type f -exec sha256sum {} + | sort | sha256sum
}

get_variable_from_script() {
    _file="$1"
    _variable_to_verify="$2"
    _code_snippet="$(grep ^"${_variable_to_verify}"= "$_file")"
    [ -z "$_code_snippet" ] && {
        error_msg "$_file does not define $_variable_to_verify" -1
        return 1
    }
    _count="$(echo "$_code_snippet" | wc -l | sed 's/^ *//')"
    [ "$_count" != "1" ] && {
        _msg="There should be exactly one assignment of: $_variable_to_verify in"
        _msg="$_msg $_file - found: $_count"
        error_msg "$_msg" -1
        return 1
    }
    run_in_sub_shell="$(printf '%s\n%s' "$_code_snippet" "echo \$$_variable_to_verify")"
    _variable_content=$(sh -c "$run_in_sub_shell")
}

failed_to_extract_variable() {
    msg="Odd error, this should not happen...\nFailed to extract \"$2\" from\n"
    msg="$msg $1\nDuring create_index\nthis additional item will be skipped for now"
    error_msg "$msg" -1
}

create_additional_index() {
    crate_cache_folder # make sure it exists
    [ -z "$f_additional_items_content" ] && {
        error_msg "variable f_additional_items_content undefined"
    }
    rm -f "$f_additional_items_content" # make sure its nothing there

    for additional_menu in $1; do

        # since the get_variable_from_script calls succeeded just before as the
        # script was validated, lets assume it works again...
        get_variable_from_script "$additional_menu" menu_key || {
            failed_to_extract_variable "$additional_menu" menu_key
            continue
        }
        [ -z "$_variable_content" ] && {
            error_msg "menu_key was empty in: $additional_menu"
        }
        n_menu_key="$_variable_content"
        get_variable_from_script "$additional_menu" menu_label || {
            failed_to_extract_variable "$additional_menu" menu_label
            continue
        }
        [ -z "$_variable_content" ] && {
            error_msg "menu_label was empty in: $additional_menu"
        }
        n_menu_item="$_variable_content"
        [ -f "$f_additional_items_content" ] && {
            # add items continuation to previous item
            printf ' \\\n' >>"$f_additional_items_content"
        }

        printf '        %s \\\n        %s' \
            "0.0 M \"$n_menu_key\" \"$n_menu_item   $cfg_nav_next\"" \
            "$additional_menu" >>"$f_additional_items_content"
        log_it "Will use: $additional_menu"
    done
    [ ! -f "$f_additional_items_content" ] && {
        # all supposedly valid additional items failed to be processed, clear
        # main-menu cache and abort generating this index
        log_it "WARNING: Despite valid additional menus was found, none could be added"
        remove_additional_index
        return 1
    }
    echo >>"$f_additional_items_content" # adding final lf

    # make sure cache is cleared
    clear_addditional_items_cache

    # Generate additional index menu
    sed "/$template_splitter/q" "$f_additional_items_template" | sed '$d' \
        >"$f_additional_items_index"
    cat "$f_additional_items_content" >>"$f_additional_items_index"
    sed -n "/$template_splitter/"',$p' "$f_additional_items_template" | sed '1d' \
        >>"$f_additional_items_index"
    chmod 0755 "$f_additional_items_index"
    generate_current_content_checksum >"$f_chksum_additional"

    # Verify that additional_items/_index.sh was correctly generated
    run_in_sub_shell="$(printf 'export TMUX_MENUS_NO_DISPLAY=1\n%s\n' "$f_additional_items_index")"
    _variable_content=$(sh -c "$run_in_sub_shell")
}

content_has_changed() {
    # This index will be regenerated
    # If it would be present during the folder scann it would be added to the list
    # of menus to be listed within it :)
    rm -f "$f_additional_items_index"

    # create list of runnable scripts in this folder
    runables="$(find "$d_additional_items" -type f -perm +0100)"

    # shellcheck disable=SC2068 # in this case we want to split the param
    valid_menus=""
    for additional_menu in $runables; do
        #
        # Verify the existence of the two variables needed to handle it
        # as an additional menu
        #
        get_variable_from_script "$additional_menu" menu_label || continue
        n_menu_item="$_variable_content"
        get_variable_from_script "$additional_menu" menu_key || continue
        n_menu_key="$_variable_content"

        valid_menus="$valid_menus $additional_menu"
        log_it "Validated src: $additional_menu"
    done
    [ -z "$valid_menus" ] && {
        # none of the additional items are valid abort generation
        remove_additional_index
        log_it "No valid additional items found"
        return 1
    }
    create_additional_index "$valid_menus"
    log_it "Updated $f_additional_items_index"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

f_chksum_additional="$d_cache"/additional_content_chksum

template_splitter="ADDITIONAL_ITEMS_SPLITTER" # items will be inserted at his point
f_additional_items_template="$D_TM_BASE_PATH"/content/additional_index_template
f_additional_items_content="$d_cache"/additional_items_content

# log_interactive_to_stderr=true

if [ ! -d "$d_additional_items" ]; then
    # Folder missing, clear cache and exit
    clear_addditional_items_cache
    exit 0
fi

previous_content_chksum="$(read_previous_content_checksum)"
current_content_chksum="$(generate_current_content_checksum)"
[ -z "$current_content_chksum" ] && error_msg "Failed to scan content in: $d_additional_items"

if [ "$previous_content_chksum" != "$current_content_chksum" ]; then
    content_has_changed
else
    log_it "No changes detected in: $d_additional_items"
fi
