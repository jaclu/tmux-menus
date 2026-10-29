# Advanced Configuration

This document covers optional settings for debugging, performance tuning, and
advanced use cases.

## Really old tmux versions

For versions < 1.9 TPM is not available; initialize by running
`[path to tmux-menus]/menus.tmux` directly from `tmux.conf`.

For versions < 1.8 user variables are not available, so the plugin will always
use defaults.

## Display Menu Commands

```tmux
set -g @menus_display_commands 'No'
```

Default: `Yes` (not available when using whiptail/dialog)

When enabled, each menu includes a "Display Commands" item (shortcut `!`). Press it
to cycle through three views: the underlying tmux commands, all matching prefix and
root key bindings, and back to the normal menu.

This helps you discover tmux bindings and verify if an action already has a shortcut
configured.

Note: Menus grow larger with this feature enabled—ensure sufficient screen space.

<img width="251" height="188" alt="Move Window"
  src="https://github.com/user-attachments/assets/55daaf9d-80c8-49f8-a5c2-121536e159e3" />
<img width="389" height="264" alt="Move Window-Cmds"
  src="https://github.com/user-attachments/assets/16142418-5a9a-4798-a87a-3407d8e7d55a" />
<img width="251" height="217" alt="Move Window-KeyBinds"
  src="https://github.com/user-attachments/assets/df2262ae-c055-4451-9d00-c7580fae30f5" />

### Command Display Width

This option only applies when Display Menu Commands is enabled above.

```tmux
set -g @menus_display_cmds_cols 160
```

Default: `75`

Controls the maximum line length for displayed commands. Long commands are split
into chunks at whitespace when possible, or at the maximum length if no
whitespace is found.

If the window is narrower than this value, the window width limits this setting so
that no lines are cut off.

## Config File Location

Usually the default (below) is sufficient, but you can configure it if needed:

```tmux
set -g @menus_config_file "~/.configs/tmux.conf"
```

See [QuotingPitfalls](docs/QuotingPitfalls.md) for handling `$HOME` and `~` in tmux
variables.

The main menu includes a reload option that needs to know which config file to
reload. The location is determined in this order:

1. `@menus_config_file` - if defined in your tmux config
2. `$TMUX_CONF` - if present in the environment
3. `$XDG_CONFIG_HOME/tmux/tmux.conf` - if `$XDG_CONFIG_HOME` is defined
4. `~/.tmux.conf` - default fallback

When reloading, you'll be prompted to confirm the config file path, which
defaults to the first match above and can be edited if needed.

## Logging

Logging is disabled by default. To enable it, specify a log file:

```tmux
set -g @menus_log_file "~/tmp/tmux-menus.log"
```

See [QuotingPitfalls](QuotingPitfalls.md) for handling `$HOME` and `~` in tmux
variables.

### Measure Menu Processing Time

```tmux
set -g @menus_use_timers 'Yes'
```

Default: `No` (automatically enabled for tmux 3.7 and earlier)

On tmux 3.7 and earlier, timers are required to detect silent menu display
failures. When a menu doesn't fit on screen, tmux silently refuses to display
it but still exits with status 0, giving no indication of failure. The plugin
monitors how quickly the menu closes—if it closes in less than 0.1 seconds, it
indicates the menu likely didn't fit and failed to display.

On tmux 3.8+, this is no longer necessary:
menus spill over available display edges instead of silently failing, and
`display-menu` now forks so timing instant-closure detection doesn't work
anyway. The option is still available for debugging purposes on slow systems
where you want to monitor actual menu rendering performance.

## Hint Overlays (Obsolete in tmux 3.7)

```tmux
set -g @menus_use_hint_overlays 'No'
```

Up to tmux 3.6, this defaults to enabled. Starting with 3.7, all tmux dialogs
have native help popups via F1, so this feature is obsolete and is not offered
on 3.7 and later.

(not available when using whiptail/dialog)

Some menu items launch tmux dialogs with complex keybindings (choose-buffer,
choose-client, choose-tree, and customize-mode). When enabled, this setting
displays an overlay listing available keys before entering the dialog, if
screen space permits.

Set to `No` to disable overlays.

Note: If `@menus_use_hint_overlays` is disabled, the `@menus_show_key_hints`
option (below) is ignored.

### Show Key Hints

```tmux
set -g @menus_show_key_hints 'Yes'
```

Up to tmux 3.6, this defaults to disabled. Starting with 3.7,
all tmux dialogs have native help popups via F1,
so this feature is obsolete and is not used on 3.7 and later.

Related to `@menus_use_hint_overlays`. Since key listings can be quite long,
they may not fit on screen and will be silently skipped. Enabling this option
adds a "Key Hints" entry to relevant menus, which displays the dialog normally
with a size warning if needed.

This serves two purposes:

- Provides access to key hints even when automatic overlays don't fit
- Indicates which menu entries normally trigger an overlay

## Caching

```tmux
set -g @menus_use_cache 'No'
```

Default: `Yes`

Menu items are cached by default for better performance. Disabling caching also
disables the Custom Menus feature.

Menu files define two functions: `static_content()` for items that never change
(cached for performance), and `dynamic_content()` for conditional items that
regenerate each display. See [items/pane_move.sh](../items/pane_move.sh) where
"Swap current pane with marked" only appears when a marked pane exists.

The cache is fully invalidated during plugin init when:

- A different tmux version is detected at initialization
- The plugin repo has been updated
- Any change to the tmux-menus variables in tmux.conf

### Validate Cache

```tmux
set -g @menus_validate_cache 'Yes'
```

Default: `No`

When enabled, the cache system verifies that cached menu items have not become stale by
checking file modification timestamps. This ensures that if a menu script is
modified, the cache is immediately invalidated rather than serving outdated
content on the next display.

This is useful during development or when troubleshooting menu issues.
On modern hardware, it adds negligible overhead but can be noticeable on slower systems.
If no menus are changed, enabling this does not serve much purpose.

Note: This option has no effect when caching is disabled.
