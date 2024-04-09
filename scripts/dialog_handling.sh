#!/bin/sh
# This is sourced. Fake bang-path to help editors and linters
#  Global exclusions
#  shellcheck disable=SC2154
#
#   Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Parses params and generates tmux or whiptail menus
#  One variable is expected to have been set by the caller
#
#  D_TM_BASE_PATH - base location for tmux-menus plugin
#

debug_print() {
    case "$menu_debug" in
    1) echo "$1" ;;
    2) log_it "$1" ;;
    *)
        echo "$1"
        echo
        echo "ERROR: dialog_handling:debug_print()"
        echo "       \$menu_debug state invalid [$menu_debug] shoule be 1 or 2!"
        echo
        exit 1
        ;;
    esac
}

ensure_menu_fits_on_screen() {
    #
    #  Since tmux display-menu returns 0 even if it failed to display the menu
    #  due to not fitting on the screen, for now I check how long the menu
    #  was displayed. If the seconds didn't tick up, inspect required size vs
    #  actual screen size, and display a message if the menu doesn't fit.
    #
    #  Not perfect, but it kind of works. If you hit escape and instantly close
    #  the menu, a time diff zero might trigger this to check sizes, but if
    #  the menu fits on the screen, no size warning will be printed.
    #
    #  This gets slightly more complicated with tmux 3.3, since now tmux shrinks
    #  menus that don't fit due to width, so tmux might decide it can show a menu,
    #  but due to shrinkage, the hints in the menu might be so shortened that they
    #  are off little help explaining what this option would do.
    #
    [ "$t_start" -ne "$(date +'%s')" ] && return # should have been displayed

    #
    #  Param checks
    #
    set -- "ensure_menu_fits_on_screen() '$menu_name'" \
        "w:$req_win_width h:$req_win_height"

    cur_width="$($TMUX_BIN display -p "#{window_width}")"
    cur_height="$($TMUX_BIN display -p "#{window_height}")"

    if [ "$cur_width" -lt "$req_win_width" ] ||
        [ "$cur_height" -lt "$req_win_height" ]; then
        echo
        echo "menu '$menu_name'"
        echo "needs a screen size"
        echo "of at least $req_win_width x $req_win_height"
    fi
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
    #  shellcheck disable=SC2154
    menu_items="$TMUX_BIN display-menu -T \"#[align=centre] $menu_name \" \
        -x \"$menu_location_x\" -y \"$menu_location_y\""
}

tmux_open_menu() {
    label="$1"
    key="$2"
    menu="$3"

    # [ -n "$menu_debug" ] && debug_print "tmux_open_menu($label,$key,$menu)"

    # shellcheck disable=SC2089
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
    #  shellcheck disable=SC2089
    menu_items="$menu_items \"\""
}

alt_dialog_prefix() {
    #  shellcheck disable=SC2089
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

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$label" && return

    # filer out backslashes prefixing special chars
    key_action="$(echo "$key" | sed 's/\\//')"

    menu_items="$menu_items $key \"$label\""
    wt_actions="$wt_actions $key_action | $TMUX_BIN $cmd $alt_dialog_action_separator"
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
        error_msg "alt_dialog_parse_selection() - called without param" 1
    }

    lst=$wt_actions
    i=0
    while true; do
        # POSIX way to handle array types of data
        section="${lst%%"${alt_dialog_action_separator}"*}" # up to first colon excluding it
        lst="${lst#*"${alt_dialog_action_separator}"}"      # after fist colon

        #  strip leading and trailing spaces
        # section=${section#"${string%%[![:space:]]*}"}
        # section=${section%%[[:space:]]*}

        # echo ">> section [$section]"
        i=$((i + 1))
        # echo "i $i"
        [ "$i" -gt 50 ] && break
        [ -z "$section" ] && continue # skip blank lines
        # echo ">> reimainder [$lst]"

        key="$(echo "$section" | cut -d'|' -f 1 | awk '{$1=$1};1')"
        action="$(echo "$section" | cut -d'|' -f 2 | awk '{$1=$1};1')"

        # echo ">> section [$section]"
        # echo ">> name [$key] action [$action]"
        if [ "$key" = "$menu_selection" ]; then
            # echo "Will run whiptail triggered action:"
            # echo "$action"
            # sleep 1
            eval "$action"
            break
        fi
        [ "$lst" = "" ] && break # we have processed last group
        # echo
    done
}

is_function_defined() {
    # Use type command to check if the function is defined
    type "$1" 2>/dev/null | grep -q 'function'
    return $?
}

menu_parse() {
    #
    #  Since the various menu entries have different numbers of params
    #  we first identify all the params used by the different options,
    #  only then can we continue if the min_vers does not match running tmux
    #

    [ "$menu_idx" -eq 1 ] && {
        [ -z "$menu_name" ] && error_missing_param "menu_name"
        # set prefix for item 1
        if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
            alt_dialog_prefix
        else
            [ -z "$req_win_width" ] && error_missing_param "req_win_width"
            [ -z "$req_win_height" ] && error_missing_param "req_win_height"
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

        "M") #  Open another menu
            key="$1"
            shift
            label="$1"
            shift
            menu="$1"
            shift

            ! tmux_vers_compare "$min_vers" && continue

            #
            #  If menu is not full PATH, assume it to be a tmux-menus
            #  item
            #
            if echo "$menu" | grep -vq /; then
                menu="$D_TM_ITEMS/$menu"
            fi

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] menu[$menu]"

            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_open_menu "$label" "$key" "$menu"
            else
                tmux_open_menu "$label" "$key" "$menu"
            fi
            ;;

        "C") #  direct tmux command - params: key label task
            key="$1"
            shift
            label="$1"
            shift
            cmd="$1"
            shift

            ! tmux_vers_compare "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] command[$cmd]"

            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_command "$label" "$key" "$cmd"
            else
                tmux_command "$label" "$key" "$cmd"
            fi
            ;;

        "E") #  Run external command - params: key label cmd
            #
            #  If no / is found in the script param, it will be prefixed with
            #  $D_TM_SCRIPTS
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

            ! tmux_vers_compare "$min_vers" && continue

            #
            #  Expand relative PATH at one spot, before calling the
            #  various implementations
            #
            if echo "$cmd" | grep -vq /; then
                cmd="$D_TM_SCRIPTS/$cmd"
            fi

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] command[$cmd]"

            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_external_cmd "$label" "$key" "$cmd"
            else
                tmux_external_cmd "$label" "$key" "$cmd"
            fi
            ;;

        "T") #  text line - params: txt
            txt="$1"
            shift

            ! tmux_vers_compare "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "text line [$txt]"
            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_text_line "$txt"
            else
                tmux_text_line "$txt"
            fi
            ;;

        "S") #  Spacer line - params: none

            ! tmux_vers_compare "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "Spacer line"

            # Whiptail/dialog does not have a concept of spacer lines
            if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                alt_dialog_spacer
            else
                tmux_spacer
            fi
            ;;

        *) # Error
            echo
            echo "ERROR: [$1]"
            echo "--- Menu created so far ---"
            echo "$menu_items"
            exit 1
            ;;

        esac
    done

    if $use_cache; then
        # clear cache (if present)
        echo "$menu_items" >"$f_cache_file" || error_msg "Failed to write to: $f_cache_file"
    else
        _new_item="$menu_idx $menu_items"
        if [ -n "$uncached_menu" ]; then
            uncached_menu="$uncached_menu$uncached_item_splitter$_new_item"
        else
            uncached_menu="$_new_item"
        fi
        unset _new_item
    fi
    unset menu_items
}

menu_generate_part() {
    menu_idx="$1"
    shift # get rid of the idx
    f_cache_file="$d_cache_file/$menu_idx"
    menu_parse "$@"

    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        if $use_cache; then
            # clear actions
            [ "$menu_idx" -eq 1 ] && rm -f "$d_cache_file/wt_actions"
            echo "$wt_actions" >>"$d_cache_file/wt_actions"
        else
            uncached_wt_actions="$uncached_wt_actions $wt_actions"
        fi
    fi
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

handle_menu() {
    #
    #  If a menu needs to handle a param, save it before sourcing this using:
    #  menu_param="$1"
    #  then process it in dynamic_content()
    #

    # 1 - Handle static parts, use cache if enabled and available
    if $use_cache; then
        #  Calculate the relative path, to avoid name collitions if
        #  two items with same name in different rel paths are used
        rel_path=$(echo "$d_current_script" | sed "s|$D_TM_BASE_PATH/||")

        #  items/main.sh -> items_main
        d_cache_file="$D_TM_MENUS_CACHE/${rel_path}_$(basename "$0" | sed 's/\.[^.]*$//')"

        if
            [ ! -f "$d_cache_file"/1 ] ||
                [ "$(get_mtime "$0")" -gt "$(get_mtime "$d_cache_file"/1)" ]
        then
            # Ensure d_cache_file seems to be valid before doing erase
            case "$d_cache_file" in
            *tmux-menus*) ;;
            *) error_msg "d_cache_file seems wrong [$d_cache_file]" ;;
            esac

            rm -rf "$d_cache_file" || error_msg "Failed to remove: $d_cache_file"
            mkdir -p "$d_cache_file" || error_msg "Failed to create: $d_cache_file"
            # 1 - if not cached, cache static parts
            static_content
        fi
    else
        static_content
    fi

    # 2 - Handle dynamic parts (if any)
    if is_function_defined "dynamic_content"; then
        dynamic_content
    fi

    # 3 - Gather each item in correct order
    if $use_cache; then
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

    # 4 Display menu
    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        #  shellcheck disable=SC2294
        menu_selection=$(eval "$menu_items" 3>&2 2>&1 1>&3)
        # echo "selection[$menu_selection]"
        if $use_cache; then
            all_wt_actions="$(cat "$d_cache_file/wt_actions")"
        else
            all_wt_actions="$uncached_wt_actions"
        fi
        alt_dialog_parse_selection "$all_wt_actions"
    else
        #  shellcheck disable=SC2034
        t_start="$(date +'%s')"
        # tmux can trigger actions by it self
        #  shellcheck disable=SC2068,SC2294
        eval "$menu_items"
        ensure_menu_fits_on_screen
    fi
}

#===============================================================
#
#   Main
#
#===============================================================

if [ -z "$D_TM_BASE_PATH" ]; then
    # utils not yet sourced, so error_missing_param() not yet available
    echo "ERROR: dialog_handling.sh - D_TM_BASE_PATH must be set!"
    exit 1
fi

#  shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/utils.sh

[ -z "$TMUX" ] && error_msg "tmux-menus can only be used inside tmux!"

! tmux_vers_compare 3.0 && FORCE_WHIPTAIL_MENUS=1

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

menu_debug="" # Set to 1 to use echo 2 to use log_it

handle_menu
