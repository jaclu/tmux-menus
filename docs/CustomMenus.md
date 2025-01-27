# Custom menus

## How It Works

This plugin automatically handles custom menus placed in the `custom_items/`
directory, and links to them from the Main menu.

If custom menus are found, an index listing them will be created, and an extra
item will be added at the top of the Main menu

### **Monitoring Changes**

When files in `custom_items/` change, on next tmux startup the plugin will
process all files found.

- It creates or updates an index, listing all valid custom menus.
- If no valid items are found, this index is removed, and the link to Custom items
  in the Main menu is removed.
- Each Custom menu will be labeled with its menu name and have the shortcut defined
  in `menu_key`

To manually trigger a reprocessing of the custom menus, run the plugin init script
`menus.tmux`

### **Main Menu Integration**

If `_index.sh` exists, it’s automatically linked in the Main Menu as
"Custom items"

![Image](https://github.com/user-attachments/assets/7a7b272f-b05e-421b-8447-89fa00c9d2c0)

### **Custom Menu Requirements**

Custom menu scripts must indicate what shortcut should be used to access this menu
from the Custom items index.

- **menu_key**: A shortcut for quick access to the menu.<br>
  Example: `menu_key="C"`

- **menu_name**: The label for this menu in the index.<br>
  Example: `menu_name="A very special menu"`

If either is missing or invalid, a notification will be displayed next time
the Custom pages are processed, and that custom menu will be ignored until it is fixed.

There is a template that can be used when creating custom menus.
copy `templates/custom_item_template.sh` into `custom_items/` with a
suitable name

## Summary

This approach ensures your custom menus are always recognized and properly linked to
the Main Menu, keeping everything neat and user-friendly.

In case some Custom menus should not be listed in the Custom menu index, such as
listing sub-options for one of the main Custom menus, put them
in a subfolder off `custom_items/`. This way any changes in them will trigger a
re-indexing of the Custom menus index.
