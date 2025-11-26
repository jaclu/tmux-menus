# Caching

Multiple optimization strategies are used to render menus quickly.

Purely static cached menus typically render in under 0.01 seconds on modern
systems. Enable `@menus_log_file` to see render times for each menu displayed.

The cache is automatically cleared at initialization if the tmux version or
plugin configuration has changed.

## Script Environment

Menu scripts start with a minimal environment loaded, with the full support
environment loaded only when needed. This reduces overhead. The minimal
environment is sufficient for displaying cached static content.

Dynamic content is slightly slower since it must be generated on each display.
Performance depends on the complexity of dynamic operations, but on modern
systems this overhead is barely noticeable.

## Static Content

Defined in `static_content() {}` within each menu script.

The first time a menu is accessed, its cache is generated. All subsequent
displays are instantaneous.

## Dynamic Content

Defined in `dynamic_content() {}` within each menu script.

Since dynamic content is rendered each display, only the minimal environment
(from `scripts/helpers_minimal.sh`) is loaded by default to keep it lean.

To load the full environment when needed, use this pattern (see
[items/pane_move.sh](../items/pane_move.sh) for an example):

```sh
${all_helpers_sourced:-false} || source_all_helpers "pane_move:dynamic_content()"
```

The conditional ensures the full environment is sourced only once, even if
called multiple times.

## Read-Only Plugin Directory

If the plugin directory is read-only, either disable caching entirely or create
a symlink for the cache folder to a writable location:

```sh
ln -sf ~/.cache/tmux-menus <tmux-plugin-folder>/cache
```

Or use a temporary directory:

```sh
ln -sf /tmp/tmux-menus-cache <tmux-plugin-folder>/cache
```

## whiptail / dialog

These external menu handlers also use caching like the native `display-menu`.
However, due to their inherent rendering overhead, they display noticeably
slower despite caching.
