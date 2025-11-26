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
remained broken. As of 3.5, tmux reverted to the 3.0 behavior.

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

## Special Characters and Escaping

Quoting affects how special characters like backslash (`\`) are parsed:

- **No quoting**: Must use `\\`
- **Single quotes**: Both `'\\'` and `'\'` work
- **Double quotes**: Must escape the backslash: `"\\"`

To avoid subtle quoting issues in key bindings or option values, escape
special characters consistently:

- Use `\\` for a literal backslash
- Avoid switching between single and double quotes unnecessarily

---

## Examples

**Incorrect (common mistakes):**

```tmux
set -g @plugin_path '$HOME/.tmux/plugins'
set -g @plugin_path '~/plugins'
set -g @my_key '\'  # unreliable in some quoting contexts
```

**Correct (portable and safe):**

```tmux
set -g @plugin_path "$HOME/.tmux/plugins"
set -g @plugin_path "~/plugins"
set -g @my_key "\\" # explicit and unambiguous
```

These patterns behave consistently across tmux versions and quoting contexts.
