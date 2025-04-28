#!/bin/sh
# This is sourced. Fake bang-path to help editors and linters
# shellcheck disable=SC2154
#
#   Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Parses params and generates tmux or whiptail menus
#  One variable is expected to have been set by the caller
#
#  Optional params:
#    1 min screen width required for menu
#    2 min screen height required for menu
#  If provided, screen size is chcecked and

#  Menus are expected to define the following:
#   D_TM_BASE_PATH  - base location for tmux-menus plugin
#   menu_name       - Name of menu
#   menu_min_vers   - If set, min version of tmux menu supports
#   static_content()    - all static menu fragments, that can be cached
#   dynamic_content()   - all dynamic fragments, will be regenerated each time
#

#---------------------------------------------------------------
#
#   Common
#
#---------------------------------------------------------------

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
    1) print_stderr "$1" ;;
    2) log_it "$1" ;;
    *)
        error_msg_safe "$menu_debug state invalid [$menu_debug] should be 1 or 2! p1[$1]"
        ;;
    esac
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

is_function_defined() {
    [ "$(command -v "$1")" = "$1" ]
}

update_wt_actions() {
    if $cfg_use_cache; then
        [ "$menu_idx" -eq 1 ] && {
            # clear menu actions
            safe_remove "$d_wt_actions"
        }
        mkdir -p "$d_wt_actions"
        if $is_dynamic_content; then
            echo "$wt_actions" >"$d_wt_actions/dynamic-$menu_idx"
        else
            echo "$wt_actions" >>"$d_wt_actions/static"
        fi
    else
        uncached_wt_actions="$uncached_wt_actions $wt_actions"
    fi

}

#---------------------------------------------------------------
#
#   Called from menu items
#
#---------------------------------------------------------------

menu_generate_part() {
    # Generate one menu segment
    # log_it "menu_generate_part($1)"

    $is_dynamic_content && dynamic_content_found=true
    $all_helpers_sourced || source_all_helpers "menu_generate_part()"

    menu_idx="$1"
    shift # get rid of the idx

    $cfg_use_cache && f_cache_file="$d_menu_cache/$menu_idx"
    # log_it "><> menu_generate_part($menu_idx) using cache: $f_cache_file"
    menu_parse "$@"

    $cfg_use_whiptail && update_wt_actions
}

#---------------------------------------------------------------
#
#   Processing menu items
#
#---------------------------------------------------------------

mnu_prefix() {

    _title="$(echo "$cfg_format_title" | sed "s/#{@menu_name}/$menu_name/g")"
    menu_items="$TMUX_BIN display-menu -T $_title -x '$cfg_mnu_loc_x' -y '$cfg_mnu_loc_y'"

    tmux_vers_check 3.4 && {
        # Styling is supported
        [ -n "$cfg_border_type" ] && {
            menu_items="$menu_items -b $cfg_border_type"
        }
        [ -n "$cfg_simple_style_selected" ] && {
            menu_items="$menu_items -H $cfg_simple_style_selected"
        }
        [ -n "$cfg_simple_style" ] && menu_items="$menu_items -s $cfg_simple_style"
        [ -n "$cfg_simple_style_border" ] && {
            menu_items="$menu_items -S $cfg_simple_style_border"
        }
    }
}

mnu_open_menu() {
    label="$1"
    key="$2"
    menu="$3"

    # [ -n "$menu_debug" ] && debug_print "mnu_open_menu($label,$key,$menu)"

    menu_items="$menu_items \"$label\" $key \"run-shell '$menu'\""
}

mnu_external_cmd() {
    label="$1"
    key="$2"
    # cmd="$3"
    cmd="$(echo "$3" | sed 's/"/\\"/g')" # replace embedded " with \"
    # [ -n "$menu_debug" ] && debug_print "mnu_external_cmd($label,$key,$cmd)"

    #
    #  needs to be prefixed with run-shell, since this is triggered by
    #  tmux
    #
    menu_items="$menu_items \"$label\" $key 'run-shell \"$cmd\"'"
}

mnu_command() {
    label="$1"
    key="$2"
    # cmd="$3"
    cmd="$(echo "$3" | sed 's/"/\\"/g')" # replace embedded " with \"

    # [ -n "$menu_debug" ] && debug_print "mnu_command($label,$key,$cmd)"
    menu_items="$menu_items \"$label\" $key \"$cmd\""
}

mnu_text_line() {
    txt="$1"
    menu_items="$menu_items \"$txt\" '' ''"
}

mnu_spacer() {
    menu_items="$menu_items \"\""
}

alt_prefix() {
    case "$cfg_alt_menu_handler" in
    whiptail | dialog) ;;
    *) error_msg "Un-recognized cfg_alt_menu_handler: [$cfg_alt_menu_handler]" ;;
    esac
    menu_items="$cfg_alt_menu_handler --title \"$menu_name\"  --menu \"\" 0 0 0 "
}

alt_open_menu() {
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
    wt_actions="$wt_actions $key | $menu $external_action_separator"
}

alt_external_cmd() {
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
    wt_actions="$wt_actions $key | $cmd $external_action_separator"
}

alt_command() {
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
        wt_actions="$wt_actions $key_action | tmux_error_handler $cmd $external_action_separator"
    else
        wt_actions="$wt_actions $key_action | tmux_error_handler $cmd $external_action_separator"
    fi
}

alt_text_line() {
    #
    #  filtering out tmux #{...} sequences and initial -
    #  labels starting with - indicates disabled feature,
    #  whiptail can not handle labels starting with -, so remove it
    #
    txt="$(echo "$1" | sed 's/^[-]//' | sed 's/#\[[^]]*\]//g')"

    [ "$(printf '%s' "$txt" | cut -c1)" = "-" ] && {
        txt=" ${txt#?}"
    }

    menu_items="$menu_items '' \"$txt\""
}

alt_spacer() {
    menu_items="$menu_items '' ' '"
}

add_uncached_item() {
    # log_it "add_uncached_item()"
    #  Add one item to $uncached_menu
    _new_item="$menu_idx $menu_items"
    if [ -n "$uncached_menu" ]; then
        uncached_menu="$uncached_menu$uncached_item_splitter$_new_item"
    else
        uncached_menu="$_new_item"
    fi
}

verify_menu_key() {
    _key="$1"
    _item="$2"
    [ -z "$_key" ] && error_msg_safe "Key was empty for: $_item in: $0"
}

menu_parse() {
    #
    #  Since the various menu entries have different numbers of params
    #  we first identify all the params used by the different options,
    #  only then can we continue if the min_vers does not match running tmux
    #
    # log_it "><> mennu_parse()"

    [ "$menu_idx" -eq 1 ] && {
        # set prefix for item 1
        if $cfg_use_whiptail; then
            alt_prefix
        else
            mnu_prefix
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

            verify_menu_key "$key" "tmux command: $cmd"

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] command[$cmd]"

            if $cfg_use_whiptail; then
                alt_command "$label" "$key" "$cmd" "$keep_cmd"
            else
                mnu_command "$label" "$key" "$cmd" "$keep_cmd"
                $b_do_show_cmds && sc_show_cmd "$TMUX_BIN $cmd"
            fi
            ;;

        E)
            #
            #  Run external command - params: key label cmd
            #
            #  If no initial / is found in the script param, it will be prefixed with
            #  $d_scripts
            #  This means that if you give full path to something in this
            #  param, all scriptd needs to have full path prepended.
            #  For example help menus, which takes the full path to the
            #  current script, in order to be able to go back.
            #  For the normal case a name pointing to a script in the same
            #  dir as the current, this will be prepended automatically.
            #
            key="$1"
            shift
            label="$1"
            shift
            cmd="$1"
            shift

            verify_menu_key "$key" "external command: $cmd"

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] command[$cmd]"

            if $cfg_use_whiptail; then
                alt_external_cmd "$label" "$key" "$cmd"
            else
                mnu_external_cmd "$label" "$key" "$cmd"
                $b_do_show_cmds && [ "$key" != "!" ] && sc_show_cmd "$cmd"
            fi
            ;;

        "M")
            #  Open another menu
            key="$1"
            shift
            label="$1"
            shift
            menu="$1"
            shift

            verify_menu_key "$key" "$menu"

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

            #
            #  If menu is not full PATH, assume it to be a tmux-menus
            #  item
            #
            echo "$menu" | grep -vq / && menu="$d_items/$menu"

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] menu[$menu]"

            if $cfg_use_whiptail; then
                alt_open_menu "$label" "$key" "$menu"
            else
                mnu_open_menu "$label" "$key" "$menu"
            fi
            ;;

        "T")
            #  text line - params: txt
            txt="$1"
            shift

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "text line [$txt]"
            if $cfg_use_whiptail; then
                alt_text_line "$txt"
            else
                mnu_text_line "$txt"
            fi
            ;;

        "S")
            #  Spacer line - params: none

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "Spacer line"

            # Whiptail/dialog does not have a concept of spacer lines
            if $cfg_use_whiptail; then
                alt_spacer
            else
                mnu_spacer
            fi
            ;;

        *)
            # Error
            log_it "  menu_parse()  ---  Menu created so far  ---"
            log_it "$menu_items"
            error_msg_safe "ERROR: [$1]"
            ;;

        esac
    done

    if $cfg_use_cache; then
        log_it_minimal "Caching: $(relative_path "$f_cache_file")"
        echo "$menu_items" >"$f_cache_file" || {
            error_msg_safe "Failed to write to: $f_cache_file"
        }
    else
        add_uncached_item
    fi
    unset menu_items
}

#---------------------------------------------------------------
#
#   Preparing menu
#
#---------------------------------------------------------------

set_menu_env_variables() {
    # log_it "set_menu_env_variables()"
    #
    #  Needs to be done for every menu even if caching is done,
    #  since the cache might refer to tmux variables like menu_name
    #
    #  Per menu overrides of configuration
    #
    [ -n "$override_title" ] && cfg_format_title="$override_title"
    [ -n "$override_selected" ] && cfg_simple_style_selected="$override_selected"
    [ -n "$override_border" ] && cfg_simple_style_border="$override_border"
    [ -n "$override_style" ] && cfg_simple_style="$override_style"
    [ -n "$override_next" ] && cfg_nav_next="$override_next"
    [ -n "$override_prev" ] && cfg_nav_prev="$override_prev"
    [ -n "$override_home" ] && cfg_nav_home="$override_home"

    # allow for having shorter variable names in menus
    # shellcheck disable=SC2034
    nav_next="$cfg_nav_next"
    # shellcheck disable=SC2034
    nav_prev="$cfg_nav_prev"
    # shellcheck disable=SC2034
    nav_home="$cfg_nav_home"

    external_action_separator=":/:/:/:"
    if $cfg_use_cache; then
        # Include relative script path in cache folder name to avoid name collisions
        #  items/main.sh -> cache/items/main.sh/
        # [ "$env_initialized" -lt 2 ] && error_msg_safe "env not fully initialized"
        d_menu_cache="$d_cache/$(relative_path "$0")"

        $cfg_use_whiptail && d_wt_actions="$d_menu_cache/wt_actions"
    else
        uncached_menu=""
        uncached_wt_actions=""
        uncached_item_splitter="||||"
    fi

    if $cfg_use_whiptail; then
        #
        #  I haven't been able do to menu reload with whiptail/dialog yet,
        #  so disabled for now
        #
        # log_it "><> whiptail - disabling menu_reload"
        # menu_reload="\; run-shell \\\"$m$d_scripts/external_dialog_trigger.sh $0\\\""
        # menu_reload="\; run-shell \\\"$0\\\""
        menu_reload=""
        reload_in_runshell=""
    else
        # External commands normally needs to use reload_in_runshell!

        # shellcheck disable=SC2034
        menu_reload="; run-shell $0"

        # Use this for reloads already embedded in a run-shell command
        # shellcheck disable=SC2034
        reload_in_runshell=" ; $0"
    fi
}

static_files_reduction() {
    # if only static content was generated, compact all parts into one
    # for quicker cache loading
    $dynamic_content_found && {
        error_msg "static_files_reduction() called when dynamic content was generated"
    }
    # log_it "static_files_reduction()"
    _items="$(find "$d_menu_cache" -maxdepth 1 -type f | wc -l)"

    [ "$_items" -gt 1 ] && {
        sort_menu_items
        find "$d_menu_cache" -maxdepth 1 -type f | while IFS= read -r f_name; do
            safe_remove "$f_name"
            echo "$menu_items" >"$d_menu_cache/1"
        done
        unset menu_items # clear it
    }
}

cache_static_content() {
    #
    # Ensure the cache folder is present, and newer than the menu file, making sure
    # obsolete cache is dropped.
    #
    # log_it "cache_static_content() - [$0] d_menu_cache [$d_menu_cache]"
    if [ ! -d "$d_menu_cache" ] || [ "$(get_mtime "$0")" -gt "$(get_mtime "$d_menu_cache")" ]; then
        # Cache is missing or obsolete, regenerate it
        # log_it "  regenerate cache for: $d_menu_cache"
        $all_helpers_sourced || {
            source_all_helpers "cache_static_content() - cache error"
        }
        safe_remove "$d_menu_cache"
        mkdir -p "$d_menu_cache" || error_msg_safe "Failed to create: $d_menu_cache"

        is_function_defined "static_content" && {
            static_content
            static_cache_updated=true
        }
    fi
}

handle_dynamic() {
    # log_it "handle_dynamic()"
    is_function_defined "dynamic_content" && {
        wt_actions_static="$wt_actions"
        wt_actions=""
        is_dynamic_content=true
        mkdir -p "$d_menu_cache" # needed if menu is purely dynamic
        dynamic_content
        is_dynamic_content=false
        wt_actions="$wt_actions_static"
    }
}

generate_menu_items_in_sorted_order() {
    #
    # Since dynamic_content is generated after static_content, it can't be assumed
    # that the menu fragments were generated in proper order, in addition the
    # display_commands_toggle segment will not be generated when caching is disabled.
    # adding gaps in the segment sequence.
    #
    # One of the no-cache assumptions is that tmp files can't be used, so all this put
    # together, leads to this rather hackish in-memory implementation of sorting
    # the uncached_menu clearly lots of room for improvement...
    #
    gmi_entries=""

    gmi_rest="$uncached_menu"
    while :; do
        case "$gmi_rest" in
        *"$uncached_item_splitter"*)
            gmi_part=${gmi_rest%%"$uncached_item_splitter"*}
            gmi_rest=${gmi_rest#*"$uncached_item_splitter"}
            ;;
        *)
            gmi_part=$gmi_rest
            gmi_rest=''
            ;;
        esac

        idx=$(printf "%s" "$gmi_part" | cut -d' ' -f1)
        gmi_body=$(printf "%s" "$gmi_part" | cut -d' ' -f2-)
        # Save as index<TAB>content
        gmi_entries="$gmi_entries
$idx	$gmi_body"

        [ -z "$gmi_rest" ] && break
    done

    # Now sort and print, skipping initial empty line
    menu_items="$(
        printf "%s\n" "$gmi_entries" | sed 1d | sort -n | while IFS='	' read -r idx this_section; do
            printf '%s' "$this_section" # send it back to the script
        done
    )"
}

sort_menu_items() {
    # log_it "sort_menu_items()"
    if $cfg_use_cache; then
        for f_name in "$d_menu_cache"/*; do
            # log_it "><> sort_menu_items() - processing: $f_name"

            # skip special files
            b_name=${f_name##*/} # basename equiv
            [ "${#b_name}" -gt "2" ] && continue

            # Read the content of the file and append it to the menu_items variable
            menu_items="$menu_items $(cat "$f_name")"
        done
    else
        # _s="[dialog_handling] sort_menu_items()"
        # _s="$_s - calling: generate_menu_items_in_sorted_order"
        generate_menu_items_in_sorted_order
    fi
}

verify_menu_runable() {
    # Check that menu starts with a menu handling cmd, if not most likely due to
    # menu idx 1 not generated, but could be other causes. eithe way this menu
    # will be displayable...
    # log_it "verify_menu_runable()"

    # Remove leading spaces
    while [ "${menu_items# }" != "$menu_items" ]; do
        menu_items=${menu_items# }
    done

    # extract first word
    _actual_first="${menu_items%% *}"

    if [ -n "$cfg_alt_menu_handler" ]; then
        _mnu_first="$cfg_alt_menu_handler"
    else
        _mnu_first="${TMUX_BIN%% *}"
    fi
    [ "$_actual_first" = "$_mnu_first" ] || {
        msg="The processed menu should start with a menu handler."
        msg="$msg\nIn the current environment this was expected:"
        msg="$msg\n\n  $_mnu_first"
        msg="$msg\n\nThis was found:"
        msg="$msg\n\n  $_actual_first"
        msg="$msg\n\nWas no part 1 created?\n"
        msg="$msg\nThe menu handler and other menu definitions like title"
        msg="$msg and styling\nare prepended to the part defined by:"
        msg="$msg\n\n  menu_generate_part 1 \""'$@'"\"\n"
        msg="$msg\nGenerated menu:\n"

        # filter ; ini order not to execute when displaying the error msg
        escaped="$(printf '%s' "$menu_items" | sed 's/;//g')"
        error_msg_safe "$msg\n$escaped"
    }
}

prepare_menu() {
    #
    #  If a menu needs to handle a param, save it before sourcing this using:
    #  menu_param="$1"
    #  then process it in dynamic_content()
    #
    # log_it "prepare_menu()"

    set_menu_env_variables

    # 1 - Handle static parts, use cache if enabled and available
    if $cfg_use_cache; then
        cache_static_content
    else
        is_function_defined "static_content" && static_content
    fi

    # 2 - Handle dynamic parts (if any)
    handle_dynamic

    $static_cache_updated && ! $dynamic_content_found && static_files_reduction

    # 3 - Gather each item in correct order
    sort_menu_items
    verify_menu_runable
}

#---------------------------------------------------------------
#
#   Display menu and handling Screen size
#
#---------------------------------------------------------------

check_screen_size() {
    #
    #  Only consider checking win size if not whiptail/dialog, since they
    #  can scroll menus that don't fit the screen
    #
    #  Only checks if menu_width and or menu_height has been set
    #
    #  Examining client_height instead of menu_height, includes the entire terminal
    #  including lines covered by a status bar. Since Menus can cover the status bar
    #  This gives the actual screen limits for menus
    #
    $cfg_use_whiptail && return 0
    # log_it "check_screen_size()"

    $all_helpers_sourced || source_all_helpers "check_screen_size()"

    [ -n "$menu_height" ] && {
        [ -z "$current_screen_rows" ] && get_screen_size_variables # only get if not defined
        [ "$menu_height" -gt "$current_screen_rows" ] && {
            _warn="$(relative_path "$0") aborted, win height > actual: "
            _warn="$_warn $menu_height > $current_screen_rows"
            log_it "$_warn"
            return 1
        }
    }
    [ -n "$menu_width" ] && {
        [ -z "$current_screen_cols" ] && get_screen_size_variables # only get if not defined
        [ "$menu_width" -gt "$current_screen_cols" ] && {
            _warn="menu display aborted, win width > actual: "
            _warn="$_warn $menu_width > $current_screen_cols"
            log_it "$_warn"
            return 1
        }
    }
    return 0
}

wt_cached_selection() {
    #
    #  Public variables
    #   all_wt_actions - lists all actions
    #
    # log_it "wt_cached_selection()"
    # gathering action files from cache
    all_wt_actions=""
    for file in "$d_wt_actions"/*; do
        # skip special files
        fn="$(basename "$file")"
        # [ "$n" = "all" ] && continue # for debugging
        [ "${#fn}" -le "2" ] && continue # skip . & ..

        # Check if the file is a regular file
        [ -f "$file" ] && {
            all_wt_actions="$all_wt_actions $(cat "$file")"
            #
            #  Read the content of the file and append it to
            #  the dialog variable
            #
            menu_items="$menu_items $(cat "$file")"
        }
    done
}

alt_parse_selection() {
    #
    #  Whiptail/dialog can only display selected keyword,
    #  so a post dialog step is needed matching keyword with intended
    #  action, and then perform it
    #
    wt_actions="$1"
    # log_it "alt_parse_selection($wt_action)"
    [ -z "$wt_actions" ] && {
        error_msg_safe "alt_parse_selection() - called without param"
    }

    lst=$wt_actions
    i=0
    while true; do
        # POSIX way to handle array types of data
        section="${lst%%"${external_action_separator}"*}" # up to first colon excluding it
        lst="${lst#*"${external_action_separator}"}"      # after fist colon

        i=$((i + 1))
        [ "$i" -gt 50 ] && break
        [ -z "$section" ] && continue # skip blank lines

        key="$(echo "$section" | cut -d'|' -f 1 | awk '{$1=$1};1')"
        action="$(echo "$section" | cut -d'|' -f 2 | awk '{$1=$1};1')"

        [ "$key" = "$menu_selection" ] && [ -n "$action" ] && {
            $all_helpers_sourced || source_all_helpers "alt_parse_selection()"
            eval "$action"
            break
        }
        [ -z "$lst" ] && break # we have processed last group
    done
}

handle_wt_selecion() {
    # log_it "handle_wt_selecion($menu_selection)"
    if $cfg_use_cache; then
        wt_cached_selection
    else
        all_wt_actions="$uncached_wt_actions"
    fi
    alt_parse_selection "$all_wt_actions"
    unset all_wt_actions
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
    # Display time menu was shown
    safe_now
    disp_time="$(echo "$t_now - $dh_t_start" | bc)"

    # log_it "ensure_menu_fits_on_screen() Menu $bn_current_script - Display time:  $disp_time ($t_minimal_display_time)"
    [ "$(echo "$disp_time < $t_minimal_display_time" | bc)" -eq 1 ] && {
        $all_helpers_sourced || {
            source_all_helpers "ensure_menu_fits_on_screen()  short display, give warning"
        }
        #
        # Save menu that failed to show, helpful to try to figure out why it failed
        #
        # _f_mnu="$d_tmp"/tmux-menus-failed-to-show.cmd
        # echo "$menu_items" >"$_f_mnu"
        # log_it "Failed menu saved to: $_f_mnu"

        f_menu_rel="$(relative_path "$0")"
        if [ -n "$menu_width" ] && [ -n "$menu_height" ]; then
            _s="$f_menu_rel: screen mins: ${menu_width}x$menu_height"
        elif [ -n "$menu_height" ]; then
            _s="$f_menu_rel: Height required: $menu_height"
        elif [ -n "$menu_width" ]; then
            _s="$f_menu_rel: Width required: $menu_width"
        else
            # log_it "display time was: $disp_time"
            _s="$f_menu_rel: Screen might be too small - menu closed after $disp_time"
        fi
        error_msg_safe "$_s"
    }
}

clear_prep_disp_status() {
    safe_now
    display_command_label
    log_it "$(relative_path "$0") - Preparing $_lbl took: $(
        echo "$t_now - $t_show_cmds" | bc
    )s"

    if tmux_vers_check 3.2; then
        tmux_error_handler display-message -d 1 ""
    else
        # Older tmuxes don't have the time out feature, so the
        # empty message will remain potentially until a key-press
        tmux_error_handler display-message ""
    fi
}

display_menu() {
    # log_it "display_menu()"
    # Display time to generate menu

    case "$TMUX_MENUS_SHOW_CMDS" in
    "1" | "2") clear_prep_disp_status ;;
    *) ;;
    esac

    [ -n "$cfg_log_file" ] && {
        # If logging is disabled - no point in generating this log msg

        safe_now
        _t="$(echo "$t_now - $t_script_start" | bc)"

        _m="Menu $(relative_path "$0")"
        _m="$_m - processing time:  $_t"
        log_it_minimal "$_m"
    }

    [ "$TMUX_MENUS_NO_DISPLAY" = "1" ] && return

    if $cfg_use_whiptail; then
        # display whiptail menu
        menu_selection=$(eval "$menu_items" 3>&2 2>&1 1>&3)
        [ -n "$menu_selection" ] && handle_wt_selecion
        true #  hides none true exit if whiptail menu was cancelled
    else
        safe_now dh_t_start
        eval "$menu_items"

        ensure_menu_fits_on_screen
    fi
}

exit_if_menu_doesnt_fit_screen() {
    # Useful for hints, if it doesn't fit on screen, just silently skip this menu
    # log_it "exit_if_menu_doesnt_fit_screen()"
    check_screen_size && return
    exit 0 # menu won't fit on screen, exit nicely without any warnings/errors
}

prepare_show_commands() {
    # Do not use normal caching, build custom menu including cmds under each
    # action item
    # log_it "prepare_show_commands()"

    $all_helpers_sourced || source_all_helpers "prepare_show_commands()"

    # Do this before the timer is started, otherwise the first usage of show commands
    # will always be slower
    $all_helpers_sourced || source_all_helpers "prepare_show_commands"
    [ ! -f "$f_cached_tmux_key_binds" ] && {
        log_it "Creating: $f_cached_tmux_key_binds"
        # Filtering out all key binds displaying a menu, since they won't be relevant
        $TMUX_BIN list-keys | grep -iv display-menu >"$f_cached_tmux_key_binds"
    }

    safe_now t_show_cmds
    cfg_use_cache=false
    b_do_show_cmds=true
    display_command_label
    tmux_error_handler display-message "Preparing $_lbl ..."
    # shellcheck source=scripts/show_cmd.sh
    . "$D_TM_BASE_PATH"/scripts/show_cmd.sh
}

display_commands_toggle() {
    menu_part="$1"
    # log_it "display_commands_toggle($menu_part)"
    [ -z "$menu_part" ] && error_msg "add_display_commands() - called with no param"

    # In case we got here via dynamic_content()
    $all_helpers_sourced || source_all_helpers "display_commands_toggle()"

    display_command_label
    set -- \
        0.0 E ! "$_lbl_next" "TMUX_MENUS_SHOW_CMDS='$_idx_next' $0"

    menu_generate_part "$menu_part" "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -z "$D_TM_BASE_PATH" ] && {
    # helpers not yet sourced, so error_msg_safe() not yet available
    msg="ERROR: dialog_handling.sh - D_TM_BASE_PATH must be set!"
    (
        echo
        echo "$msg"
        echo
    )
    exit 1
}

# Only import if needed, checking a random variable
[ -z "$d_scripts" ] && {
    # shellcheck source=scripts/helpers_minimal.sh
    . "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh
}

is_dynamic_content=false    # indicates if a dynamic content segment is being processed
dynamic_content_found=false # indicate dynamic content was generated
static_cache_updated=false  # used to decide if static cache file reduction should happen
b_do_show_cmds=false

[ -z "$TMUX_MENUS_SHOW_CMDS" ] && ! $cfg_use_cache && {
    # always disabled if cache is not used
    cfg_display_cmds=false
    # unset TMUX_MENUS_SHOW_CMDS
}

# in case this was set when whiptail is used
$cfg_use_whiptail && unset TMUX_MENUS_SHOW_CMDS

[ -n "$TMUX_MENUS_SHOW_CMDS" ] && {
    # override @menus_display_commands setting, if cache is enabled
    cfg_display_cmds=true
}

case "$TMUX_MENUS_SHOW_CMDS" in
"1" | "2") prepare_show_commands ;;
*) ;;
esac

# Some sanity checks
[ "$TMUX_MENUS_NO_DISPLAY" != "1" ] && {
    [ -z "$TMUX" ] && error_msg_safe "$plugin_name can only be used inside tmux!"
}
[ -z "$menu_name" ] && error_msg_safe "menu_name not defined"
[ -n "$menu_min_vers" ] && {
    # Abort with error if tmux version is insufficient for this menu
    tmux_vers_check "$menu_min_vers" || {
        error_msg_safe "$(relative_path "$0") needs tmux: $menu_min_vers"
    }
}

[ "$skip_oversized" = "1" ] && {
    # To minimize overhead, the normal case is to rely on oversized menus instantly
    # closing and the displayal of the warning: Screen might be too small
    #
    # only do this check if it is requested, this assumes at least one of
    # menu_height or menu_width must have been set
    #
    [ -z "$menu_height" ] && [ -z "$menu_width" ] && {
        _m="With neither menu_height or menu_width defined"
        _m="$_m\n It is not possible to check if menu fits on screen"
        error_msg "$_m"
    }
    exit_if_menu_doesnt_fit_screen
}

#
#  If @menus_use_cache is not disabled, any cached items will not be
#  fully processed, so either disable caching, or clear the cache for
#  the itam before each run, unless of course your focus is to debug
#  cache handling.
#
menu_debug="" # Set to 1 to use echo 2 to use log_it

prepare_menu
display_menu

# log_it "[$$]   COMPLETED: scripts/dialog_handling.sh"
return 0 # ensuring this exits true
