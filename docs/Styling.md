# Menu Styling

## Introduction

Common menu styling can be set using:

- menu-style
- menu-selected-style
- menu-border-style
- menu-border-lines

The plugin styling features are not so much meant to duplicate this, instead
offering convenient overrides for certain menus/items.

## Navigation Indicators

| Action        | Variable        | Default | Example                |
| ------------- | --------------- | ------- | ---------------------- |
| Next menu     | @menus_nav_next | `'-->'` | `'#[fg=colour220]-->'` |
| Previous menu | @menus_nav_prev | `'<--'` | `'#[fg=colour71]<--'`  |
| Home          | @menus_nav_home | `'<=='` | `'#[fg=colour84]<=='`  |

Navigation variables support full tmux styling and are available in tmux 3.0+.

## Per-Menu Overrides

All styling variables support per-menu overrides for fine-grained control:

| Override Variable | Falls Back To                |
| ----------------- | ---------------------------- |
| override_title    | @menus_format_title          |
| override_selected | @menus_simple_style_selected |
| override_style    | @menus_simple_style          |
| override_border   | @menus_simple_style_border   |
| override_next     | @menus_nav_next              |
| override_prev     | @menus_nav_prev              |
| override_home     | @menus_nav_home              |

When an override is defined in a menu, it takes precedence over the
configuration variables.

**Testing tip:** Overrides are ideal for testing themes and styles. Modifying
an override in a menu script invalidates that menu's cache, causing it to
regenerate with the new style on next display.

![sample of dynamic changes using overrides](https://github.com/user-attachments/assets/e4f1c2b6-fb99-40d8-b8df-9174e9d5d3e3)

## Style Variables

The table below lists available style variables. "Param" refers to
`display-menu` parameters (see the tmux man page).

In the Defaults it is indicated what Session option will control this if not
directly provided to `display-menu`. This means that at least in principle
these menus can have different styling from other tmux menus. If that might be
desirable I leave up to others to decide...

| Param | Variable                     | Default                              | Example             |
| ----- | ---------------------------- | ------------------------------------ | ------------------- |
| -T    | @menus_format_title          | `"'#[align=centre] #{@menu_name} '"` | `"#{@menu_name}"`   |
| -s    | @menus_simple_style          | menu-style                           | `bg=red`            |
| -H    | @menus_simple_style_selected | menu-selected-style                  | `fg=blue,bg=yellow` |
| -S    | @menus_simple_style_border   | menu-border-style                    | `fg=green`          |
| -b    | @menus_border_type           | menu-border-lines                    | `rounded`           |

**Notes:**

- The `simple_style` prefix indicates limited style notation support.
- **-T** (`@menus_format_title`): A FORMAT field. Use `#{@menu_name}` to
  display the menu name.
- **-b** (`@menus_border_type`): Sets border character style. See
  `popup-border-lines` in the tmux man page.
- **-H, -s, -S**: Appear to only support `fg`, `bg`, and `default` attributes.

### Quoting Considerations

To maximize styling freedom, these variables are **not** wrapped in quotes in
the generated menu code. This means you're responsible for proper quoting,
especially for spaces in menu names.

If using `#{@menu_name}` and menus contain spaces, wrap it in an inner quote.

Example:

```tmux
set -g @menus_format_title "'#[align=centre] #[fg=colour34]#{@menu_name} '"
```

## The styling I use

```tmux
set -g @menus_nav_next "#[fg=colour220]-->"
set -g @menus_nav_prev "#[fg=colour71]<--"
set -g @menus_nav_home "#[fg=colour84]<=="
```
