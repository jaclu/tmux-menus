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
  profiling can print to stderr
- `2` - profiling is redirected to log file
- `3` - no output at all, neither to /dev/stderr nor log file profiling will also
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
