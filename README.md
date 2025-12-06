# Tmux-Menus

<img width="250" alt="main"
src="https://github.com/user-attachments/assets/63b13583-471d-4cfb-89db-3e30bdcd0f58" />
<img width="250" alt="main-styled"
src="https://github.com/user-attachments/assets/0dafa700-529a-4020-b049-93b5cf92358b" />

## Summary

A collection of popup menus for managing your tmux environment. Menus can be
customized with optional [docs/Styling](docs/Styling.md), as shown in the right
screenshot above.

Once installed, press the trigger key to display the main menu. The default
trigger is `<prefix> \` (see Configuration below to customize).

The menus are designed to be easily adaptable to your workflow. Some items may
seem redundant to experienced users, but this makes it easier for newcomers to
discover functionality—advanced users can simply remove what they don't need.

## Recent Changes

- Re-ordered main menu to better align with frequently used items.
- Layouts – The currently active option is dimmed and cannot be selected. Also giving a
  hint about current setting.
- New menu for `tmux 3.6` `Panes - Layouts - Scroll Bars`
- Documentation improvements for better clarity and readability throughout README
  and docs/ files.
- tmux versions with `next-` prefix are treated as one version lower for
  compatibility. For example, `next-3.4` is treated as `3.3` since `next-3.4`
  doesn't yet support display-menu profiling.

## Purpose

While tmux provides a few basic popup menus by default, they're quite limited
and difficult to extend due to their complex, mouse-focused one-liner
implementations. This plugin provides a more user-friendly approach with better
navigation and extensibility.

This isn't just a beginner's tool—it's useful for experienced users too:

- **Command Reference**: Use `Display menu commands` as a quick reference for
  keyboard shortcuts.
- **Limited Terminals**: When connecting via terminals with poor Meta key or
  arrow key support (like macOS's built-in Terminal), menus provide access to
  actions that would otherwise require unavailable shortcuts.
- **Complex Operations**: Simplify tasks that would otherwise require external
  scripts or hard-to-read bind one-liners, such as killing the current session
  without disconnecting.
- **Efficiency**: Some operations are simply faster via menus. For example,
  killing the server takes 12 keystrokes via command line
  (`<prefix> : kill-ser <tab> <enter>`) but only 5 via menus
  (`<prefix> \ A x y`).

## Screenshots

The white screenshot shows a whiptail-generated menu, which uses more screen
space than native tmux menus. However, whiptail menus are scrollable when they
don't fit the screen, whereas tmux's native `display-menu` simply won't render
if there's insufficient space. The other screenshots show native tmux menus.

<img width="265" alt="Handling Pane"
src="https://github.com/user-attachments/assets/6784be66-b2a0-4c41-b76c-1a3a7a2f99ac" />
<img width="297" alt="Handling Window"
src="https://github.com/user-attachments/assets/a407ccd3-d8f0-428d-a0c1-f6a1aca93ab8" />
<img width="337" alt="Help summary"
src="https://github.com/user-attachments/assets/efa0e3e5-5d37-4c88-b379-16d5a5264946" />
<img width="264" alt="Missing Keys"
src="https://github.com/user-attachments/assets/95d4b08f-894d-4b78-bf46-95b4447393e3" />
<img width="270" alt="Missing Keys-whiptail"
src="https://github.com/user-attachments/assets/d4025441-a310-4805-8204-431197c1056a" />

## Known Limitations

This plugin does not work when the tmux environment path contains spaces.

## Dependencies & Compatibility

| Version    | Notes                                                                                                 |
| ---------- | ----------------------------------------------------------------------------------------------------- |
| 3.4        | Styling supported.                                                                                    |
| 3.2        | Full menu positioning available.                                                                      |
| 3.0 - 3.1c | Menu centering not supported; displays top-left if C is selected.                                     |
| < 3.0      | Requires `whiptail` or `dialog` (see below). Menu location and styling settings are ignored.          |
| < 1.8      | TPM not available; initialize by running `[path to tmux-menus]/menus.tmux` directly from config file. |
| 1.5        | Minimum required version.                                                                             |

These compatibility notes apply to the plugin as a whole. Individual menu items
may have minimum version requirements—items incompatible with your tmux version
will be automatically skipped. If you encounter incorrect version limits, please
report them!

## Installation

### Via TPM (Recommended)

The easiest installation method is via the [Tmux Plugin
Manager](https://github.com/tmux-plugins/tpm).

1. Add the plugin to your TPM plugin list in `.tmux.conf`:

   ```tmux
   set -g @plugin 'jaclu/tmux-menus'
   ```

2. Press `<prefix> + I` to install and activate the plugin. It should now be
   ready to use.

### Manual Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/jaclu/tmux-menus ~/clone/path
   ```

2. Add this line to the bottom of your `.tmux.conf`:

   ```tmux
   run-shell ~/clone/path/menus.tmux
   ```

3. Reload your tmux configuration:

   ```sh
   # Inside tmux
   tmux source-file ~/.tmux.conf
   ```

The plugin should now be active.

## Configuration

### Boolean Parameters

All boolean parameters accept the following values (case-insensitive):

- True: `Yes`, `True`, `1`
- False: `No`, `False`, `0`

### Menu Trigger Key

The default trigger is `<prefix> \`. To customize it:

```tmux
set -g @menus_trigger 'Space'
```

See [SingleQuotes](docs/SingleQuotes.md) for handling special characters like
`\` in tmux variables.

### Trigger Without Prefix

```tmux
set -g @menus_without_prefix 'Yes'
```

Default: `No`

Enable this to trigger menus without pressing `<prefix>` first.

### Config File Location

```tmux
set -g @menus_config_file "~/.configs/tmux.conf"
```

See [SingleQuotes](docs/SingleQuotes.md) for handling `$HOME` and `~` in tmux
variables.

The main menu includes a reload option that needs to know which config file to
reload. The location is determined in this order:

1. `@menus_config_file` - if defined in your tmux config
2. `$TMUX_CONF` - if present in the environment
3. `$XDG_CONFIG_HOME/tmux/tmux.conf` - if `$XDG_CONFIG_HOME` is defined
4. `~/.tmux.conf` - default fallback

When reloading, you'll be prompted to confirm the config file path, which
defaults to the first match above and can be edited if needed.

### Menu Position

Default: `C` for tmux ≥ 3.2, `P` otherwise. Ignored when using whiptail/dialog.

```tmux
set -g @menus_location_x 'W'
set -g @menus_location_y 'S'
```

For complete location options, see the tmux man page under `display-menu`.
Common options:

| Value | Axis | Meaning                         |
| ----- | ---- | ------------------------------- |
| C     | Both | Center of terminal (tmux ≥ 3.2) |
| R     | -x   | Right side of terminal          |
| P     | Both | Bottom-left of pane             |
| M     | Both | Mouse position                  |
| W     | Both | Window position on status line  |
| S     | -y   | Line above or below status line |

### Caching

```tmux
set -g @menus_use_cache 'No'
```

Default: `Yes`

Menu items are cached by default for better performance. Disabling caching also
disables the Custom Menus feature.

Technically, only items defined in `static_content()` are cached, while items that
need fresh generation each time (like conditional menu entries) are defined in
`dynamic_content()`. See [scripts/pane_move.sh](items/pane_move.sh) for an
example—it only shows "Swap current pane with marked" when a marked pane exists.

The cache is automatically invalidated when:

- A different tmux version is detected at initialization
- A menu script has been modified (checked via timestamp)

### Hint Overlays

```tmux
set -g @menus_use_hint_overlays 'No'
```

Default: `Yes` (not available when using whiptail/dialog)

Some menu items launch tmux dialogs with complex keybindings (choose-buffer,
choose-client, choose-tree, and customize-mode). When enabled, this setting
displays an overlay listing available keys before entering the dialog, if
screen space permits.

Set to `No` to disable overlays.

Note: If `@menus_use_hint_overlays` is disabled, the `@menus_show_key_hints`
option (below) is ignored.

#### Show Key Hints

```tmux
set -g @menus_show_key_hints 'Yes'
```

Default: `No`

Related to `@menus_use_hint_overlays`. Since key listings can be quite long,
they may not fit on screen and will be silently skipped. Enabling this option
adds a "Key Hints" entry to relevant menus, which displays the dialog normally
with a size warning if needed.

This serves two purposes:

- Provides access to key hints even when automatic overlays don't fit
- Indicates which menu entries normally trigger an overlay

### Logging

Logging is disabled by default. To enable it, specify a log file:

```tmux
set -g @menus_log_file "~/tmp/tmux-menus.log"
```

See [SingleQuotes](docs/SingleQuotes.md) for handling `$HOME` and `~` in tmux
variables.

### Display Menu Commands

```tmux
set -g @menus_display_commands 'No'
```

Default: `Yes` (not available when using whiptail/dialog or when caching is
disabled)

When enabled, each menu includes a "Display Commands" item (shortcut `!`) that
shows the underlying tmux commands for each action. Press again to display all
matching prefix and root key bindings.

Note: Menus are taller when this feature is enabled, so ensure your screen has
sufficient height.

#### Command Display Width

```tmux
set -g @menus_display_cmds_cols 160
```

Default: `75`

Controls the maximum line length for displayed commands. Long commands are split
into chunks at whitespace when possible, or at the maximum length if no
whitespace is found.

If lines end with `>`, they've been truncated by tmux because they exceed the
display width. Reduce `@menus_display_cmds_cols` to prevent truncation.

## Custom Menus

Originally, customization required forking the repository and modifying menus
directly. However, a dynamic menu system has been added that allows users to
add custom menus without forking.

The key difference: **custom menus** integrate into the official menu system,
while **alternate menus** (below) replace it entirely.

For implementation details, see [docs/CustomMenus.md](docs/CustomMenus.md).

### Alternate Menus

```tmux
set -g @menus_main_menu "~/my_tmux_menus/main.sh"
```

Default: None (uses built-in menus)

Override the default menu system with a completely custom set.

**Important notes:**

- All custom menus must define `D_TM_BASE_PATH` to point to the tmux-menus
  installation directory for support scripts to work correctly.

## Screen Size Detection

tmux doesn't provide an error when a menu doesn't fit the screen—it simply
refuses to display it. The only indication is that the menu closes immediately.

To help identify this issue, the plugin monitors menu display time. If a menu
closes in less than 0.1 seconds, it assumes the screen was too small and displays:

```text
tmux-menus ERROR: Screen might be too small
```

**Note:** This detection isn't perfect. The error may also appear if you close
the menu immediately (intentionally or not), leading to false positives. If it
doesn't recur when you retry, it can be safely ignored.

## Alternative Menu Handlers: whiptail / dialog

For tmux versions prior to 3.0, the `display-menu` feature is unavailable. In
these cases, the plugin falls back to `whiptail` or `dialog` for menu display.

The plugin prefers `whiptail`, falling back to `dialog` if unavailable. If
neither tool is found, the plugin will abort with an error message.

Since these are full-screen applications, they suspend any running task, display
the menu, and then resume the suspended task when done.

**Limitations:** External menu handlers don't differentiate between uppercase
and lowercase letters, and don't support special keys like arrow keys or Home.

### Forcing External Handlers

To use whiptail/dialog on modern tmux versions, set an environment variable:

- For `whiptail`: `export TMUX_MENUS_HANDLER=1`
- For `dialog`: `export TMUX_MENUS_HANDLER=2`

### Installation

**Linux:** Most distributions include `whiptail` by default. If not, install it
via your package manager. Note that in the Red Hat ecosystem, the package is
called `newt` (not `whiptail`).

**macOS:** Install via Homebrew: `brew install newt`

## Contributing

Contributions are welcome and appreciated! Every contribution helps, and credit
is always given.

To report bugs, request features, or provide feedback, please file an
[issue](https://github.com/jaclu/tmux-menus/issues).

## Acknowledgments

Thanks to everyone who has contributed to making this plugin better:

- [cmon1701](https://github.com/cmon1701) - Reported hardcoded path assumptions
  in plugin listing (fixed in 2.1.3)
- [sumskyi](https://github.com/sumskyi) - Improved boolean check error messages
  to include variable names (fixed in 2.0.2)
- [GaikwadPratik](https://github.com/GaikwadPratik) - Reported broken cache
  disabling feature
- [Tony Soloveyv](https://github.com/tony-sol) - Caught unintentional shortcut
  change in main menu
- [JuanGarcia345](https://github.com/JuanGarcia345) - Suggested making
  menu-cache optional
- [phdoerfler](https://github.com/phdoerfler) - Identified TMUX_BIN not being
  set consistently
- [giddie](https://github.com/giddie) - Suggested "Re-spawn current pane"
  feature
- [wilddog64](https://github.com/wilddog64) - Suggested prefix for public IP
  curl probe

## License

[MIT](LICENSE)
