# Custom Menus

## Overview

This addition streamlines the integration of custom menus into the tmux-menu hierarchy.
Simply place your custom menu scripts in the `custom_items/` directory (it needs
to be created in the plugin top folder), and they
will be automatically linked to the Main menu.

If custom menus are detected, the plugin generates an index of these menus and adds
a "Custom items" entry at the top of the Main menu.

---

## How It Works

### **Detecting Changes**

The plugin monitors the `custom_items/` directory. When files in this directory
are added or updated, the following actions occur the next time tmux starts:

1. **Item Creation or Update**: An index is created or updated to list all valid
   custom menus.
2. **Item Removal**: The removed Custom item will no longer be listed.
   If no valid custom menus are found, the index is removed,
   and the "Custom items" link in the Main menu disappears.
3. **Menu Labels**: Each custom menu is listed in the index using:
   - **menu_name**: The menu's display name.
   - **menu_key**: The shortcut key for quick access.

To manually reprocess the `custom_items/` directory, run the plugin initialization
script: `menus.tmux`

---

### **Main Menu Integration**

If a Custom menus index file is generated, the "Custom items" entry will
appear automatically in the Main menu, linking to your custom menus.

![Image](https://github.com/user-attachments/assets/7a7b272f-b05e-421b-8447-89fa00c9d2c0)

If nolonger any Custom menus are present, this top item will be removed from the
Main menu

---

## Requirements for Custom Menus

Each custom menu script must define the following variables:

- **menu_key**: A unique shortcut key for quick access.<br>
  Example: `menu_key="C"`

- **menu_name**: A user-friendly label displayed in the Custom items index.<br>
  Example: `menu_name="My Special Menu"`. This will also be used as the label for
  the menu when displayed.

If either variable is missing or invalid, the menu will be ignored during the
indexing process. A notification will appear the next time menus are processed,
prompting you to fix the script.

To get started, copy the provided template from `templates/custom_item_template.sh`
into `custom_items/` and rename it appropriately.

---

## Customization Tips

- **Submenus**: To exclude certain scripts (e.g., submenu scripts) from being listed
  in the index, place them in a subdirectory of `custom_items/`. Changes to these
  scripts will still trigger re-indexing but won't appear in the main Custom items
  index.

---

## Summary

This plugin ensures your custom menus are recognized, properly linked, and easy
to access via the Main menu. By following the simple guidelines for menu scripts,
you can create a clean, organized tmux experience tailored to your needs.
