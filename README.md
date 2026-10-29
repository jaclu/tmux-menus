# Tmux-Menus

<img width="237" height="278" alt="Main - Dark theme"
src="https://github.com/user-attachments/assets/adb009fc-9a6c-4c56-b01c-b1570f1bc5ff" />
<img width="237" height="279" alt="Main - Light Theme"
src="https://github.com/user-attachments/assets/bfbd8eb2-70a6-4821-834f-fae7cc9f8a87" />

## Summary

A collection of popup menus for managing your tmux environment. With tmux 3.8+,
automatic theming is much improved. The dark and light themes are shown above.

Once installed, press the trigger key to display the main menu. The default
trigger is `<prefix> \` (see Configuration below to customize).
There is also a secondary default `<prefix> Enter` if it has not already been
bound to something else. See [docs/SecondaryDefault.md](docs/SecondaryDefault.md)
for details.

The menus are designed to be easily adaptable to your workflow. Some items may
seem redundant to experienced users, but this makes it easier for newcomers to
discover functionality—advanced users can simply remove what they don't need.

## Recent Changes

- Fixed handling of tmux names containing quotes and spaces
- **Floating Panes handling** — New menus for positioning and managing floating panes
  (tmux 3.7+)
- **Display Settings** — New menu for selecting one of the available themes
  (Dark/Light, Terminal, Auto) (tmux 3.8+)
- **Danger Zone** — Destructive commands are highlighted by default; enable/disable
  or customize as needed
- **Key collision detection** — Prevents duplicate keyboard shortcuts across menus
- **Automatic location detection** — The plugin finds its own location, so manual
  `D_TM_BASE_PATH` configuration is no longer needed

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

<img width="252" height="354" alt="Handling Pane"
  src="https://github.com/user-attachments/assets/4363910a-237e-4d07-bdd5-d659cb656592" />
<img width="252" height="324" alt="Handling Window"
  src="https://github.com/user-attachments/assets/fead153b-081c-420e-afff-e2db948bfac9" />
<img width="268" height="295" alt="Layouts"
  src="https://github.com/user-attachments/assets/aaef90f0-c1e0-4110-821e-f8b8aed3c2ed" />
<img width="251" height="203" alt="Missing Keys"
  src="https://github.com/user-attachments/assets/4211bdbb-3ce2-4273-ba45-6b081dbc1998" />
<img width="227" height="264" alt="Missing Keys-whiptail"
  src="https://github.com/user-attachments/assets/6186795e-ef99-4a73-b958-61f42aa9fb13" />

Floating pane handling offers both a combined menu and split menus. If the combined
menu is too tall for your terminal, you can toggle to split format. This selection
is remembered for the next time.

<img width="261" height="339" alt="Handling floating panes - Placement"
  src="https://github.com/user-attachments/assets/ba8b444f-404c-4ecb-aa09-93bd27f23bef" />
<img width="261" height="354" alt="Handling floating panes - split menu"
  src="https://github.com/user-attachments/assets/abb0b5fc-1b60-4f21-98b9-3889475166e0" />
<img width="263" height="492" alt="Handling floating panes - combined"
  src="https://github.com/user-attachments/assets/e54d79f6-5c22-4d1d-82dc-c799b030748c" />

## Known Limitations

This plugin does not work when the tmux environment path contains spaces.

## Dependencies & Compatibility

| Version    | Notes                                                                                                                         |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 3.4        | Styling supported.                                                                                                            |
| 3.2        | Full menu positioning available.                                                                                              |
| 3.0 - 3.1c | Menu centering not supported; displays top-left if C is selected.                                                             |
| < 3.0      | Supported back to tmux 1.5 via whiptail/dialog, see [Alternative Menu Handlers](#alternative-menu-handlers-whiptail--dialog). |

These compatibility notes apply to the plugin as a whole. Individual menu items
may have minimum version requirements—items incompatible with your tmux version
will be automatically skipped. If you encounter incorrect version limits, please
report them!

## Installation of tmux-menus

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

**tmux 3.7:** Left arrow doesn't go back to the previous menu (tmux bug, fixed in 3.8).
Highlight "Back" and press Enter instead.

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

See [docs/QuotingPitfalls.md](docs/QuotingPitfalls.md) for handling special characters
like `\` in tmux variables. For more information about the secondary default and why
it was introduced, see [Secondary Default Key](docs/SecondaryDefault.md).

### Trigger Without Prefix

```tmux
set -g @menus_without_prefix 'Yes'
```

Default: `No`

Enable this to trigger menus without pressing `<prefix>` first.

### Danger Zone

All commands that are destructive, such as kill, delete, and respawn, can be made
to stand out by using a specific style. To disable this, set it to `""`

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

This affects floating pane move/resize actions in the Panes - Floating Panes
menu (requires tmux 3.8).

The stepping size is defined by these two settings:

```tmux
set -g @menus_floating_pane_incr_horizontal 5
set -g @menus_floating_pane_incr_vertical 2
```

Default for both: `1`

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

**Linux:** Most distributions include `whiptail` by default. In Red Hat and Homebrew
ecosystems, the package that contains `whiptail` is called `newt`.

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

- [gregorias](https://github.com/gregorias) - Reported about issues handling
  quotes and spaces when naming tmux entities, like sessions, windows and more
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
