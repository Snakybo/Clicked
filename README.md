# Clicked

## Introduction

Clicked is a World of Warcraft addon that allows you to manage both keybindings and click-cast bindings in an inuitive yet powerful manner. It allows you to bind virtually any keyboard or mouse button to perform a specic action, such as casting an ability or using an item. You can also configure the left and right mouse buttons to immediately cast an ability on a the targeted unit frame.

The Clicked configuration panel can be accessed using the `/clicked` command, or clicking on the minimap button.

## Features

### Bind spells, items, and custom macros

In order to bind a spell, item, or macro to a keyboard key or mouse button, simply open the Clicked configuration panel (`/clicked`) and use the new binding button. You'll be able to configure a variety of options, but in order to get started only the keybind and spell are required for the binding to function.

The keybind can be set to virtually any keyboard or mouse button. The spell can be configured in multiple ways, the easiest is to use the selection button, that will automatically open the spellbook and allow you to click on any spell to select it. Alternatively you can enter a spell name or spell ID manually.

In addition to spells, Clicked also allows you to bind any item or custom macro in the same manner, simply switch between the various types with the dropdown in the configuration window.

Custom macros do not take up a slot in the default macro interface, so you'll be able to configure as many as you'd like. They also are not limited to the 255 character limit. The process to configure custom macros is very similar to the default macro interface and you can use and macro conditionals that also exist in the default interface.

### Powerful target priority configuration

When configuring a binding you will be able to specify a chain of targets for each binding, this allows you to change the behavior of the binding depending on what you've specified as the target, for example a simple example is:

1. Cast on my mouseover target
2. Cast on my target
3. Cast on myself.

This will dynamically target the correct unit and find the first one that is valid. When used in a macro this will look similar to: `/cast [@mouseover,exists] [@target, exists] [@player] Holy Light`

Clicked supports a variety of relevant units out of the box:

* Global (no target is required for this spell)
* The player itself
* The current target
* The focus target
* The mouseover target (works for unit frames and 3D world units)
* Party member 1 to 5

In addition to specifying the target, you're also able to change the behavior depending on the unit's hostility towards you. For example, target the focus target if it's friendly, or the player otherwise.

### Bind unit targetting and context menu actions

Since Clicked allows you to rebind the left and right mouse button, you can configure another button to act as a replacement for those actions. If you haven't rebound the left or right mouse buttons it is safe to not include these as the default click functionality will persis.

### Dynamically load or unload bindings

Clicked will dynamically and seamlessly switch active bindings based on your current specialization, combat state, or whether a spell is currently known. You can configure these on a per-binding basis which allows you to activate or deactivate certain bindings on a per-spec basis, or disable the fishing rod binding when you enter combat.

## Upcoming Features

Clicked is still in active development and will gain the following features in the future:

* Support for binding keyboard keys to the targetting and menu actions
* Support for a "mouseover (frame)" target to exclude targeting units from the 3D world
* Support to select an item from your bags or equipment panel

## Credits

Clicked is inspired by the [Clique](https://www.wowinterface.com/downloads/fileinfo.php?id=5108) addon. A lot of the click casting functionality is based of Clique.
