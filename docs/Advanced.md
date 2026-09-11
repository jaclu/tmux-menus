# Advanced Configuration

This document covers optional settings for debugging, performance tuning, and
advanced use cases.

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
- the plugin repo has been updated
- Any changes to the tmux-menus variables in tmux.conf

### Validate Cache

```tmux
set -g @menus_validate_cache 'Yes'
```

Default: `No`

When enabled, the cache system verifies that cached menu items haven't staled by
checking file modification timestamps. This ensures that if a menu script is
modified, the cache is immediately invalidated rather than serving outdated
content on the next display.

This is useful during development or when troubleshooting menu issues.
On modern hardware, it adds negligible overhead but can be noticeable on slower systems.
If no menus are changed, enabling this does not serve much purpose.

Note: This option has no effect when caching is disabled.

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

## Hint Overlays (Obsoleted in tmux 3.7)

```tmux
set -g @menus_use_hint_overlays 'No'
```

Up to tmux 3.6, this defaults to active, however starting with 3.7 all tmux dialogs
have native help popups via F1, so this feature is entirely obsolete and thus
not offered on 3.7 and up.

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

Up to tmux 3.6, this defaults to disabled, however starting with 3.7 all tmux dialogs
have native help popups via F1, so this feature is entirely obsolete and thus
not offered on 3.7 and up.

Related to `@menus_use_hint_overlays`. Since key listings can be quite long,
they may not fit on screen and will be silently skipped. Enabling this option
adds a "Key Hints" entry to relevant menus, which displays the dialog normally
with a size warning if needed.

This serves two purposes:

- Provides access to key hints even when automatic overlays don't fit
- Indicates which menu entries normally trigger an overlay
