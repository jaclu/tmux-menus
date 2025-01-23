# Custom Menus for `tmux-menus`

This automatically handles custom menus placed in the `items/additional/` directory.
This script ensures everything stays updated and consistent whenever you add, change,
or remove custom menu scripts.

## How It Works

1. **Monitoring Changes**:
   When files in `items/additional/` change, the script checks if an
   `items/additional/_index.sh` file (a menu index) needs to be updated or removed.

   - If valid files are found, it creates or updates `_index.sh` to include all
     custom menus.
   - If no valid files are found, `_index.sh` is removed.

2. **Main Menu Integration**:
   If `_index.sh` exists, it’s automatically linked in the Main Menu the next time
   you run it.

3. **Custom Menu Requirements**:
   Custom menu scripts should include two optional variables:

   - **Menu Label**: How the menu is described (used in `_index.sh`).<br>
     Example: `menu_item="My custom applications"`
   - **Shortcut**: A shortcut for quick access to the menu.<br>Example: `menu_key="M"`

   If these hints are missing or invalid, a notification will be displayed,
   and `_index.sh` won’t include the affected menu. Fix the issue, and the script
   will automatically reprocess the changes.

## Summary

This script ensures your custom menus are always recognized and properly linked to the
Main Menu, keeping everything neat and user-friendly. Just make sure your custom
scripts include valid labels and shortcuts if needed!
