# Caching

Several approaches are used to render menus quickly.

Purely static menus that have been cached typically renders in < 0.01 seconds on
reasonably modern systems. Enabling a log_file will print render times for each menu
displayed.

At initialization, if tmux version and/or tmux conf for this plugin has been altered
cache is cleared.

## Scripts environment

When a menu script is started only a minimal env is loaded, the full support env
is only loaded when needed. All to cut down on overhead. This minimal env is enough
to display cached static content.

Dynamic content will be slightly slower, since it has to be generated each time,
so it is highly dependent on the complexity of the dynamic tasks.
On modern systems this should hardly be noticeable

## Static content

Defined inside static_content() {} in each menu

First time a menu is accessed this cache needs to be rendered, but on all subsequent
displays it should be instantaneous.

## Dynamic content

Defined inside dynamic_content() {} in each menu

Since this is rendered each time a menu is displayed, the full environment has not
been loaded to keep it lean, so only what is in `scripts/helpers_minimal.sh` is available.

If the full environment is needed, it has to be loaded. For example `items/pane_move.sh`
can be used for a template how to load the full environment.
Look for the line:

```sh
$all_helpers_sourced || source_all_helpers "pane_move:dynamic_content()"
```

The initial condition ensures that the call to source all helpers is only done
if it has not been done previously.

## When plugin-dir is read only

Either disable caching entirely, or create a softlink for the cache folder.
This way cache can be located elsewhere, where writing is allowed, something like:

```sh
ln -sf ~/.cache/tmux-menus <tmux plugin folder>/cache

ln -sf /tmp/tmux-menus-cache <tmux plugin folder>/cache
```

## whiptail / dialog

These also use caching same as tmux built in `display-menu`, but due to displaying
such menus take a noticeable time, they will not be displayed as quickly despite
using caching.
