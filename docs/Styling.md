# Layouts

## Aesthetic Disclaimer

I have little sense of visual aesthetics, so these features are not driven by a personal
need for visual appeal. However, it was recently suggested that it would be useful
to match menus to various themes, which made me curious about how to provide such
features.

For me, it’s more about making it easy to use and implement. I’ve included some
samples to show what’s possible, but please be kind—creating themes isn’t my goal.
Hopefully, those with an eye for design can put this to good use to better integrate
the menus with themed environments.

## Menu style variables

In the table below, Param refers to display-menu parameters (see the tmux man page).

| Param | variable                     | Default                            | Sample config     |
| ----- | ---------------------------- | ---------------------------------- | ----------------- |
| -T    | @menus_format_title          | `"'#[align=centre] #{@menu_name} '"` | `"#{@menu_name}"` |
| -H    | @menus_simple_style_selected | default                            | fg=blue,bg=yellow |
| -s    | @menus_simple_style          | default                            | bg=red            |
| -S    | @menus_simple_style_border   | default                            | fg=green          |

The prefix `simple_style` indicates that it doesn’t support full style notation.

The -T parameter (`@menus_format_title`) is a FORMAT field. Use `#{@menu_name}`
to display the menu name.

The -H, -s, and -S parameters seem to only support setting fg, bg, and default,
but I could be mistaken.

Since tmux scripting has limitations that quickly exhaust available quotes and to
maximize styling freedom, these variables are not wrapped in quotes in the
generated menu code.

All quoting of spaces in the menu name etc. is up to the style creator.

This could be more trouble than it's worth, so let me know if this method isn’t practical.
On the upside, it should allow for maximum styling flexibility.

Example:

```tmux
set -g @menus_format_title "'#[align=centre] #[fg=colour34]#{@menu_name} '"
```

## Menu navigaion hints

| action    | variable        | default | Sample config        |
| --------- | --------------- | ------- | -------------------- |
| next menu | @menus_nav_next | '-->'   | '#[fg=colour220]-->' |
| prev menu | @menus_nav_prev | '<--'   | '#[fg=colour71]<--'  |
| home      | @menus_nav_home | '<=='   | '#[fg=colour84]<=='  |

The navigation variables support full normal styling

## Menu overrides

| override variable | Default                      |
| ----------------- | ---------------------------- |
| override_title    | @menus_format_title          |
| override_selected | @menus_simple_style_selected |
| override_style    | @menus_simple_style          |
| override_border   | @menus_simple_style_border   |
| override_next     | @menus_nav_next              |
| override_prev     | @menus_nav_prev              |
| override_home     | @menus_nav_home              |

All the styling variables support overrides on a per-menu level, for those who want full
control over dynamic menus.

If an override is defined in a menu, it will take precedence over the config variables.

These overrides are also ideal for testing themes and styles. By assigning overrides
in a menu and saving it, the cache (if used) for that menu is invalidated,
and the menu will be regenerated with the new style the next time it’s displayed.

![sample of dynamic changes using overrides](https://github.com/user-attachments/assets/e4f1c2b6-fb99-40d8-b8df-9174e9d5d3e3)

## Sample config - Catppuccin Frappe inspired

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
