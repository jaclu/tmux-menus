# Debugging

Some environment variables that can be used

## MENUS_PROFILING

If set to 1 profiling will be used and `profiling_display "some message"`
will print total time and time since last profiling_display

For more details check `scripts/utils/dbg_profiling.sh`

If not set to 1 `profiling_display` statements will be ignored,

## TMUX_MENUS_NO_DISPLAY

If set to `1` menu will be processed, but not actually displayed, it will also
prevent the cfg_trigger_key from being bound, so with this setting the code can be
profiled outside tmux

## TMUX_MENUS_FORCE_SILENT

- `1` - logging does not display to /dev/stderr, even if log_interactive_to_stderr is 1
- `2` - profiling is redirected to log file
- `3` - no output at all, neiter to /dev/stderr nor log file profiling will also
  be silenced. error_msg will override this and be displayed.

tmux_get_plugin_options

- retrieves from tmux, only relying on f_cached_tmux_options

get_config

- returns cache directly if found
- reads from tmux - tmux_get_plugin_options
- save if allowed

get_config_refresh

- removes old param cache if need be
- cache_config_get_save

```shell
# cfg_trigger_key=\"$(cache_escape_special_chars "$cfg_trigger_key")\"
# cfg_no_prefix=\"$cfg_no_prefix\"

# cfg_use_cache=\"$cfg_use_cache\"
# cfg_use_hint_overlays=\"$cfg_use_hint_overlays\"
# cfg_show_key_hints=\"$cfg_show_key_hints\"

# cfg_use_whiptail=\"$cfg_use_whiptail\"
# cfg_alt_menu_handler=\"$cfg_alt_menu_handler\"

# cfg_nav_next=\"$(cache_escape_special_chars "$cfg_nav_next")\"
# cfg_nav_prev=\"$(cache_escape_special_chars "$cfg_nav_prev")\"
# cfg_nav_home=\"$(cache_escape_special_chars "$cfg_nav_home")\"

# cfg_format_title=\"$(cache_escape_special_chars "$cfg_format_title")\"
# cfg_simple_style=\"$(cache_escape_special_chars "$cfg_simple_style")\"
# cfg_simple_style_border=\"$(cache_escape_special_chars "$cfg_simple_style_border")\"
# cfg_simple_style_selected=\"$(cache_escape_special_chars "$cfg_simple_style_selected")\"

# cfg_mnu_loc_x=\"$cfg_mnu_loc_x\"
# cfg_mnu_loc_y=\"$cfg_mnu_loc_y\"

# cfg_tmux_conf=\"$cfg_tmux_conf\"
# cfg_log_file=\"$cfg_log_file\"

# cfg_use_notes=\"$cfg_use_notes\"

# tpt_current_vers=\"$tpt_current_vers\"
# tpt_current_vers_i=\"$tpt_current_vers_i\"
# tpt_current_vers_suffix=\"$tpt_current_vers_suffix\"

# #
# # Get version hints for repo and local changes,
# # This ensures cache is cleared next time tmux is started or conf is sourced
# # anytime repo was updated, or any file was changed locally.
# #
# repo_last_changed=\"$repo_last_changed\"
# last_local_edit=\"$last_local_edit\"
```
