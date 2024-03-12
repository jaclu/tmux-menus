# MenuGenerator

Since caching was introduced, menu generation is split in two parts:

- Static content - is only generated once,
and then the cache is used until the menu script is changed. A sample
using only static content is `items/main.sh`

- Dynamic content - is generated each time the menu is displayed, such
as a pane zoom item, where the menu should call the action Zoom or Un-Zoom
depending on state. A sample using dynamic content is `items/panes.sh`

In most cases only some items need to be dynamic, most parts of the menu
can be static
