# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**tmux-menus** is a tmux plugin providing user-friendly popup menus for managing
tmux sessions, windows, and panes. It's written in shell script and designed to
be highly configurable and adaptable.

## Linting

**Always run `olint` before reporting any task complete.** This is non-negotiable.

- Run from anywhere in the project: `olint` searches upward to find `.olint.conf`
- Clear cache and relint everything: `olint -Z`
- Check current configuration: `olint -c`
- Non-zero exit is a blocker—do not commit or report completion

Config files (do not use ad-hoc flags):

- `.olint.conf` – olint configuration
- `.shellcheckrc` – shellcheck rules for shell scripts
- `.markdownlint.json` – markdown rules
- `pyproject.toml` – pymarkdown rules

## Project Structure

```text
menus.tmux              # Entry point for TPM; initializes plugin in background
scripts/
  menu_handling.sh      # Core menu parser (1200+ lines); generates tmux/whiptail menus
  plugin_init.sh        # Plugin initialization; binds trigger key and reads config
  helpers.sh            # Full helper suite (sourced on demand)
  helpers_minimal.sh    # Minimal helpers for performance (always sourced first)
  show_cmd.sh           # Displays underlying tmux commands for each menu item
  update_custom_inventory.sh  # Manages custom menu registration
  utils/                # Utility scripts used by menu items
items/
  main.sh               # Main menu definition
  *.sh                  # Submenu definitions; each implements static_content() ± dynamic_content()
templates/
  custom_item_template.sh     # Template for users creating custom menu items
  custom_index_template.sh    # Template for custom menu index
tools/
  plugins.sh            # Plugin inventory display
  show_config.sh        # Display current tmux-menus configuration
  public_ip.sh          # Utility for showing public IP
docs/                   # User-facing documentation
```

## Architecture

### Menu System

All menus follow the same pattern:

1. **static_content()** – Define menu items that can be cached; executed once per
   tmux version
2. **dynamic_content()** (optional) – Define items that need fresh generation on
   each display (e.g., conditional items based on pane state, marked pane status)

Menus are parsed by `menu_handling.sh` and rendered as:

- Native tmux `display-menu` (tmux 3.0+)
- External tools: whiptail or dialog (tmux < 3.0 fallback)

### Performance & Caching

Menu caching is enabled by default (`@menus_use_cache`). The cache:

- Stores generated menu definitions for reuse
- Is invalidated when tmux version changes or menu scripts are modified
- Can be disabled, but also disables the custom menus feature

When developing:

- Disable caching during testing: Set `@menus_use_cache` to `No` in tmux config
- Or manually clear cache: `rm -rf ~/.cache/tmux-menus/`

### Adding a Menu Item

To add a new menu item in `items/`:

1. Create `items/my_feature.sh` or reference `items/main.sh` as a template
2. Define `static_content()` and build menu parameters with `set --`
3. Call `menu_generate_part <part-index> "$@"` to render
4. Source `menu_handling.sh` at the bottom:
   `. "$D_TM_BASE_PATH"/scripts/menu_handling.sh`
5. Optional: Define `dynamic_content()` for conditional items
6. Set `menu_name` for logging

Menu parameter format: `<version-req> <type> <key> <label> <command>`

- `version-req`: tmux version requirement (0.0 = none; e.g., 3.2)
- `type`: M (menu), C (command), E (execute), S (separator), T (text)
- `key`: keyboard shortcut
- `label`: display text
- `command`: tmux command or path to submenu script

### Helper Functions

**helpers_minimal.sh** (always sourced):

- `log_it()`, `log_it_minimal()` – Logging with cache validation
- `tmux_vers_check()` – Version comparison
- `error_msg()` – Error reporting
- `source_all_helpers()` – Load full helpers on demand

**helpers.sh** (sourced when needed):

- `tmux_get_option()` – Read tmux user options via eval
- `tmux_set_option()` – Set tmux user options
- Menu generation utilities
- String formatting and escaping

Sourcing pattern (ensures helpers load only once):

```bash
${all_helpers_sourced:-false} || source_all_helpers "context description"
```

### Compatibility

Supports tmux 1.5+. Version-specific behavior:

- **1.5–1.7**: Requires manual initialization in `.tmux.conf`
- **1.8–2.9**: TPM supported; external menu handlers (whiptail/dialog) required
- **3.0–3.1c**: Native `display-menu`; menu centering not supported
- **3.2+**: Full menu positioning and styling
- **3.4+**: Advanced styling with profiling optimization

Prefix `next-` versions (e.g., `next-3.4`) are treated as one version lower for
compatibility.

## Configuration

Users configure the plugin via tmux variables in `.tmux.conf` (e.g.,
`@menus_trigger`, `@menus_location_x`). The plugin reads these at init time and
caches them.

Key files:

- Cache stored in `~/.cache/tmux-menus/` (or custom location if
  `$XDG_CACHE_HOME` is set)
- Custom menus can be added without forking (see `docs/CustomMenus.md`)

## Development Notes

### Shell Compatibility

Target POSIX shell (`#!/bin/sh`). Avoid bash-specific features.

### Logging

Enable in `.tmux.conf`:

```tmux
set -g @menus_log_file "~/tmp/tmux-menus.log"
```

Environment variables:

- `TMUX_MENUS_LOGGING_MINIMAL=1` – Quiet (startup messages only)
- `TMUX_MENUS_LOGGING_MINIMAL=2` – Disable logging completely
- `TMUX_MENUS_NO_DISPLAY=1` – Skip binding trigger key (for debugging menu
  builds)

### Known Limitation

Plugin does not work when the tmux environment path contains spaces.

## Testing & Debugging

1. Disable cache: Set `@menus_use_cache` to `No` in `.tmux.conf`
2. Clear cache: `rm -rf ~/.cache/tmux-menus/`
3. View config: Run `tools/show_config.sh`
4. Display commands: Use menu item "Display Commands" (shortcut `!`) to see
   underlying tmux commands
5. Profile rendering: Use `tools/profiling-test.sh` to measure menu generation
   time

## Git Workflow

- **Branch**: Create feature branches from `main`
- **Commits**: Keep focused; reference issues if applicable
- **Linting**: **Always run `olint` before committing. Non-zero exit is a blocker.**
- **Testing**: Lint before committing; manual tmux testing if you've modified menu rendering
- **PRs**: All contributions welcome

## Documentation

User documentation in `docs/`:

- `Styling.md` – Custom menu styling (tmux ≥ 3.4)
- `CustomMenus.md` – Adding custom menus without forking
- `Caching.md` – How the caching system works
- `SingleQuotes.md` – Handling special characters in tmux variables
- `Debugging.md` – Troubleshooting and debug techniques
- `Modifications.md` – Guidance for local modifications
- `TODO.md` – Known issues and future enhancements

See also: README.md (overview and installation), CHANGELOG.md (version history)
