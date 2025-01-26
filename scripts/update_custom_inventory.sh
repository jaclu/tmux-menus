#!/bin/sh
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  This is triggered by menus.tmux as plugin is initiated.
#  But can also be run manually, to trigger the re-examination of items/custom/
#
#  If any changes in the files found in items/custom/is observed, either
#  an index menu items/custom/_index.sh is created or updated,
#  listing each custom menu.
#
#  If no other files are found there, the items/custom/_index.sh is removed.
#
#  If the _index.sh is created/removed the cache for the Main Menu is purged.
#  Next time the Main Menu is run, it will check if items/custom/_index.sh
#  is present. If it is, then a menu pointer to this menu is included.
#
# Menus plaed in items/custom can provide two custom hints
# 1. menu label - this will be used in _index.sh to describe the menu.
# 2. shortcut   - what shortcut to use for this menu in _index.sh
#
# If either is missing, a tmux notification will be presented mentioning the issue
# and _index.sh will not be updated to lst the flawed custom menu.
# Once the custom menu has been updated, the next run of this script will
# notice that something changed and will try again to generate a _index.sh pointing
# to all present custom menus.

clear_custom_items_cache() {
    [ -z "$d_cache" ] && error_msg "variable d_cache was unexpectedly undefined!"
    # clear cache for main menu, so that next time its run it will not include
    # the alternate items index
    rm -rf "$d_cache"/items_main
    # remove all cached custom items
    rm -rf "$d_cache"/custom_items_*/
}

remove_custom_index() {
    # make sure its gone
    rm -f "$f_custom_items_index"
    clear_custom_items_cache # just to be sure its not pointing this file
}


read_content_checksum() {
    [ -f "$f_chksum_custom" ] && cat "$f_chksum_custom"
}

store_content_checksum() {
    find "$d_custom_items" -type f -exec sha256sum {} + | sort | \
	sha256sum > "$f_chksum_custom" || {

	error_msg "Failed to write checksum into: $f_chksum_custom"
    }
}

content_changed_check() {
    log_it "content_changed_check()"

    previous_content_chksum="$(read_content_checksum)"
    log_it " previous: $previous_content_chksum"

    store_content_checksum
    current_content_chksum="$(read_content_checksum)"
    [ -z "$current_content_chksum" ] && {
	error_msg "Failed to scan content in: $d_custom_items"
    }
    log_it " current:  $current_content_chksum"

    [ "$previous_content_chksum" != "$current_content_chksum" ]
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
    msg="$msg $1\nDuring create_index\nthis custom item will be skipped for now"
    error_msg "$msg" -1
}

create_custom_index() {
    log_it "create_custom_index()"
    crate_cache_folder # make sure it exists
    [ -z "$f_custom_items_content" ] && {
        error_msg "variable f_custom_items_content undefined"
    }
    rm -f "$f_custom_items_content" # make sure its nothing there

    for custom_menu in $1; do

        # since the get_variable_from_script calls succeeded just before as the
        # script was validated, lets assume it works again...
        get_variable_from_script "$custom_menu" menu_key || {
            failed_to_extract_variable "$custom_menu" menu_key
            continue
        }
        [ -z "$_variable_content" ] && {
            error_msg "menu_key was empty in: $custom_menu"
        }
        n_menu_key="$_variable_content"
        get_variable_from_script "$custom_menu" menu_name || {
            failed_to_extract_variable "$custom_menu" menu_label
            continue
        }
        [ -z "$_variable_content" ] && {
            error_msg "menu_label was empty in: $custom_menu"
        }
        n_menu_item="$_variable_content"
        [ -f "$f_custom_items_content" ] && {
            # add items continuation to previous item
            printf ' \\\n' >>"$f_custom_items_content"
        }

        printf '        %s \\\n        %s' \
            "0.0 M \"$n_menu_key\" \"$n_menu_item   $cfg_nav_next\"" \
            "$custom_menu" >>"$f_custom_items_content"
        log_it "Will use: $custom_menu"
    done
    [ ! -f "$f_custom_items_content" ] && {
        # all supposedly valid custom items failed to be processed, clear
        # main-menu cache and abort generating this index
        log_it "WARNING: Despite valid custom menus was found, none could be added"
        remove_custom_index
        return 1
    }
    echo >>"$f_custom_items_content" # adding final lf

    # make sure cache is cleared
    clear_custom_items_cache

    # Generate custom index menu
    sed "/$template_splitter/q" "$f_custom_items_template" | sed '$d' \
        >"$f_custom_items_index"
    cat "$f_custom_items_content" >>"$f_custom_items_index"
    sed -n "/$template_splitter/"',$p' "$f_custom_items_template" | sed '1d' \
        >>"$f_custom_items_index"
    chmod 0755 "$f_custom_items_index"
    store_content_checksum

    # Verify that custom_items/_index.sh was correctly generated
    run_in_sub_shell="$(printf 'export TMUX_MENUS_NO_DISPLAY=1\n%s\n' "$f_custom_items_index")"
    _variable_content=$(sh -c "$run_in_sub_shell")
}

process_custom_items() {
    # This index will be regenerated
    # If it would be present during the folder scann it would be added to the list
    # of menus to be listed within it :)
    log_it "process_custom_items()"
    rm -f "$f_custom_items_index"

    # create list of runnable scripts in this folder
    # the name filter is intended to filter out foo.sh~ and foo.bash~ names
    runables="$(find "$d_custom_items/" -type f -name '*sh'  -executable)"

    # shellcheck disable=SC2068 # in this case we want to split the param
    valid_menus=""
    for custom_menu in $runables; do
	# log_it " examining: $custom_menu"
        #
        # Verify the existence of the two variables needed to handle it
        # as an custom menu
        #
        get_variable_from_script "$custom_menu" menu_name || continue
        n_menu_item="$_variable_content"
        get_variable_from_script "$custom_menu" menu_key || continue
        n_menu_key="$_variable_content"

        valid_menus="$valid_menus $custom_menu"
        log_it "Validated src: $custom_menu"
    done
    [ -z "$valid_menus" ] && {
        # none of the custom items are valid abort generation
        remove_custom_index
        log_it "No valid custom items found"
        return 1
    }
    create_custom_index "$valid_menus"
    log_it "Updated $f_custom_items_index"
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

f_chksum_custom="$d_cache"/chksum_custom_content

template_splitter="CUSTOM_ITEMS_SPLITTER" # items will be inserted at his point
f_custom_items_template="$D_TM_BASE_PATH"/items/custom_index_template.sh
f_custom_items_content="$d_cache"/custom_items_content

# debug helper
[ "$1" = "stderr" ] && log_interactive_to_stderr=true

if [ ! -d "$d_custom_items" ]; then
    # Folder missing, clear cache and exit
    clear_custom_items_cache
    exit 0
fi

if content_changed_check; then
    process_custom_items
else
    log_it "No changes detected in: $d_custom_items"
fi
