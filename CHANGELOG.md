# Changelog

All notable changes to this project will be documented here.

---

## [2.2.17] - 2025-07-16

### Added

- display_message() - if tmux > 1.7 messages longer than status bar will be displayed
  in full screen.

### Changed

- Removed remaining Bash dependencies
- Made it possible to import dialog_handling without running it right away,
  solving linting issues with items/hints & Missing chars menus
- Code cleanup to avoid repeated sourcing that confused linters

---

## [2.2.16] - 2025-06-20

### Changed

- Bug fix: Made conversion of hex char -> printable be more POSIX compliant
  in order to get it to run on iSH

---

## [2.2.15] - 2025-06-19

### Changed

- Bug fix: Removed leftover debug code that prevented some missing keys from being
  displayed

---

## [2.2.14] - 2025-06-11

### Changed

- Bug: extras.sh - incorrect line continuation hiding external tools
- `Layouts - Border Indicators` - menu_min_vers=3.3
- Cleanup of TODO - removed completed tasks

---

## [2.2.13] - 2025-06-08

### Added

- Currencies; Added bitcoin glyph
- Missing Keys - Diacritics; Added entry of common diacritics

### Changed

- removed exec flag from a source only script show_cmd.sh
- Fixed bug in cache.sh - forgotten # before a shellcheck directive

---

## [2.2.12] - 2025-06-08

### Changed

- Set min version to 2.5 for "Layouts - Border Lines"

---

## [2.2.11] - 2025-06-06

### Added

- Layouts - Border Lines: Added controls for pane title

---

## [2.2.10] - 2025-06-04

### Changed

- Corrected Pane & Window screenshots to not use styling

---

## [2.2.9] - 2025-06-04

### Added

- moved Modifications to separate document

### Changed

- Simplified README.md
- Better alignment Window - Pane & Move Window - Move Pane, both shortcuts and item order

---

## [2.2.8] - 2025-06-02

### Added

- new function display_formated_message() - shows multi line messages in a temp window
  used both for long error messages and notifications
- plugin_init.sh Warns if tmux is < 1.8 and notifies that all options will use defaults
- Fully clear cache if tmux version has changed
- Added mirrored layouts for tmux >= 3.5

### Changed

- Ensure everything works on tmux 1.5
- tmux_escape_for_display() - corrected handling of backticks
- Cleaned up Pane move and Window move/link
- Changes to speed cutoff
- Better menu display error handling

---

## [2.2.7] - 2025-05-25

### Added

- Main help mentions that `j` & `k` can be used for scrolling
- re-enabled menu reloads when using whiptail/dialog
- when using whiptail/dialog, this keeps track of menu recursion depth and only resumes
  the backgrounded process (if any) as last menu closes
- Layouts available both from Panes and Windows menus

### Changed

- Fix: Main help had an empty text line that could be selected
- Removed min vers for Pane History - View scrollback, since it's been around since
  at least version 0.8
- Lowered min tmux vers for plugin to 1.0, since there isn't really any tmux limit
  on using this. Each feature not available for the running tmux is skipped
- Better sanity checks when checking for TMUX_MENUS_HANDLER
- Adjusted min version for some menus
- whiptail adjustments for menu reload
- Simplified handling of actions for whiptail
- skipped using sockets in TMUX_BIN ended up causing param confusion when using
  whiptail on some complex menu actions
- Removed usage of env variable: TMUX_MENUS_SHOW_CMDS
- Simplified: Extras - dropbox & mullvad
- Moved Dropbox handling into a single file
- Fixed broken handling of multiword params
- Linting, made notices about why each shellcheck disable is being used
- Better plugin scan for iSH compatibility
- Removed usage of env variable: TMUX_MENUS_SHOW_CMDS

---

## [2.2.6] - 2025-05-09

### Added

- Display error if plugin init failed

---

## [2.2.5] - 2025-05-09

### Added

- New documentation: docs/SingleQuotes.md

### Changed

- Updated README.md to refer to docs/SingleQuotes.md when relevant

---

## [2.2.4] - 2025-05-09

### Added

- time_span(org_time) - sets t_time_span to time since org_time
- copied definition of TMUX*BIN to scripts/utils/define_tmux_bin.sh in order to ensure
  sockets will always be used to minimize risk for collisions if an inner tmux uses
  this plugin in stdalone tools, like `external_dialog*\*`
- scripts/utils/std*alone_log.sh - Tries to pick up current log_file if defined
  otherwise logs to /dev/stderr, used by external tools that don't load the entire
  environment like `external_dialog*\*`

### Changed

- Bug fix: fix_home_path() - Now correctly handles the odd behaviour of tmux 3.4
- Bug fix: forgetting to check if cache is active in dialog_handling.sh:handle_dynamic()
- Bug fix: verify_menu_runable() - escape ' in order to display errors in menu code
- Bug fix: scripts/update_custom_inventory.sh - ensure main menu is cleared if
  custom items are removed, to ensure main menu stops offering custom menus

- menu_parse() - optimized processing
- menu_generate_part() - abort early for empty parts
- tmux_error_handler_assign() - streamlined for performance and added inline comments
- get_menu_items_sorted() & cache_read_menu_items() - simplified code, slight performance boost
- Added run_if_found() - makes code cleaner
- Improved error detection when parsing and displaying menus
- 'Move pane' & 'Move Window' - Corrected check when pane is marked in another context
- static_files_reduction() - simplified
- sort_menu_items() -> get_menu_items_sorted()
- moved all profiling init to dbg_profiling.sh

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
