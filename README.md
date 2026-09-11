# Tmux-Menus

<img width="236" alt="Main"
  src="https://github.com/user-attachments/assets/f8510b2f-4880-4fed-99e5-7db29f400cd8" />
<img width="235" alt="Main styled"
  src="https://github.com/user-attachments/assets/12188f8f-fcdd-457c-ae74-2a6fd8cc38f1" />

## Summary

A collection of popup menus for managing your tmux environment. Menus can be
customized with optional [docs/Styling.md](docs/Styling.md), as shown in the right
screenshot above.

Once installed, press the trigger key to display the main menu. The default
trigger is `<prefix> \` (see Configuration below to customize).
There is also a secondary default `<prefix> Enter` if it has not already been
bound to something else. See [docs/SecondaryDefault.md](docs/SecondaryDefault.md)
for details.

The menus are designed to be easily adaptable to your workflow. Some items may
seem redundant to experienced users, but this makes it easier for newcomers to
discover functionality—advanced users can simply remove what they don't need.

## Recent Changes

- **Danger Zone** — Destructive commands are highlighted by default; enable/disable
  or customize as needed
- **Enhanced Floating Panes handling** — New combined menu, with a toggle to
  split format for standard 25x80 terminals, plus new pane placement controls
- **Stabilized Display Commands** — Fixed crashes and improved stability when
  displaying menu command references
- **Secondary default trigger key** `<prefix> Enter` for non-US keyboards where
  `<prefix> \` is impractical

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
don't fit the screen. The other screenshots show native tmux menus.

<img width="254" height="354" alt="Handling Pane"
  src="https://github.com/user-attachments/assets/2aa664b7-33a7-4560-a6e6-d128212e16f4" />
<img width="253" height="325" alt="Handling Window"
  src="https://github.com/user-attachments/assets/54e3ce58-0f18-4bef-8388-712e21acb930" />
<img width="268" height="294" alt="Layouts"
  src="https://github.com/user-attachments/assets/ae6a3bea-c550-4062-9cb7-92d56dc72680" />
<img width="251" height="203" alt="Missing Keys"
  src="https://github.com/user-attachments/assets/638d5071-669d-483a-bacf-6fb2d45b248a" />
<img width="227" height="264" alt="Missing Keys-whiptail"
  src="https://github.com/user-attachments/assets/6186795e-ef99-4a73-b958-61f42aa9fb13" />

Floating pane handling offers both a combined menu and split menus. If the combined
menu is too tall for your terminal, you can toggle to split format. This selection
is remembered for the next time.

<img width="253" height="325" alt="Handling floating panes - Placement"
  src="https://github.com/user-attachments/assets/5018d1a9-5e25-4b58-95c9-618682d45b88" />
<img width="254" height="355" alt="Handling floating panes - split menu"
  src="https://github.com/user-attachments/assets/ec90a06a-8861-4fa4-bdf4-4db8e22059c5" />
<img width="262" height="492" alt="Handling floating panes - combined"
  src="https://github.com/user-attachments/assets/902e3a1f-d6fe-4327-8bd0-5c0022e4d88b" />

## Known Limitations

This plugin does not work when the tmux environment path contains spaces.

### tmux 3.7 - display-menu bug

Left arrow doesn't work to go back. Workaround: Highlight and press Enter instead.

Still present in `3.7c` - resolved in `3.8`

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

Add the plugin to your `.tmux.conf`:

```tmux
set -g @plugin 'jaclu/tmux-menus'
```

Press `<prefix> I` to install and source the plugin.

### Manual Installation

Clone the repository:

```sh
git clone https://github.com/jaclu/tmux-menus ~/path/to/tmux-menus
```

Add to the bottom of your `.tmux.conf`:

```tmux
run-shell ~/path/to/tmux-menus/menus.tmux
```

Reload your configuration:

```sh
tmux source-file ~/.tmux.conf
```

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

See [docs/QuotingPitfalls.md](docs/QuotingPitfalls.md) for handling special characters like
`\` in tmux variables. For more information about the secondary default and why
it was introduced, see [SecondaryDefault](docs/SecondaryDefault.md).

### Trigger Without Prefix

```tmux
set -g @menus_without_prefix 'Yes'
```

Default: `No`

Enable this to trigger menus without pressing `<prefix>` first.

### Danger Zone

All commands that are destructive, such as kill/delete/respawn etc can be made
to standout by using a specific style. If this is not desired, set it to `""`

```tmux
set -g @menus_danger_zone "#[fg=red,bg=white]" # prints it red on white
set -g @menus_danger_zone "" # Disables the feature
```

Default: `#[reverse]`

### Alternate Menus

```tmux
set -g @menus_main_menu "~/my_tmux_menus/main.sh"
```

Default: None (uses built-in menus)

Override the default menu system with custom menus.

**Important notes:**

- All custom menus must define `D_TM_BASE_PATH` to point to the tmux-menus
  installation directory for support scripts to work correctly.

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

### Floating Panes positioning

This impacts floating pane move/resize actions in the Panes - Floating Panes
menu (requires tmux 3.8).

The stepping size is defined by these two settings:

```tmux
set -g @menus_floating_pane_incr_horizontal 5
set -g @menus_floating_pane_incr_vertical 2
```

Default for both: `1`

### Display Menu Commands

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

#### Command Display Width

This option only applies when Display Menu Commands is enabled above.

```tmux
set -g @menus_display_cmds_cols 160
```

Default: `75`

Controls the maximum line length for displayed commands. Long commands are split
into chunks at whitespace when possible, or at the maximum length if no
whitespace is found.

If lines end with `>`, they've been truncated by tmux because they exceed the
display width. Reduce `@menus_display_cmds_cols` to prevent truncation.

### Config File Location

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

## Advanced Configuration

For advanced settings including caching, logging, and hint overlays, see
[docs/Advanced.md](docs/Advanced.md).

## Screen Size Detection

In tmux versions prior to 3.8, when a menu doesn't fit on screen, tmux silently refuses
to display it without raising an error—the menu simply won't appear.

To help diagnose this issue, the plugin monitors how quickly a menu closes. If it closes
in less than 0.1 seconds, it displays:

```text
tmux-menus ERROR: Screen might be too small
```

**Note:** This detection has false positives—a quick close can also mean you
dismissed the menu while it was rendering. Try again to confirm. (Not an issue
on tmux 3.8+.)

## Alternative Menu Handlers: whiptail / dialog

For tmux versions prior to 3.0, the plugin falls back to `whiptail` or `dialog`
for menu display since `display-menu` doesn't exist.

The plugin tries handlers in this order:

1. `whiptail` (preferred)
2. `dialog` (fallback)

If neither is available, the plugin will error.

These are full-screen terminal applications that pause your session while displaying the menu.

**Limitations:** External handlers don't differentiate between uppercase and lowercase
letters, and don't support special keys (arrow keys, Home, etc.).

### Installation

**Linux:** Most distributions include `whiptail` by default. In the Red Hat
an Homebrew ecosystems, the package that contains `whiptail` is called `newt`.

**macOS:** Install via Homebrew: `brew install newt`

### Forcing External Handlers on Modern Tmux

To use whiptail/dialog on tmux 3.0+, set an environment variable:

```bash
export TMUX_MENUS_HANDLER=1  # force whiptail
export TMUX_MENUS_HANDLER=2  # force dialog
```

## Contributing

Contributions are welcome and appreciated! Every contribution helps, and credit
is always given.

To report bugs, request features, or provide feedback, please file an
[issue](https://github.com/jaclu/tmux-menus/issues).

## Acknowledgments

Thanks to everyone who has contributed to making this plugin better:

- [shixianqin](https://github.com/shixianqin) - Reported that `<prefix> \` is
  problematic on non-US keyboards, leading to the secondary default `<prefix> Enter`
  (fixed in 2.3.0)
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
