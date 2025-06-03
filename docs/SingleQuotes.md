# Quoting Pitfalls in Plugin Variable Assignments

## `$HOME`, `~`, and Single Quotes

A common but problematic habit is using single quotes when assigning plugin variables,
especially with paths involving `$HOME` or `~`.

Before tmux 3.0, tmux would automatically interpret paths like `'$HOME/some/path'`
or `'~/some/path'` correctly—effectively converting them to `"$HOME/some/path"`
behind the scenes.

That changed starting with version 3.0:

- `'$HOME/some/path'` is interpreted as `"\$HOME/some/path"`
- `'~/some/path'` becomes `\~/some/path`

In 3.4, `$HOME` became `"\\$HOME/some/path"` while `~` was still broken in the same way.
As of 3.5, tmux reverted to the 3.0 behavior again.

To work around this inconsistency, a helper—`fix_home_path()`—has been added.
It detects the tmux version and rewrites broken single-quoted paths into their
proper double-quoted form.

While this provides some compatibility, **it’s still discouraged**. Most plugins
do not account for these quirks, and relying on single quotes leads to broken
behavior across versions.

**Best practice:** Always wrap paths and variables like `$HOME` or `~` in
double quotes. This ensures consistent, correct expansion in all tmux versions.

---

## Special Characters and Escaping

Quoting also affects how special characters like the backslash (`\`) are parsed.

- With no quoting, `\\` must be used
- In _single quotes_, both `'\\'` and `'\'` can be used.
- In _double quotes_, you must escape the backslash: `"\\"`.

To avoid subtle quoting issues in key bindings or option values,
**escape special characters consistently**, regardless of quoting style:

- Use `\\` for a literal backslash
- Avoid switching between single and double quotes unless necessary

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
