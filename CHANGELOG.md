# Changelog

All notable changes to this project will be documented here.

---

## [2.2.3] - 2025-04-28

### Added

- Prevent tmux variables from being expanded in `Display Menu Commands`

### Changed

- Changed titles of some menus to better reflect current placement
- Removed a relative path expander, no longer needed and caused some external
menu actions to fail

---

## [2.2.2] - 2025-04-26

### Changed

- Updated Screenshots
- tools/dbg_vars.sh - When running with 'clear' it clears env before displaying
  current state
- whiptail / dialog - useses `--title` option to display title

---

## [2.2.1] - 2025-04-26

### Changed

- Updated about box
- Moved some tasks into `Handling Window`

  - Split window
  - Layouts

- About box via **Help** menu:
  - Dynamically generate about box content each time that help menu is displayed
  - In the about box, added tag date, and if repo is newer also time for last commit

---

## [2.2.0] - 2025-04-25

### Added

- Rotation feature for `Display Menu Commands`:
  - Shows all available commands or matching prefix/root bindings.
  - Adds `[TMUX]` and `[tmux-menus]` prefixes for clarity.
- About box via **Help** menu, showing:
  - Latest tag
  - Branch (if not `main` or `master`)
  - Last update time
  - Repo origin (HTTPS, Git, etc.)
- New styling parameter: `@menus_border_type` (documented under Styling).

### Changed

- Plugin initialization refactored:
  - Rewritten into two functions: fast config reader and builder for config cache.
  - When cache is disabled, full config is read every time.

### Fixed

- Plugin listing reworked to resolve display issues.

---

## [2.1.3] - 2025-04-09

### Added

- Improved auto-detection of plugin folder:
  - Checks `TMUX_PLUGIN_MANAGER_PATH`, then `XDG_CONFIG_HOME`.
  - Suggests setting `TMUX_PLUGIN_MANAGER_PATH` if detection fails.
- Compatible with setups that don't use TPM.

---

## [2.1.2] - 2025-04-04

### Added

- Config option: `@menus_display_cmds_cols` to set max line length for commands.
  - Defaults to 75.
  - Commands will be split on whitespace or forced break if needed.

---

## [2.1.1] - 2025-04-04

### Changed

- Displayed commands are now unselectable.

---

## [2.1.0] - 2025-04-04

### Added

- New feature: **Display Commands** (`!` shortcut)
  - Controlled via `@menus_display_commands 'Yes'`.
  - Shows either the matching prefix sequence or the command to be run.

---

## [2.0.3] - 2025-04-03

### Fixed

- Workaround for `tmux 3.0–3.2a` returning success even if variable not found
  via `show-options -gv`.
  - Now uses `show-options -g` + `grep` fallback.

---

## [2.0.2] - 2025-03-30

### Changed

- Improved error messages for invalid boolean variables, showing name and value.

---

## [2.0.1] - 2025-03-29

### Removed

- All debug settings and profiling checks.

---

## [2.0.0] - 2025-03-28

### Changed

- Major rewrite:
  - Split helper scripts into `minimal` and `normal` for performance.
  - Cached static
