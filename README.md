# Clicked

![CI Status](https://github.com/Snakybo/Clicked/workflows/CI/badge.svg)

Clicked is a World of Warcraft addon aimed to improve keybindings and macros. The addon adds a configuration window (`/clicked` or `/cc`) from where all all bindings can be configured to do _something_. You can configure exactly what it does on a per-binding basis, and even merge keys to do different things depending on who the target it.

Additionally it adds support for the binding of the left and right mouse buttons if you prefer clicking on unit frames to cast something.

## Features

* Create keyboard/mouse button bindings for spells, items, and custom macros
* Fallback targets for bindings
  1. Cast on my mouseover target
  2. Cast on my target
  3. Cast on myself
* Cast abilities by clicking on unit frames
* Rebind left and right mouse buttons
* Run custom macros without taking up a macro slot or 255 character limitations
* Combine keys to do different things depending on the target
  * Cast a heal when hovering over a friendly unit frame
  * Cast Smite when hovering over an enemy unit frame
* Remove the need for action bar keybindings
* Dynamically load and unload bindings
  * Talent specialization(s)
  * Combat status
  * Group status
  * Specific player in group
* Pick spells from the spellbook

## Support

[Issue tracker](https://github.com/Snakybo/Clicked/issues)

Please include which version and unit frame addon you're using (`/dump Clicked.VERSION`). If there are specific bindings that are not working include the configurations for those as well.

## Credits

Clicked is inspired by [Clique](https://www.curseforge.com/wow/addons/clique). A lot of the click casting functionality is based of Clique.
