# Custom Menus

## Overview

This feature streamlines the integration of custom menus into the tmux-menus
hierarchy. By placing custom menu scripts in the `custom_items/` directory
(create this in the plugin's root folder), they'll be automatically linked to
the main menu.

When custom menus are detected, the plugin generates an index and adds a
"Custom items" entry at the top of the main menu.

**Note:** Custom menus require caching to be enabled, as they depend on index
updates.

An alternative approach, **Alternate Menus**, is also available—it replaces
the entire menu system rather than integrating with it. Custom menus remain
useful when you want to add specific menus while keeping the default ones
intact.

---

## How It Works

### Change Detection

The plugin monitors the `custom_items/` directory for changes. When files are
added, updated, or removed, the following actions occur during the next tmux
startup:

1. **Index Creation/Update**: An index is created or updated listing all valid
   custom menus.
2. **Index Removal**: If a custom menu is deleted, it's removed from the index.
   When no valid custom menus remain, the index is deleted and the "Custom
   items" link is removed from the main menu.
3. **Menu Labels**: Each valid custom menu appears in the index with:
   - **menu_name**: The display name of the menu
   - **menu_key**: The shortcut key for quick access

To manually trigger reprocessing of `custom_items/` without restarting tmux,
run the plugin initialization script: `menus.tmux`

---

### Main Menu Integration

When the custom menus index is generated, a "Custom items" entry automatically
appears in the main menu, linking to your custom menus.

![Image](https://github.com/user-attachments/assets/7a7b272f-b05e-421b-8447-89fa00c9d2c0)

If no custom menus are present, this entry is removed from the main menu.

---

## Requirements for Custom Menus

Each custom menu script must define two variables:

- **menu_key**: A unique shortcut key for quick access.
  Example: `menu_key="C"`

- **menu_name**: A user-friendly label for the menu.
  Example: `menu_name="My Special Menu"`
  This label appears in the custom items index and as the menu's display name.

If either variable is missing or invalid, the menu is ignored during indexing,
and you'll receive a notification the next time menus are processed.

To get started, copy the template from `templates/custom_item_template.sh` into
`custom_items/` and rename it appropriately.

---

## Customization Tips

**Submenus**: To exclude certain scripts (like submenus) from the index, place
them in a subdirectory under `custom_items/`. They'll still be cached but won't
appear in the main menu's custom items list.

---

## Summary

This feature ensures your custom menus are automatically recognized, properly
linked, and easily accessible via the main menu. By following these simple
guidelines, you can maintain a clean, organized tmux environment tailored to
your workflow.
