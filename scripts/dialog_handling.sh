#!/bin/sh
# This is sourced. Fake bang-path to help editors and linters
#
#   Copyright (c) 2023-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Parses params and generates tmux or whiptail menus
#  One variable is expected to have been set by the caller
#
#  D_TM_BASE_PATH - base location for tmux-menus plugin
#

get_mtime() {
    _fname="$1"
    if [ "$(uname)" = "Darwin" ]; then
        # macOS version
        stat -f "%m" "$_fname"
    else
        # Linux version
        stat -c "%Y" "$_fname"
    fi
}

debug_print() {
    case "$menu_debug" in
    "") ;; # not active
    1) echo "$1" ;;
    2) log_it "$1" ;;
    *)
        error_msg "$menu_debug state invalid [$menu_debug] shoule be 1 or 2! p1[$1]"
        ;;
    esac
}

ensure_menu_fits_on_screen() {
    #
    #  Since tmux display-menu returns 0 even if it failed to display the
    #  menu due to not fitting on the screen, the display time is checked.
    #  If it seems to have closed right away, display a message that there
    #  might be a screen size issue.
    #
    #  This is not ideal, since a very slow computer might take some time
    #  for this, and if the user hits q right away, this message will also
    #  be displayed.
    #
    #  This gets slightly more complicated with tmux 3.3, since now tmux
    #  shrinks menus that don't fit due to width, so tmux might decide it
    #  can show a menu, but due to shrinkage, the labels might be so
    #  shortened that they are off little help explaining what the option
    #  would do.
    #

    # Display time meny was shown
    disp_time="$(echo "$(safe_now) - $dh_t_start" | bc)"
    log_it "Menu $current_script_no_ext - Display time:  $disp_time"

    if [ "$(echo "$disp_time < 0.5" | bc)" -eq 1 ]; then
        error_msg "$(relative_path "$f_current_script") Screen might be too small"
    fi
    unset disp_time
}

starting_with_dash() {
    #
    #  In whiptail/dialog, an initial '-'' in a label causes the menu to
    #  fail, in tmux menus this is used to indicate dimmed (disabled)
    #  entries, for whiptail/dialog entries with such labels are just
    #  ignored
    #
    if [ "$(printf '%s' "$1" | cut -c 1)" = "-" ]; then
        return 0
    else
        return 1
    fi
}

#
#  tmux 3.0+ built in menu handling using display-menu
#
tmux_dialog_prefix() {
    menu_items="tmux_error_handler display-menu -T \"#[align=centre] $menu_name \" \
        -x '$cfg_mnu_loc_x' -y '$cfg_mnu_loc_y'"
}

tmux_open_menu() {
    label="$1"
    key="$2"
    menu="$3"

    # [ -n "$menu_debug" ] && debug_print "tmux_open_menu($label,$key,$menu)"

    menu_items="$menu_items \"$label\" $key \"run-shell '$menu'\""
}

tmux_external_cmd() {
    label="$1"
    key="$2"
    # cmd="$3"
    cmd="$(echo "$3" | sed 's/"/\\"/g')" # replace embedded " with \"
    # [ -n "$menu_debug" ] && debug_print "tmux_external_cmd($label,$key,$cmd)"

    #
    #  needs to be prefixed with run-shell, since this is triggered by
    #  tmux
    #
    menu_items="$menu_items \"$label\" $key 'run-shell \"$cmd\"'"
}

tmux_command() {
    label="$1"
    key="$2"
    # cmd="$3"
    cmd="$(echo "$3" | sed 's/"/\\"/g')" # replace embedded " with \"

    # [ -n "$menu_debug" ] && debug_print "tmux_command($label,$key,$cmd)"
    menu_items="$menu_items \"$label\" $key \"$cmd\""
}

tmux_text_line() {
    txt="$1"
    menu_items="$menu_items \"$txt\" '' ''"
}

tmux_spacer() {
    menu_items="$menu_items \"\""
}

alt_dialog_prefix() {
    menu_items="$dialog_app --menu \"$menu_name\" 0 0 0 "
}

alt_dialog_open_menu() {
    label="$1"
    key="$2"
    menu="$3"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$label" && return

    menu_items="$menu_items $key \"$label\""
    wt_actions="$wt_actions $key | $menu $alt_dialog_action_separator"
}

alt_dialog_external_cmd() {
    label="$1"
    key="$2"
    cmd="$3"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$label" && return

    menu_items="$menu_items $key \"$label\""
    # This will run outside tmux, so should not have run-shell prefix
    wt_actions="$wt_actions $key | $cmd $alt_dialog_action_separator"
}

alt_dialog_command() {
    # filtering out tmux #{...} & #[...] sequences
    label="$(echo "$1" | sed 's/#{[^}]*}//g' | sed 's/#\[[^}]*\]//g')"
    key="$2"
    cmd="$3"
    keep_cmd="${4:-false}"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$label" && return

    # filer out backslashes prefixing special chars
    key_action="$(echo "$key" | sed 's/\\//')"

    menu_items="$menu_items $key \"$label\""
    if $keep_cmd; then
        wt_actions="$wt_actions $key_action | $cmd $alt_dialog_action_separator"
    else
        wt_actions="$wt_actions $key_action | tmux_error_handler $cmd $alt_dialog_action_separator"
    fi
    unset label
    unset key
    unset cmd
    unset keep_cmd
    unset key_action
}

alt_dialog_text_line() {
    #
    #  filtering out tmux #{...} sequences and initial -
    #  labels starting with - indicates disabled feature,
    #  whiptail can not handle labels starting with -, so remove it
    #
    txt="$(echo "$1" | sed 's/#{[^}]*}//g' | sed 's/#\[[^}]*\]//g' | sed 's/^[-]//')"

    if [ "$(printf '%s' "$txt" | cut -c1)" = "-" ]; then
        txt=" ${txt#?}"
    fi

    menu_items="$menu_items '' \"$txt\""
}

alt_dialog_spacer() {
    menu_items="$menu_items '' ' '"
}

alt_dialog_parse_selection() {
    #
    #  Whiptail/dialog can only display selected keyword,
    #  so a post dialog step is needed matching keyword with intended
    #  action, and then perform it
    #
    wt_actions="$1"
    [ -z "$wt_actions" ] && {
        error_msg "alt_dialog_parse_selection() - called without param"
    }

    lst=$wt_actions
    i=0
    while true; do
        # POSIX way to handle array types of data
        section="${lst%%"${alt_dialog_action_separator}"*}" # up to first colon excluding it
        lst="${lst#*"${alt_dialog_action_separator}"}"      # after fist colon

        i=$((i + 1))
        [ "$i" -gt 50 ] && break
        [ -z "$section" ] && continue # skip blank lines

        key="$(echo "$section" | cut -d'|' -f 1 | awk '{$1=$1};1')"
        action="$(echo "$section" | cut -d'|' -f 2 | awk '{$1=$1};1')"

        if [ "$key" = "$menu_selection" ] && [ -n "$action" ]; then
            eval "$action"
            break
        fi
        [ "$lst" = "" ] && break # we have processed last group
    done
}

is_function_defined() {
    [ "$(command -v "$1")" = "$1" ]
}

#
#  Add one item to $uncached_menu
#
add_uncached_item() {
    _new_item="$menu_idx $menu_items"
    if [ -n "$uncached_menu" ]; then
        uncached_menu="$uncached_menu$uncached_item_splitter$_new_item"
    else
        uncached_menu="$_new_item"
    fi
    unset _new_item
}

menu_parse() {
    #
    #  Since the various menu entries have different numbers of params
    #  we first identify all the params used by the different options,
    #  only then can we continue if the min_vers does not match running tmux
    #

    [ "$menu_idx" -eq 1 ] && {
        [ -z "$menu_name" ] && error_msg "menu_parse() - menu_name not defined"
        # set prefix for item 1
        if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
            alt_dialog_prefix
        else
            tmux_dialog_prefix
        fi
    }

    [ -n "$menu_debug" ] && debug_print ">> menu_parse()"
    while [ -n "$1" ]; do
        min_vers="$1"
        shift
        action="$1"
        shift

        [ -n "$menu_debug" ] && debug_print "-- parsing an item [$min_vers] [$action]"
        case "$action" in

        "M")
            #  Open another menu
            key="$1"
            shift
            label="$1"
            shift
            menu="$1"
            shift

            ! tmux_vers_check "$min_vers" && continue

            #
            #  If menu is not full PATH, assume it to be a tmux-menus
            #  item
            #
            if echo "$menu" | grep -vq /; then
                menu="$d_items/$menu"
            fi

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] menu[$menu]"

            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_open_menu "$label" "$key" "$menu"
            else
                tmux_open_menu "$label" "$key" "$menu"
            fi
            ;;

        "C")
            #  direct tmux command - params: key label task [keep] [reload]
            key="$1"
            shift
            label="$1"
            shift
            cmd="$1"
            shift
            if [ "$1" = "keep" ]; then
                #  keep cmd as is
                keep_cmd=true
                shift # get rid of the keep cmd
            else
                keep_cmd=false
            fi

            ! tmux_vers_check "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] command[$cmd]"

            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_command "$label" "$key" "$cmd" "$keep_cmd"

            else
                tmux_command "$label" "$key" "$cmd" "$keep_cmd"
            fi
            unset keep_cmd
            ;;

        E)
            #
            #  Run external command - params: key label cmd
            #
            #  If no / is found in the script param, it will be prefixed with
            #  $d_scripts
            #  This means that if you give full path to something in this
            #  param, all scriptd needs to have full path pre-pended.
            #  For example help menus, which takes the full path to the
            #  current script, in order to be able to go back.
            #  For the normal case a name pointing to a script in the same
            #  dir as the current, this will be pre-pended automatically.
            #
            key="$1"
            shift
            label="$1"
            shift
            cmd="$1"
            shift

            ! tmux_vers_check "$min_vers" && continue

            #
            #  Expand relative PATH at one spot, before calling the
            #  various implementations
            #
            if echo "$cmd" | grep -vq /; then
                cmd="$d_scripts/$cmd"
            fi

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] command[$cmd]"

            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_external_cmd "$label" "$key" "$cmd"
            else
                tmux_external_cmd "$label" "$key" "$cmd"
            fi
            ;;

        "T")
            #  text line - params: txt
            txt="$1"
            shift

            ! tmux_vers_check "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "text line [$txt]"
            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_text_line "$txt"
            else
                tmux_text_line "$txt"
            fi
            ;;

        "S")
            #  Spacer line - params: none

            ! tmux_vers_check "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "Spacer line"

            # Whiptail/dialog does not have a concept of spacer lines
            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_spacer
            else
                tmux_spacer
            fi
            ;;

        *)
            # Error
            log_it "--- Menu created so far ---"
            log_it "$menu_items"
            error_msg "ERROR: [$1]"
            ;;

        esac
    done

    if $cfg_use_cache; then
        # clear cache (if present)
        log_it "Cashing ${current_script_no_ext}-$menu_idx"
        echo "$menu_items" >"$f_cache_file" || error_msg "Failed to write to: $f_cache_file"
    else
        add_uncached_item
    fi
    unset menu_items
}

update_wt_actions() {
    if $cfg_use_cache; then
        # clear actions
        [ "$menu_idx" -eq 1 ] && {
            rm -rf "$d_wt_actions"
            mkdir -p "$d_wt_actions"
        }
        if $is_dynamic_content; then
            echo "$wt_actions" >"$d_wt_actions/dynamic-$menu_idx"
        else
            echo "$wt_actions" >>"$d_wt_actions/static"
        fi
    else
        uncached_wt_actions="$uncached_wt_actions $wt_actions"
    fi

}

menu_generate_part() {
    menu_idx="$1"
    shift # get rid of the idx

    f_cache_file="$d_cache_file/$menu_idx"
    menu_parse "$@"

    [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && update_wt_actions
}

generate_menu_items_in_sorted_order() {
    #
    #  Since dynamic content is generated after static content
    #  $uncached_menu might be out of order, this extracts each item
    #  incrementally, in order to display the menu as intended
    #
    menu_items=""
    idx=1
    while true; do
        case "$uncached_menu" in
        "$idx "*)
            this_section="${uncached_menu#*"${idx}" }"
            this_section="${this_section%%"${uncached_item_splitter}"*}"
            menu_items="$menu_items $this_section"
            ;;
        *"$uncached_item_splitter$idx"*)
            this_section="${uncached_menu#*"${uncached_item_splitter}""${idx}" }"
            this_section="${this_section%%"${uncached_item_splitter}"*}"
            menu_items="$menu_items $this_section"
            ;;
        *) break ;; # no more sections
        esac
        idx=$((idx + 1))
    done
}

handle_static_cached() {
    #
    #  Calculate the relative path, to avoid name collitions if
    #  two items with same name in different rel paths are used
    #
    rel_path="$(relative_path "$d_current_script")"

    #  items/main.sh -> items_main
    current_script_no_ext="$(echo "$current_script" | sed 's/\.[^.]*$//')"
    d_cache_file="$d_cache/${rel_path}_$current_script_no_ext"

    [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && d_wt_actions="$d_cache_file/wt_actions"

    if [ ! -d "$d_cache_file" ] || [ "$(get_mtime "$0")" -gt "$(get_mtime "$d_cache_file")" ]; then
        # Ensure d_cache_file seems to be valid before doing erase
        case "$d_cache_file" in
        *"$plugin_name"*) ;;
        *) error_msg "d_cache_file seems wrong [$d_cache_file]" ;;
        esac

        rm -rf "$d_cache_file" || error_msg "Failed to remove: $d_cache_file"
        mkdir -p "$d_cache_file" || error_msg "Failed to create: $d_cache_file"
        # 1 - if not cached, cache static parts
        static_content
    fi

}

handle_dynamic() {
    if is_function_defined "dynamic_content"; then
        wt_actions_static="$wt_actions"
        wt_actions=""
        is_dynamic_content=true
        dynamic_content
        is_dynamic_content=false
        wt_actions="$wt_actions_static"
        unset wt_actions_static
    fi
}

sort_menu_items() {
    if $cfg_use_cache; then
        for file in "$d_cache_file"/*; do
            # skip special files
            fn="$(basename "$file")"
            [ "${#fn}" -gt "2" ] && continue

            # Check if the file is a regular file
            if [ -f "$file" ]; then
                # Read the content of the file and append it to the dialog variable
                menu_items="$menu_items $(cat "$file")"
            fi
        done
    else
        generate_menu_items_in_sorted_order
    fi
}

wt_cached_selection() {
    #
    #  Public variables
    #   all_wt_actions - lists all actions
    #
    # gathering action files from cache
    all_wt_actions=""
    for file in "$d_wt_actions"/*; do
        # skip special files
        fn="$(basename "$file")"
        # [ "$n" = "all" ] && continue # for debugging
        [ "${#fn}" -le "2" ] && continue # skip . & ..

        # Check if the file is a regular file
        if [ -f "$file" ]; then
            all_wt_actions="$all_wt_actions $(cat "$file")"
            #
            #  Read the content of the file and append it to
            #  the dialog variable
            #
            menu_items="$menu_items $(cat "$file")"
        fi
    done
}

handle_wt_selecion() {
    log_it "handle_wt_selecion($menu_selection)"
    if $cfg_use_cache; then
        wt_cached_selection
    else
        all_wt_actions="$uncached_wt_actions"
    fi
    alt_dialog_parse_selection "$all_wt_actions"
    unset all_wt_actions
}

display_menu() {
    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        # display whiptail menu
        menu_selection=$(eval "$menu_items" 3>&2 2>&1 1>&3)
        [ -n "$menu_selection" ] && handle_wt_selecion
        true #  hides none true exit if whiptail menu was cancelled
    else
        # Display time to generate menu
        disp_time="$(echo "$(safe_now) - $dh_t_mnu_processing_start" | bc)"
        log_it "Menu $current_script_no_ext - processing time:  $disp_time"

        dh_t_start="$(safe_now)"
        eval "$menu_items"

        ensure_menu_fits_on_screen
        unset dh_t_start
    fi
}

handle_menu() {
    #
    #  If a menu needs to handle a param, save it before sourcing this using:
    #  menu_param="$1"
    #  then process it in dynamic_content()
    #
    dh_t_mnu_processing_start="$(safe_now)"

    # 1 - Handle static parts, use cache if enabled and available
    if $cfg_use_cache; then
        handle_static_cached
    else
        static_content
    fi

    # 2 - Handle dynamic parts (if any)
    handle_dynamic

    # 3 - Gather each item in correct order
    sort_menu_items

    # 4 Display menu
    display_menu
}

#===============================================================
#
#   Main
#
#===============================================================

if [ -z "$D_TM_BASE_PATH" ]; then
    # helpers not yet sourced, so error_msg() not yet available
    msg="ERROR: dialog_handling.sh - D_TM_BASE_PATH must be set!"
    (
        echo
        echo "$msg"
        echo
    )
    exit 1
fi

# Only import if needed, checking a random variable
# shellcheck source=scripts/helpers.sh
[ -z "$tmux_vers" ] && . "$D_TM_BASE_PATH"/scripts/helpers.sh

[ -z "$TMUX" ] && error_msg "$plugin_name can only be used inside tmux!"

! tmux_vers_check 3.0 && FORCE_WHIPTAIL_MENUS=1

# not working right now, so disabeling
# [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && {
#     if [ -f "$f_wt_reload_script" ]; then
#         #
#         #  Delete old reload scripts, they will be created during execution
#         #  of a menu, and then if found executed at end of this one.
#         #  This is most likely a leftover due to some bug.
#         #

#         log_it "[$$]-----   Found reload script - deleting it"
#         rm -f "$f_wt_reload_script"
#     else
#         log_it "><>[$$]-----   no wt_reload_script found at start fo dialog_handling"
#     fi
# }

#
#  What alternate dialog app to use, if tmux built in dialogs will not
#  be used, options: whiptail dialog
#
dialog_app="whiptail"

alt_dialog_action_separator=":/:/:/:"

# only used when caching is disabled - @menus_use_cache is false
uncached_menu=""
uncached_wt_actions=""
uncached_item_splitter="||||"

#
#  If @menus_use_cache is not disabled, any cached items will not be
#  fully processed, so either disable caching, or clear the cache for
#  the itam before each run, unless of course your focus is to debug
#  cache handling.
#
menu_debug="" # Set to 1 to use echo 2 to use log_it

handle_menu

# e="$?"
# if [ "$e" -ne 0 ]; then
#     log_it "><> $current_script - dialog_handling - before wt_reload [$e]"
# fi

# not working right now, so disabeling
# [ "$FORCE_WHIPTAIL_MENUS" = 1 ] && {
#     if [ -f "$f_wt_reload_script" ]; then
#         #
#         #  in whiptail run-shell cant chain to another menu, so instead
#         #  reload script is written to a tmp file, and if it is found
#         #  it will be exeuted
#         #
#         log_it "[$$]+++++   Will run f_wt_reload_script[$f_wt_reload_script]"
#         /bin/sh "$f_wt_reload_script"
#     else
#         log_it "><>[$$]+++++   no wt_reload_script found at end of dialog handling"
#     fi
# }

# e="$?"
# if [ "$e" -ne 0 ]; then
#     log_it "><> $current_script - dialog_handling - exiting [$e]"
# fi

# log_it "[$(safe_now)] exiting dialog_handling.sh"
