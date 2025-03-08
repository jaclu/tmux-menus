# Debugging

Some environment variables that can be used

# MENUS_PROFILING

If set to 1 profiling will be used and `profiling_display "some message"`
will print total time and time since last profiling_display

For more details check `scripts/utils/dbg_profiling.sh`

If not set to 1 `profiling_display` statements will be ignored,

# TMUX_MENUS_FORCE_SILENT

- `1` - no display to /dev/stderr, everything is directed to the log file (if defined)
- `2` - no output at all, neiter to /dev/stderr nor log file profiling will also
  be silenced.
