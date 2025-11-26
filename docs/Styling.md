# Menu Styling

## About Styling

These styling features were added to allow menus to match various tmux themes.
The focus is on ease of use and implementation rather than providing preset
themes.

Sample configurations are included to demonstrate what's possible. Users with
design expertise can leverage these features to better integrate menus with
their themed environments.

## Style Variables

The table below lists available style variables. "Param" refers to
`display-menu` parameters (see the tmux man page).

| Param | Variable                     | Default                              | Example             |
| ----- | ---------------------------- | ------------------------------------ | ------------------- |
| -T    | @menus_format_title          | `"'#[align=centre] #{@menu_name} '"` | `"#{@menu_name}"`   |
| -b    | @menus_border_type           | (none)                               | `rounded`           |
| -H    | @menus_simple_style_selected | (none)                               | `fg=blue,bg=yellow` |
| -s    | @menus_simple_style          | (none)                               | `bg=red`            |
| -S    | @menus_simple_style_border   | (none)                               | `fg=green`          |

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

## Example Configurations

### Catppuccin Frappe

![Catppuccin Frappe inspired](https://github.com/user-attachments/assets/82bd152a-e577-4e1b-abc0-f959c30a87c3)

```tmux
# fg @thm_surface_0 bg @thm_yellow
set -g @menus_simple_style_selected 'fg=#414559,bg=#e5c890'
set -g @menus_simple_style 'bg=#414559'        # @thm_surface_0
set -g @menus_simple_style_border 'bg=#414559' # @thm_surface_0
set -g @menus_nav_next '#[fg=colour220]-->'
set -g @menus_nav_prev '#[fg=colour71]<--'
set -g @menus_nav_home '#[fg=colour84]<=='
```

### The styling I use

![My Styling](https://github.com/user-attachments/assets/0dafa700-529a-4020-b049-93b5cf92358b)

```tmux
set -g @menus_format_title "'#[fg=yellow,align=left] #{@menu_name} '"
set -g @menus_simple_style_border "fg=green,bg=default"
set -g @menus_border_type 'rounded'
set -g @menus_nav_next "#[fg=colour220]-->"
set -g @menus_nav_prev "#[fg=colour71]<--"
set -g @menus_nav_home "#[fg=colour84]<=="
```
