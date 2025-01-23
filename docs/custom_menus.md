# Custom Menus for `tmux-menus`

This automatically handles custom menus placed in the `additional_items/` directory.
This script ensures everything stays updated and consistent whenever you add, change,
or remove custom menu scripts.

## How It Works

1. **Monitoring Changes**:
   When files in `additional_items/` change, on next startup the plugin will check
   if `additional_items/_index.sh` file (a menu index, from now on refered to just
   by `_index.sh`) needs to be updated or removed.

   - If valid files are found, it creates or updates `_index.sh`
     to include all custom menus.
   - If no valid files are found, `_index.sh` is removed.

   A reprocessing of the additional items can be manually triggered by running
   `scripts/update_additional_inventory.sh`

2. **Main Menu Integration**:
   If `_index.sh` exists, it’s automatically linked in the Main Menu the next time
   it is beeing run.

3. **Custom Menu Requirements**:
   Custom menu scripts should include two optional variables:

   - **Shortcut**: A shortcut for quick access to the menu.<br>Example: `menu_key="C"`
   - **Menu Label**: How the menu is described (used in `_index.sh`).<br>
     Example: `menu_label="My custom applications"`

   If these hints are missing or invalid, a notification will be displayed,
   and `_index.sh` won’t include the affected menu. Fix the issue, and the script
   will automatically reprocess the changes.

   There is a template that can be used when creating custom menus.
   copy `content/additional_item_template.sh` into `additional_items/` with a
   suitable name

## Summary

This script ensures your custom menus are always recognized and properly linked to the
Main Menu, keeping everything neat and user-friendly. Just make sure your custom
scripts include valid labels and shortcuts if needed!
