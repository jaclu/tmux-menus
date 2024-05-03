#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  shellcheck disable=SC2154

#  Should point to tmux-menux plugin
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")" && pwd)

#  shellcheck source=/dev/null
. "$D_TM_BASE_PATH"/scripts/utils.sh

if [ -s "$f_cached_tmux" ]; then
    tmux_vers_in_cache="$(cat "$f_cached_tmux")"
else
    tmux_vers_in_cache=""
fi

echo "Current tmux:$tmux_vers - cache built for: $tmux_vers_in_cache"
#
#  Clear cache if it was not created with current tmux version,
#  Then tag cachdir with current tmux version
#
[ "$tmux_vers" = "$tmux_vers_in_cache" ] || {
    log_it "Clearing incompatible cache"
    rm -rf "$d_cache"
    mkdir -p "$d_cache"
    echo "$tmux_vers" >"$f_cached_tmux"
}



#
#
#  In shell script unlike in tmux, backslash needs to be doubled inside quotes.
#
default_key="\\"

#
#  By printing a NL and date, its easier to keep separate runs apart
#
log_it ""
log_it "$(date)"

trigger_key=$(get_tmux_option "@menus_trigger" "$default_key")
log_it "trigger_key=[$trigger_key]"

normalize_bool_param "@menus_without_prefix" "No" &&
    without_prefix=true || without_prefix=false
# if bool_param "$(get_tmux_option "@menus_without_prefix" "0")"; then
#     without_prefix=1
# else
#     without_prefix=0
# fi

log_it "without_prefix=[$without_prefix]"

#
#  Generic plugin setting I use to add Notes to keys that are bound
#  This makes this key binding show up when doing <prefix> ?
#  If not set to "Yes", no attempt at adding notes will happen
#  bind-key Notes were added in tmux 3.1, so should not be used on
#  older versions!
#
normalize_bool_param "@use_bind_key_notes_in_plugins" "No" &&
            use_notes=true || use_notes=false
# if bool_param "$(get_tmux_option "@use_bind_key_notes_in_plugins" "No")"; then
#     use_notes=1
# else
#     use_notes=0
# fi

log_it "use_notes=[$use_notes]"

params=""
$use_notes && params="$params -N plugin:tmux-menus"
# if [ "$use_notes" -eq 1 ]; then
#     #  shellcheck disable=SC2089
#     params="$params -N plugin:tmux-menus"
# fi

# if [ "$without_prefix" -eq 1 ]; then
if $without_prefix; then
    params="$params -n"
    log_it "Menus bound to: $trigger_key"
else
    log_it "Menus bound to: <prefix> $trigger_key"
fi

if tmux_vers_compare 3.0 && [ "$FORCE_WHIPTAIL_MENUS" != "1" ]; then
    cmd="$D_TM_ITEMS/main.sh"
else
    if [ -z "$(command -v whiptail)" ]; then
        error_msg "whiptail is not installed!" 1
    fi
    cmd="$D_TM_SCRIPTS/do_whiptail.sh"
fi

#  shellcheck disable=SC2086
$TMUX_BIN bind $params $trigger_key run-shell "$cmd"
