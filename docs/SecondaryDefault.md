# Secondary Default Key

## Overview

The default trigger key `<prefix> \` is difficult or impossible to use on many
non-US keyboards, making it inaccessible to some users. Rather than change the
long-standing default and break existing configurations, a secondary default
trigger key was introduced: `<prefix> Enter`.

## Behavior

The secondary default key is used only when:

- `@menus_trigger` is not already defined
- The key is not already bound to another command (preventing accidental
  conflicts)

This approach preserves backward compatibility while providing a better
experience for users with keyboards where the backslash key is impractical.

## Plugin Ordering

If another plugin also wants to use `<prefix> Enter`, ensure it's defined
*before* tmux-menus in your `.tmux.conf`, or set `@menus_trigger` to disable
the secondary default.
