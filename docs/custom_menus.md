# Custom menus

This plugin automatically handles custom menus placed in the `custom_items/`
directory.

## How It Works

regenerate
the index listing all custom menus.
`custom_items/_index.sh` (listing all custom menus, from now on referred
to just by `_index.sh`).

### **Monitoring Changes**

When files in `custom_items/` change, on next startup the plugin will
process all files found.

- It creates or updates an inex listing all valid custom menus.
- If no valid items are found, this index is removed.

To manually trigger a reprocessing of the custom menus, run the plugin init
`menus.tmux`

### **Main Menu Integration**

If `_index.sh` exists, it’s automatically linked in the Main Menu as
"Additinoal items"

### **Custom Menu Requirements**

Custom menu scripts should include two additional variables that will be used
in `_index.sh`:

- **menu_key**: A shortcut for quick access to the menu.<br>
Example: `menu_key="C"`
- **menu_label**: A (short!) summary of what this is.<br>
Example: `menu_label="My custom applications"

If these hints are missing or invalid, a notification will be displayed next time
`_index.sh` is generated, and that custom menu will be ignored until it is fixed.

There is a template that can be used when creating custom menus.
copy `content/custom_item_template.sh` into `custom_items/` with a
suitable name

## Summary

This approach ensures your custom menus are always recognized and properly linked to
the Main Menu, keeping everything neat and user-friendly.

Just make sure your custom menu include valid labels and shortcuts!
