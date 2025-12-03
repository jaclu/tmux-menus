# Caching

Menu rendering is optimized by avoiding unnecessary script execution.
Cached menus skip all processing and return precomputed output.

Purely static cached menus typically render in under 0.01 seconds.
Enable `@menus_log_file` to view render times for each displayed menu.
The cache is cleared at initialization if the tmux version or plugin
configuration has changed.

## Static Content

Defined in `static_content() {}` within each menu script.

On first access, the menu output is generated and stored in `cache/<menu-name>`.
Subsequent displays read directly from this cache and are effectively instantaneous.

## Dynamic Content

Defined in `dynamic_content() {}` within each menu script.

Dynamic content is rebuilt for every display.

## Script Environment

All scripts start with a minimal environment. Static cached content requires nothing more.

To load the full environment in manually added/modified scripts, use:

```sh
${all_helpers_sourced:-false} || source_all_helpers "Reason for souring the full env"
```

This prevents repeated sourcings if script logic might take multiple paths to a
piece of code depending on the full env. In essence, when in doubt - source it
with a notice to what sourced it, this comes with close to zero overhead if
already sourced.

## Read-Only Plugin Directory

System-wide or package-managed installations may place the plugin under a read-only path.
In that case, either disable caching or redirect the cache directory via a symlink:

```sh
ln -sf ~/.cache/tmux-menus <tmux-plugin-folder>/cache
```

A configurable cache path is intentionally not supported. Implementing one would
require checking that location for every script invocation, adding overhead that
nullifies the cache’s purpose. A symlink avoids this cost.

## whiptail / dialog

These external menu handlers use the same caching mechanism, but their terminal
redraw overhead dominates rendering time. Caching reduces script work but cannot
eliminate the slower rendering inherent to these tools.
