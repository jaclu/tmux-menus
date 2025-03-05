# Custom Menus

## Overview

This feature streamlines the integration of custom menus into the tmux-menu hierarchy.
By placing custom menu scripts in the `custom_items/` directory (which needs to
be created in the plugin’s root folder), they will be automatically linked to the
Main menu.

When custom menus are detected, the plugin generates an index of these menus and
adds a "Custom items" entry at the top of the Main menu.

If caching is disabled, custom menus are not supported, since using them would
require updating their index.

---

## How It Works

### **Detecting Changes**

The plugin monitors the `custom_items/` directory for any changes. When files are added,
updated, or removed, the following actions occur during the next tmux startup:

1. **Index Creation or Update**: An index is created or updated to list
   all valid custom menus.
2. **Index Removal**: If a custom menu is deleted, it is removed from the index.
   If no valid custom menus remain, the index is deleted, and the "Custom items"
   link is removed from the Main menu.
3. **Menu Labels**: Each valid custom menu is listed in the index using:
   - **menu_name**: The display name of the menu.
   - **menu_key**: The shortcut key for quick access.

To manually trigger reprocessing of the `custom_items/` directory, without having
to restart tmux, run the plugin initialization script: `menus.tmux`

---

### **Main Menu Integration**

When the Custom menus index is generated, a "Custom items" entry will automatically
appear in the Main menu. This entry links to your custom menus.

![Image](https://github.com/user-attachments/assets/7a7b272f-b05e-421b-8447-89fa00c9d2c0)

If no custom menus are present, this entry will be removed from the Main menu.

---

## Requirements for Custom Menus

Each custom menu script must define the following variables:

- **menu_key**: A unique shortcut key for quick access.<br>
  Example: `menu_key="C"`

- **menu_name**: A user-friendly label for the menu.<br>
  Example: `menu_name="My Special Menu"`
  This label will be used in the Custom items index and as the menu’s display name.

If either variable is missing or invalid, the menu will be ignored during indexing.
A notification will be shown the next time menus are processed, prompting you to
correct the script.

To get started, copy the provided template from `templates/custom_item_template.sh`
into `custom_items/` and rename it appropriately.

---

## Customization Tips

- **Submenus**: If you want to exclude certain scripts (e.g., submenus) from being
  listed in the index, place them in a subdirectory under `custom_items/`.
  These scripts will still be cached.

---

## Summary

This plugin ensures your custom menus are always recognized, properly linked,
and easily accessible via the Main menu. By following the simple guidelines for
menu scripts, you can maintain a clean and organized tmux experience tailored
to your workflow.
