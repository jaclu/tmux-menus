# Quoting Pitfalls in Plugin Variable Assignments

## `$HOME`, `~`, and Single Quotes

Using single quotes when assigning plugin variables, especially for paths
containing `$HOME` or `~`, is a common mistake.

Before tmux 3.0, tmux automatically interpreted paths like `'$HOME/some/path'`
or `'~/some/path'` correctly, effectively converting them to
`"$HOME/some/path"` behind the scenes.

This changed in version 3.0:

- `'$HOME/some/path'` is interpreted as `"\$HOME/some/path"` (literal string)
- `'~/some/path'` becomes `\~/some/path` (literal string)

Version 3.4 made things worse: `$HOME` became `"\\$HOME/some/path"` while `~`
remained broken. As of 3.5, tmux reverted to the 3.0 broken behavior.

### Workaround

The helper function `fix_home_path()` detects the tmux version and rewrites
broken single-quoted paths into properly double-quoted form, providing some
compatibility.

**However, this is still discouraged.** Most plugins don't account for these
quirks, and relying on single quotes causes broken behavior across versions.

**Best practice:** Always use double quotes for paths and variables like
`$HOME` or `~`. This ensures consistent, correct expansion across all tmux
versions.

---

## Special Characters in tmux.conf

Quoting affects how special characters like backslash (`\`) are parsed. Safe
notation has changed over time.

**Before tmux 3.0:**

- Unescaped inside single quotes: `'\'`
- Escaped inside double quotes: `"\\"`

**Starting with tmux 3.0:**

- Escaped without quotes: `\\`
- Unescaped without quotes if not backslash: `$`
- Unescaped inside double quotes if not backslash: `"$"`

**Incorrect (common mistakes):**

```tmux
set -g @plugin_path '$HOME/.tmux/plugins'
set -g @plugin_path '~/plugins'
set -g @my_key \\  # Fails on older tmux versions
```

**Correct (portable and safe on all tmux versions):**

```tmux
set -g @plugin_path "$HOME/.tmux/plugins"
set -g @plugin_path "~/plugins"
set -g @my_key '\'
```

These patterns behave consistently across tmux versions and quoting contexts.
