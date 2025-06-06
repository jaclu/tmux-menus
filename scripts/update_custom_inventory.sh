#!/bin/sh
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  This is triggered by menus.tmux as plugin is initiated.
#  But can also be run manually, to trigger the re-examination of custom_items/
#
#  If any changes in the files found in custom_items/ is observed, either
#  an index menu custom_items/_index.sh is created or updated,
#  listing each custom menu.
#
#  If no other files are found there, the custom_items/_index.sh is removed.
#
#  If the _index.sh is created/removed the cache for the Main Menu is purged.
#  Next time the Main Menu is run, it will check if custom_items/_index.sh
#  is present. If it is, then a menu pointer to this menu is included.
#

clear_cache_main_index() {
    # log_it "UCI:clear_cache_main_index()"
    safe_remove "$d_cache_main_menu" "clear_cache_main_index()"
}

clear_cache_custom_items() {
    # log_it "UCI:clear_cache_custom_items()"
    [ -z "$d_cache" ] && error_msg "variable d_cache was unexpectedly undefined!"

    safe_remove "$d_cache"/custom_items "clear_cache_custom_items()"
    safe_remove "$f_chksum_custom" "clear_cache_custom_items()"

    # only time this should not be done is when cache...
    [ "$1" != "keep_content_template" ] && clear_custom_content_template
}

clear_custom_content_template() {
    # remove temp file - items being added to custom menu
    # log_it "UCI:clear_custom_content_template()"
    safe_remove "$f_custom_items_content" "clear_custom_content_template()"
}

remove_custom_item_content() {
    # Remove custom item index page and all related caches
    # log_it "UCI:remove_custom_item_content() - $f_custom_items_index"
    safe_remove "$f_custom_items_index" "remove_custom_item_content()"
    clear_cache_custom_items # just to be sure its not pointing this file
}

checksum_content_read() {
    # log_it "UCI:checksum_content_read()"
    if [ -f "$f_chksum_custom" ]; then
        cat "$f_chksum_custom"
    fi
}

checksum_content_write() {
    # log_it "UCI:checksum_content_write()"
    find "$d_custom_items/" -type f -exec sha256sum {} + | sort |
        sha256sum >"$f_chksum_custom" || {

        error_msg "Failed to write checksum into: $f_chksum_custom"
    }
}

custom_items_changed_check() {
    # log_it "UCI:custom_items_changed_check()"

    previous_content_chksum="$(checksum_content_read)"
    checksum_content_write
    current_content_chksum="$(checksum_content_read)"
    [ -z "$current_content_chksum" ] && {
        error_msg "Failed to scan content in: $d_custom_items"
    }

    [ "$previous_content_chksum" != "$current_content_chksum" ]
}

get_variable_from_script() {
    #
    # exposed variables:
    #   variable_content
    #
    _file="$1"
    _variable_to_verify="$2"
    _show_error="$3"

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
    variable_content=$(sh -c "$run_in_sub_shell")

    [ "$_show_error" = "show_error" ] && [ -z "$variable_content" ] && {
        error_msg "$custom_menu: $_variable_to_verify was empty"
    }
    return 0
}

failed_to_extract_variable() {
    msg="Odd error, this should not happen...\nFailed to extract \"$2\" from\n"
    msg="$msg $1\nDuring create_index\nthis custom item will be skipped for now"
    error_msg "$msg"
}

create_custom_index() {
    # log_it "UCI:create_custom_index()"
    cache_create_folder "create_custom_index()" # make sure it exists
    [ -z "$f_custom_items_content" ] && {
        error_msg "variable f_custom_items_content undefined"
    }

    # make sure its nothing there
    safe_remove "$f_custom_items_content" "create_custom_index()"

    clear_cache_main_index

    for custom_menu in $1; do

        # since the get_variable_from_script calls succeeded just before as the
        # script was validated, lets assume it works again...
        _variable="menu_key"
        get_variable_from_script "$custom_menu" "$_variable" show_error || {
            failed_to_extract_variable "$custom_menu" "$_variable"
            continue
        }
        _menu_key="$variable_content"

        _variable="menu_name"
        get_variable_from_script "$custom_menu" "$_variable" show_error || {
            failed_to_extract_variable "$custom_menu" "$_variable"
            continue
        }
        _menu_name="$variable_content"

        [ -f "$f_custom_items_content" ] && {
            # add items continuation to previous item
            printf ' \\\n' >>"$f_custom_items_content"
        }
        # this generates an item that will be added to custom items index
        printf '        %s \\\n        %s' \
            "0.0 M \"$_menu_key\" \"$_menu_name  $cfg_nav_next\"" \
            "$custom_menu" >>"$f_custom_items_content"
        # log_it "UCI:Will use: $custom_menu"
    done
    [ ! -f "$f_custom_items_content" ] && {
        # All supposedly valid custom items failed to be processed,
        # abort generating this index
        remove_custom_item_content
        log_it "UCI:WARNING: Despite valid custom menus was found, none could be added"
        return 1
    }
    echo >>"$f_custom_items_content" # adding final lf

    # make sure cache is cleared
    clear_cache_custom_items keep_content_template

    # Generate custom index menu
    sed "/$template_splitter/q" "$f_custom_items_template" | sed '$d' \
        >"$f_custom_items_index"
    cat "$f_custom_items_content" >>"$f_custom_items_index"
    clear_custom_content_template

    sed -n "/$template_splitter/"',$p' "$f_custom_items_template" | sed '1d' \
        >>"$f_custom_items_index"
    chmod 0755 "$f_custom_items_index"
    checksum_content_write # custom index change
    # Verify that custom_items/_index.sh was correctly generated
    run_in_sub_shell="$(
        printf '%s\n%s\n%s\n' \
            "export TMUX_MENUS_NO_DISPLAY=1" \
            "export TMUX_MENUS_LOGGING_MINIMAL=2" \
            "$f_custom_items_index"
    )"
    # 'export TMUX_MENUS_LOGGING_MINIMAL=2' \
    variable_content=$(sh -c "$run_in_sub_shell")
}

process_custom_items() {
    # This index will be regenerated
    # If it would be present during the folder scan it would be added to the list
    # of menus to be listed within it :)
    # log_it "UCI:process_custom_items()"

    safe_remove "$f_custom_items_index" "process_custom_items()"

    # create list of runnable scripts in this folder
    # the name filter is intended to filter out foo.sh~ and foo.bash~ names
    runables="$(find "$d_custom_items" -maxdepth 1 -type f -name '*sh' -perm -u=x)"
    valid_menus=""
    for custom_menu in $runables; do
        #
        # Verify the existence of the two variables needed to handle it
        # as an custom menu
        #
        get_variable_from_script "$custom_menu" menu_key || continue
        get_variable_from_script "$custom_menu" menu_name || continue

        valid_menus="$valid_menus $custom_menu"
        # log_it "UCI:Validated src: $custom_menu"
    done
    [ -z "$valid_menus" ] && {
        # none of the custom items are valid abort generation

        remove_custom_item_content
        log_it "UCI:No valid custom items found"
        return 1
    }
    create_custom_index "$valid_menus"
    log_it "UCI:Updated $f_custom_items_index"
}

custom_items_prepare() {
    # log_it "UCI:custom_items_prepare()"
    if [ ! -d "$d_custom_items" ]; then
        [ -f "$f_chksum_custom" ] && {
            # log_it "UCI: Clearing main menu cache since custom items are gone"
            clear_cache_main_index
        }
        # Folder missing, clear custom items cache and exit
        remove_custom_item_content
    else
        if custom_items_changed_check; then
            process_custom_items
        else
            log_it "UCI:No changes detected in custom_items"
        fi
    fi
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

template_splitter="CUSTOM_ITEMS_SPLITTER" # items will be inserted at his point
f_custom_items_template="$D_TM_BASE_PATH"/templates/custom_index_template.sh
# File used during generation of custom image index
# as each custom item is verified, it is added here
# then inserted into the custom index and removed
f_custom_items_content="$d_cache"/custom_items_content

if $cfg_use_cache; then
    custom_items_prepare
else
    error_msg "$rn_current_script - should not be run if caching is disabled!"
fi
