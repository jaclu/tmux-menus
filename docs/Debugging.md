# Debugging

## Logging

If `@menus_log_file` is defined, it will be used for status updates generated
by `log_it "msg"`.

The `log_interactive_to_stderr` variable (set in `scripts/helpers_minimal.sh`
around line 515) controls whether interactive scripts (run from the command
line) log to `/dev/stderr`. This setting is independent of file-based logging.

## Error Tracing

Setting `teh_debug=true` before a `tmux_error_handler` call enables detailed
logging of that specific call, useful for tracing syntax issues. Note that
`tmux_error_handler` automatically resets `teh_debug` to false, so setting it
to true only affects the next call.

When `teh_debug` is enabled, error displays are limited to one-liners in the
log file, preventing it from being flooded with elaborate error reports.

## Environment Variables

### TMUX_MENUS_LOGGING_MINIMAL

Controls logging verbosity when extensive debugging is enabled:

- `1` - Display only `log_it_minimal()` calls (errors and menu rendering times
  by default)
- `2` - Disable all logging

### TMUX_MENUS_HANDLER

Controls which menu handler to use:

- `0` - (default) Use native menus if available, otherwise fall back to
  whiptail/dialog
- `1` - Force whiptail
- `2` - Force dialog

### TMUX_MENUS_PROFILING

Set to `1` to enable profiling. When enabled, `profiling_display "some message"`
prints total elapsed time and time since the last profiling checkpoint.

For more details, see `scripts/utils/dbg_profiling.sh`.

**Tip:** Combine with `export TMUX_MENUS_LOGGING_MINIMAL=1` to isolate
profiling output from other log messages.

### TMUX_MENUS_NO_DISPLAY

When set to `1`, menus are processed but not displayed. Also prevents
`cfg_trigger_key` from being bound. Useful for testing menu generation without
showing them.
