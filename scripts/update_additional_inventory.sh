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

clear_main_menu_cache() {
    [ -z "$d_cache" ] && error_msg "variable d_cache was unexpectedly undefined!"
    rm -rf "$d_cache"/items_main
}

remove_additional_index() {
    # make sure its gone
    rm -f "$f_additional_items_index"
    clear_main_menu_cache # just to be sure its not pointing this file
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
    # log_it "_code_snippet:[$_code_snippet]"
    _count="$(echo "$_code_snippet" | wc -l | sed 's/^ *//')"
    [ "$_count" != "1" ] && {
        _msg="There should be exactly one assignment of: $_variable_to_verify in"
        _msg="$_msg $_file - found: $_count"
        error_msg "$_msg" -1
        return 1
    }
    run_in_sub_shell="$_code_snippet; echo \$$_variable_to_verify"
    _variable_content=$(sh -c "$run_in_sub_shell")
    # log_it "$_code_snippet resulted in:[$_variable_content]"
}

failed_to_extract_variable() {
    msg="Odd error, this should not happen...\nFailed to extract \"$2\" from\n"
    msg="$msg $1\nDuring create_index\nthis additional item will be skipped for now"
    error_msg "$msg" -1
}

create_additional_index() {
    additional_menus_def=""
    for additional_menu in $1; do

        # since the get_variable_from_script calls succeeded just before as the
        # script was validated, lets assume it works again...
        get_variable_from_script "$additional_menu" menu_item || {
            failed_to_extract_variable "$additional_menu" menu_item
            continue
        }
        n_menu_item="$_variable_content"

        get_variable_from_script "$additional_menu" menu_key || {
            failed_to_extract_variable "$additional_menu" menu_key
            continue
        }
        n_menu_key="$_variable_content"
        # the ammount of escapes needed in ot
        # 6 \ seems to work
        new_item="$(printf "0.0 M \"$n_menu_key\" \"$n_menu_item\" \\n $additional_menu")"
        log_it "$new_item"
        exit
        additional_menus_def="$additional_menus_def $new_item"
    done
    [ -z "$additional_menus_def" ] && {
        # all suposedly vallid additional items failed to be processed, abort genrating
        # this index clear main menu cache in case it was recreated in
        log_it "Despite valid additional menus was found, none could be added"
        remove_additional_index
        return 1
    }
    log_it "additional items [$additional_menus_def]"

    cp "$D_TM_BASE_PATH"/content/additional_index_template \
        "$f_additional_items_index" || {
        error_msg "Failed to copy addittional index template"
    }
    chmod 0755 "$f_additional_items_index"

    if [ "$(uname)" = "Darwin" ]; then
        # why is MacOS sed not normal...
        darwin_param="''"
    else
        darwin_param=""
    fi
    sed_safe_add_menus="$(echo "$additional_menus_def" | sed s/\"/\\\\\"/g)"
    log_it "sed_safe_add_menus [$sed_safe_add_menus]"
    sed_condition="s#$place_holder#$sed_safe_add_menus \\\\#"
    log_it "sed_condition [$sed_condition]"
    sed -i "$darwin_param" "$sed_condition" "$f_additional_items_index"
    log_it "sed done"
}

content_has_changed() {
    log_it "content_has_changed()"

    # create list of runnable scripts in this folder
    # runables="$(find "$d_additional_items" -type f -perm +0100)"
    runables="/Users/jaclu/git_repos/mine/tmux-menus/additional_items/panes.sh
    /Users/jaclu/git_repos/mine/tmux-menus/additional_items/main2.sh"
    log_it "runables: [$runables]"

    # shellcheck disable=SC2068 # in this case we want to split the param
    valid_menus=""
    for additional_menu in $runables; do
        log_it
        log_it "processing additional menu: $additional_menu"

        #
        # First verify the existance of the two variables needed to handle it
        # as an additional menu
        #

        get_variable_from_script "$additional_menu" menu_item || continue
        n_menu_item="$_variable_content"

        get_variable_from_script "$additional_menu" menu_key || continue
        n_menu_key="$_variable_content"

        # log_it "  found: menu_item='$n_menu_item' menu_key='$n_menu_key'"
        valid_menus="$valid_menus $additional_menu"
    done
    [ -z "$valid_menus" ] && {
        # none of the additional items are valid abort generation
        remove_additional_index
        return 1
    }
    log_it "Valid items: $valid_menus"
    create_additional_index "$valid_menus"
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

d_additional_items="$D_TM_BASE_PATH"/additional_items
f_chksum_additional="$d_cache"/additional_content_chksum
f_additional_items_index="$d_additional_items"/_index.sh
place_holder="ADDITIONAL_ITEMS_PLACEHOLDER"

log_interactive_to_stderr=true

if [ ! -d "$d_additional_items" ]; then
    # Folder missing, clear cache and exit
    clear_main_menu_cache
    exit 0
fi

echo "><> log_file: $cfg_log_file"
previous_content_chksum="$(read_previous_content_checksum)"
log_it "previous_content_chksum: $previous_content_chksum"
current_content_chksum="$(generate_current_content_checksum)"
log_it "current_content_chksum: $current_content_chksum"

[ -z "$current_content_chksum" ] && error_msg "Failed to scan content in: $d_additional_items"

[ "$previous_content_chksum" != "$current_content_chksum" ] && content_has_changed
