# Clicked

![CI Status](https://github.com/Snakybo/Clicked/workflows/CI/badge.svg)

Clicked is a World of Warcraft addon with the goal of improving keybinds and macros. The addon adds a configuration window from where all keybinds can be configured to do _something_.

There is an extreme amount of freedom in configuring exactly _what_ a keybind does by creating bindings. A binding can do anything from casting a spell to using an item to running a custom macro. Alongside from configuring what a binding does, you are also able to specify the exact target priority for that binding and configure the conditions under which the binding should load.

When configuring multiple bindings on one keybind, Clicked will automatically combine their functionality and allow the keybind to perform either action depending on the context.

Additionally Clicked adds support for the binding of all mouse buttons in case you prefer clicking on a unit frame to cast something.

## Features

* Create keyboard and mouse button bindings for spells, items, and custom macros
* Cast spells without action bars
* Cast spells by clicking on unit frames
* Easily select spells from the spellbook
* Configure binding target priorities¹
* Configure binding load conditions²
* Configure multiple bindings on the same keybind³
* Configure custom macros without taking up a macro slot
* Configure a unit frame blacklist
* Automatically unload and unlock keybinds while in a vehicle
* No performance cost during gameplay

### Configure binding target priorities

You can use the binding target interface to configure the exact target priority. When the binding is activated, Clicked will try to cast the assigned spell or item on each target configured, if the conditions of a target are not met, or if the target does not exist it will try the next target until a valid target is found.

![Binding target configuration](https://i.imgur.com/Q6xzCoj.png)

### Configure binding load conditions

You can configure the exact load conditions on a per-target basis, through this interface you can specify the exact requirements that have to be met for this binding to activate. For example you can configure a binding to only load when a talent has been selected, when you're in war mode, or when you're in a specific shapeshift form.

A full list of all available load conditions:

* **Never load** will prevent the binding from loading entirely
* **Player Name-Realm** checks if your name/realm matches the input
* **Class** checks if you are of the selected class(es)
* **Race** checks if you are of the selected race(s)
* **Talent specialization** checks if you are in the selected talent specialization(s)
* **Talent selected** checks if you have the selected talent(s) active
* **PvP talent selected** checks if you have the selected PvP talent(s) active
* **Stance** (or **Form**) checks if you are in the selected stance(s) or shapeshift form(s)
* **War Mode** checks if you are in the selected War Mode state
* **Combat** checks if you are in the selected combat state
* **Spell known** checks if you can currently cast the specified spell or ability
* **In group** checks if you are in the specified group type (solo, party, raid)
* **Player in group** checks if the specified player is in your group
* **Pet** checks if your pet is (in)active

![Binding load conditions](https://i.imgur.com/u5NIJwM.png)

### Configure multiple bindings on the same keybind

You can configure as many bindings on the same keybind as you want, Clicked will automatically and dynamically prioritize the spell, item, or macro to activate based on the configuration of all bindings sharing the same keybind.

![Binding 1](https://i.imgur.com/PWelhhY.png)
![Binding 2](https://i.imgur.com/oknvfvn.png)

With the above configuration, Clicked will automatically combine the Flash of Light and Crusader Strike bindings and generate a macro:

```text
/use [@target,help] Flash of Light; [@target,harm] Crusader Strike; [@player] Flash of Light
```

_This all happens at the time of configuration, so Clicked has no additional performance impact during gameplay at all._

## Installation

Download and install Clicked using any of the three available portals:

* [Curseforge](https://www.curseforge.com/wow/addons/clicked)
* [WoWInterface](https://www.wowinterface.com/downloads/info25703-Clicked.html)
* [GitHub](https://github.com/Snakybo/Clicked/releases)

## Usage

To get started with Clicked, open the binding configuration window, either by typing `/clicked` in the chat frame, or by clicking on the minimap button.

![Binding configuration window](https://i.imgur.com/5ON79P4.png)

### Slash commands

The main slash command is `/clicked`. Additionally `/cc` works as an alias for all slash commands.

* Use `/clicked` to open the binding configuration window
* Use `/clicked profile` to quickly navigate to the profile management options
* Use `/clicked blacklist` to quickly navigate to the unit frame blacklist options
* Use `/clicked dump` to generate a debugging log of the current state

## Issues

See the GitHub [Issue tracker](https://github.com/Snakybo/Clicked/issues).

Please include the output from `/cc dump` if you have any issues, if there are any specific binding that are causing issues please include information about which ones are problematic.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Credits

Clicked is inspired by [Clique](https://www.curseforge.com/wow/addons/clique).
