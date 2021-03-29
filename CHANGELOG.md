# Changelog

This document will contain a chronological list of all notable changes made to Clicked.

The format of this changelog is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). The versioning scheme used is [Semantic Versioning](https://semver.org/spec/v2.0.0.html), the notable breakpoints of what defines a major, minor, or patch version are as follows:

* The MAJOR component is only used ceremonically and will likely not be incremented unless a significant rewrite happens that does not have backwards compatibility.
* The MINOR component is used whenever a version has backwards-compatible profile changes. This also indicates that the user can not switch back to a previous MINOR version without using a backup.
* The PATCH component is used for versions that do not contain profile format changes. Users can freely switch between PATCH versions without risk of data loss.

## [1.1.2] - 2021-03-29

### Fixed

- Fix Lua error on Classic [#59]

## [1.1.1] - 2021-03-29

### Fixed

- Fix PvP talent ordering for some specs
- Fix a Lua error when creating a new profile [#58] ([hythloday](https://github.com/hythloday))

## [1.1.0] - 2021-03-26

### Added

- Update retail icons with new ones from 9.0.5

### Fixed

- Fix binding config occasionally resetting input field text whilst typing
- Fix spell ranks being ignored on Classic
- Fix not being able to create a "Open the unit menu" binding

## [1.0.0] - 2021-03-21

### Added

- Show spell and item ID next to text field
- Add `stealth`/`nostealth` macro condition
- Add `mounted`/`nomounted` macro condition
- Add `outdoors`/`indoors` macro condition
- Add `flying`/`noflying` macro condition
- Add `flyable`/`noflyable` macro condition
- Add `swimming`/`noswimming` macro condition
- Add Zone Name(s) load condition, specify multiple using comma as a seperator, or use `!` to negate a condition
- Add the option to execute multiple actions in a single macro, see action groups on the binding Action page
- Add a new binding type to replace the "Append" macro behavior
- Add shared binding options to macros

### Fixed

- Fix various issues with binding display names
- Improve behavior of target spell and item text field shift-clicks
- Fix shared binding options being changable during combat
- Fix custom macros that call protected functions not working [#57]

### Removed

- Remove the macro mode dropdown, the "Run first" and "Run last" behavior can now be achieved by modifying the action group

### Changed

- Save spells and items as ID instead of name
- Separate macro conditions from load conditions
- Replace the binding type dropdown with a the right click context menu option
- Hide binding status page if the binding is not loaded
- Hide binding status page from target/menu bindings
- Simplify the binding status page, remove the "local" macro and condense the related bindings into one list
- Hide binding action page from "Target the unit" and "Open the unit menu" binding types
- Slightly increase width of the binding configuration window
- Rework the binding templates list, it now lists presets of all available binding types, to replace the binding type dropdown

## [0.17.2] - 2021-03-10

### Added

- Add support for patch 9.0.5

## [0.17.1] - 2021-02-27

### Fixed

- Fix an issue where the `exists` check was incorrectly added when used in combination with the Stance/Form condition

## [0.17.0] - 2021-02-27

### Added

- Add support for mouse button 6+ [#52]

### Changed

- Major internal refactor and cleanup

### Fixed

- Fix an issue where some abilities appear twice in tooltips
- Fix an issue where uncastable spells or items would appear in the tooltip [#51]

## [0.16.2] - 2021-02-20

### Fixed

- Fix an error when logging in on Classic
- Fix an error when enabling tooltips on Classic

## [0.16.1] - 2021-02-20

### Added

- Expand tooltip system to support any bindings that are currently valid for the target

### Fixed

- Add missing Concentration Aura to the stance load options for Paladin
- Hide tooltip entries if the form/stance load condtion has not been met
- Hide tooltip etnries if the pet laod condtion has not been met

## [0.16.0] - 2021-02-18

### Added

- Add an option to show unit-frame bindings on tooltips ([h2oboi89](https://github.com/h2oboi89))
- Add an experimental WeakAura export function for spells and items, creates an icon that shows the spell/item status

## [0.15.5] - 2021-02-15

### Fixed

- Fix popups appearing behind the main Clicked frame [#50]

## [0.15.4] - 2021-02-13

### Added

- Add user-friendly tooltips explaining the binding action page
- Update Korean translations ([netaras](https://www.curseforge.com/members/netaras))

## [0.15.3] - 2021-02-01

### Fixed

- Fix binding target sorting not always following the specified order

### Removed

- Remove restriction to add target units after a dead end (i.e. player or cursor)

## [0.15.2] - 2021-01-21

### Added

- Add click-cast support for `Boss5TargetFrame` [#45]

## [0.15.1] - 2021-01-21

### Added

- Add arena 1-3 binding targets
- Add spellbook spell rank support for WoW Classic

## [0.15.0] - 2021-01-12

### Added

- Add a load condition to only load bindings in specific instance types (dungeon, raid, arena, etc.)

### Fixed

- Fix missing `exists` condition on `noX` macro conditions (`nodead`, `nopet`, etc.)

## [0.14.0] - 2021-01-08

### Added

- Add Covenant Selected load condition
- Add an option to target a unit after casting on them
- Update Korean translations ([netaras](https://www.curseforge.com/members/netaras))

### Changed

- Optimized file size
- Removed non-icons from the icon selector

## [0.13.4] - 2020-12-26

### Added

- Add Korean translations ([netaras](https://www.curseforge.com/members/netaras))

### Fixed

- Fix blacklisted unit frames intercepting clicks
- Classic: Fix a Lua error on Druid characters [#41]

## [0.13.3] - 2020-12-22

### Added

- Add an option to export and import profiles
- Add an option to share the current profile to another player

### Fixed

- Fix an error when selecting alphabetical sort

## [0.13.2] - 2020-12-19

### Fixed

- Fix blank binding configuration window on Classic with ElvUI installed [#39]

## [0.13.1] - 2020-12-17

### Fixed

- Fix tertiary mouse buttons not activating [#40]

## [0.13.0] - 2020-12-16

### Added

- Add an option to overwrite the currently queued spell
- Add dynamic icon and name for bindings that target equipment slots

### Fixed

- Fix an issue that could cause the mouse cursor to lock up when clicking on the edge of a unit frame [#37]
- Fix an error that could sometimes occur after a loading screen

## [0.12.1] - 2020-12-05

### Removed

- Remove support for loading and upgrading profiles from before version 0.5.0

### Fixed

- Fix an error when loading a profile multipe versions old

## [0.12.0] - 2020-12-05

### Added

- Add localization compatiblity with CurseForge
- Add the ability to re-order binding targets
- Add shared binding options, checkboxes will turn gray if they're enabled by a binding sharing the keybind
- Add shared binding option to allow starting of auto-attacks
- Add support for WoW Classic 1.13.6

### Changed

- Automatically apply target hostility and vital settings from the previous target when adding a new target
- Update various texts to improve consistency
- Gray out binding targets that are inactive instead of deleting them
- Improve data format of saved profiles

### Fixed

- Remove a debug message that was printed to the chat when shift-clicking a talent
- No longer unlock bindings when in a vehicle that doesn't override the action bar (will fix some world quests and the Maw)
- Unlock bindings when the override bar is visible
- Fix binding reloads if a player joins or leaves the group during combat
- Fix an excessive amount of binding reloads when in a group

## [0.11.2] - 2020-11-23

### Added

- Add new icons from patch 9.0.2

### Fixed

- Fix an error when using `-` (dash) as a keybind [#30]

## [0.11.1] - 2020-11-18

### Added

- Add the ability to close the configuration frame using Escape
- Add support for WoW 9.0.2
- Update libraries to support newly added (PvP) talents

### Changed

- Rename the binding `Actions` tab to `Action`
- Rename the `Pet Target` target to `Pet target` for consistency

### Fixed

- Remove redundant macro `exists` modifiers when it's already implied
- Fix macro attribute data display on `/cc dump`
- Fix mouse buttons sometimes not working after leaving combat or deselecting a target [#29]

## [0.11.0] - 2020-11-16

### Added

- Add icon selector for custom macros and groups [#23]
- Add a binding template for custom macros
- Add support for other targets when the unit frame target is selected [#22]
- Add a new visualization for the binding targets page, the unit frame target and regular targets are now separated and togglable using a checkbox
- Add an improved visualization of the `/cc dump` frame with clearer and more data
- Add a message when using the Mouseover target with a mouse button that the Unit Frame Target should be enabled in order to enable clicking on unit frames
- Add support for shift-clicking spells and talents in spell bindings
- Add a button to sort the bindings list alphabetically
- Add the binding search box to the scroll frame instead of above it

### Changed

- Increase the width of the binding tree to better suit groups
- Immediately process shift-clicking items rather than when the enter key is pressed
- Change the order of custom macros using the `FIRST` mode slightly. The "dangling blue cursor" will now always be cleared first
- Optimize internal binding generation for less memory usage and better performance
- Use the per-class profile by default instead of per-character profiles
- Update the healer binding template to target unit frames instead of Mouseover targets

### Removed

- Remove the ability for Mouseover targets to activate when hovering over a unit frame, the Unit Frame Target should be enabled to support unit frame clicks

### Fixed

- Fix the `/startattack` command being included in some bindings that don't include the "Target" target unit
- Fix the `/startattack` command being included in bindings that never target an enemy
- Fix groups not showing the assigned icon [#24]
- Fix custom macros using the `LAST` mode not being registered
- (Potentially) fix bindings sometimes not activating [#8]
- Fix mouseover bindings that share a keybind with a unit frame binding not working
- Fix bindings restricted to Moonkin Form while in Balance not working [#26]
- Fix that the binding targets page for custom macros showed invalid units in the dropdown

## [0.10.3] - 2020-11-05

### Changed

- Optimized binding loading for better performance

### Fixed

- Fix stance/form label for low level Druids
- Fix Lua error when entering instances if the form load option is enabled [#20]

## [0.10.2] - 2020-11-05

### Fixed

- Fix talent specializations for Priest

## [0.10.1] - 2020-11-04

### Fixed

- Fix Lua errors on new and low level characters [#16] [#18]

## [0.10.0] - 2020-11-03

### Added

- Add right click context menu items to bindings in the list view which can be used to copy, paste, duplciate, and remove them
- Add a new item template creation window which lists commonly used binding configurations
- Add the ability to create groups/folders to organize bindings [#14]
- Add a class load option [#14]
- Add a player name-realm load option [#14]
- Add a player race load option
- Add desaturated icons for unloaded bindings
- Add status page for each binding showing their generated macros and other bindings they share a keybind with
- Automatically update listed specializations, talents, and PvP talents based on the selected class/spec load option
- Remember the selected binding page (action, targets, conditions) when switching between bindings

### Changed

- Rename "Load Options" to "Conditions"
- Rename "Create" to "Add"
- Rename forms to stances when the selected class is not a Druid
- List unloaded bindings last under all loaded bindings [#12]

### Removed

- Remove the "L" and "U" labels used to indicate load state
- Remove the Copy, Paste, Duplciate, and Delete buttons from the configuration panel

### Fixed

- Fix Druid shapeshift form identifiers not always being consistent with forms selected in the UI [#13]
- Fix default dropdown value for the War Mode condition
- Fix ElvUI skinning if the "Ace3" option is disabled within ElvUI
- Fix binding list not always remembering the selected binding after deleting one
- Fix PvP talents being listed multiple times
- Fix load order for forms/stances and combat state, they no longer overwrite all other bindings [#11] [#15]

## [0.9.3] - 2020-10-22

### Changed

- [0.9.2] Only try starting auto attacks on the current target if it's enemy and exists, will prevent "you cannot attack this target" messages and automatic target switching as melee

### Removed

- [0.9.2] Removed manual option to start auto attacks

### Fixed

- [0.9.3] Start auto attacks if any of the configured target units are the current target

## [0.9.2] - 2020-10-22 [YANKED]

### Changed

- Only try starting auto attacks on the current target if it's enemy and exists, will prevent "you cannot attack this target" messages and automatic target switching as melee

### Removed

- Remove manual option to start auto attacks

## [0.9.1] - 2020-10-21

### Fixed

- Fix search box text field sometimes losing focus when typing (regression in [0.9.0])

## [0.9.0] - 2020-10-19

### Added

- Add support for new meta key modifier on MacOS (and Windows key in the future)
- Add support for Druid Incarnation: Tree of Life and other hidden shapeshift forms [#9]
- Add support for equipment slots in item bindings
- Add support for starting auto-attacks

### Changed

- Rename stances to forms
- (!) Reset form configuration due to a bug in the stances configuration

### Fixed

- Fix an error when entering a number in the "use an item" text field
- Fix the "interrupt current cast" toggle not working on item bindings

## [0.8.3] - 2020-10-14

### Changed

- Update libraries to Shadowlands compatible versions

### Fixed

- Fix a potention Lua error when opening the binding configuration frame

## [0.8.2] - 2020-10-12

### Added

- Add target alive/dead status to binding tooltips

### Changed

- Don't reload bindings on entering and leaving combat

### Fixed

- Fix a Lua error when closing the professions book

## [0.8.1] - 2020-10-10

### Changed

- Improve the blacklist UI

### Fixed

- Fix a potential error that could occur from the spellbook
- Fix the "Select from spellbook" button not working if the spellbook is already open

## [0.8.0] - 2020-10-07

### Added

- Add a target modifier for dead and alive status [#4]
- Add support for custom macro names and icons [#5]
- Add support for casting on key down instead of key up [#7]
- Add support for spellbook flyout buttons (Mage teleport, Hunter pet utilities, etc)
- Add a load option for War Mode status
- Add a load option for PvP talents
- Add a load option for pets
- Add a binding target option for pet and pet target
- Add a message to the chat when the binding configuration is opened when in combat

### Changed

- Improve formatting of binding tooltips
- Improve data loading and database upgrading
- Improve various informational messages
- Change "Mouseover unit frame" to "Unit frame"
- Change "Global (no target)" to "Default"
- Set the default target for new bindings to "Default" instead of "Target" to mimic standard Blizzard behavior

### Fixed

- Fix custom macro target option for unit frames

## [0.7.0] - 2020-09-24

### Added

- Add the ability to duplicate bindings
- Add a confirmation popup when deleting bindings (hold shift to skip)
- Add the ability to search in the binding UI (search for bindings with spells, items, keybindings, or even macro contents)
- Add the ability to blacklist frames [#2]
- Add the ability to configure target hostility for unit frame bindings
- Add the ability to specify global bindings at any part in the target order
- Add the ability to configure run options for macros, run them first, last, or enter a special mode and append them to the auto-generated command (advanced feature)
- Add slash command shortcuts to open various menus: `/cc profile`, `/cc blacklist`
- Add a debug output window: `/cc dump`

### Changed

- Improve and polish binding configuration UI
- Improve spellbook integration stability
- Disallow selecting of passive abilities in the spellbook
- Bug fixes and stability improvements

## [0.6.2] - 2020-09-19

### Changed

- Improve spellbook integration

### Removed

- Remove the escape button closing the binding configuration UI

### Fixed

- Fix a potential error that could occur when using Blizzard compact raid frames

## [0.6.1] - 2020-09-14

### Added

- Automatically remove the "blue cursor" when casting on a dead or invalid unit

## [0.6.0] - 2020-09-12

### Added

- Add the mouse cursor as a binding target (`[@cursor]`)
- Add support for copy/pasting binding data between each other
- Automatically navigate to the spellbook if the professions book is open
- Automatically disable bindings in vehicles, pet battles, and when you're possessed (whenever you have a different action bar)
- Add a load option for stances/forms
- Add support for combat flags for unit frame only bindings
- Add help tooltip texts to targeting mode dropdown items
- Add icons to the talent selected load option

### Changed

- Improve various texts
- Improve binding configuration UI performance

### Removed

- Remove the ability to designate targets _after_ the Player target in a binding as those would never be valid

### Fixed

- Fix ctrl/alt/shift + mouse button not working [#1]

## [0.5.1] - 2020-09-07

### Changed

- Merge the main development branch and the Shadowlands beta branch

## [0.5.0] - 2020-09-06

### Added

- Add support for click-cast bindings that don't use the primary mouse buttons
- Add a default target for new bindings
- Add a load option for group status (in group, in raid, not in group)
- Add a load option for a specific player in your group
- Add support for shift-clicking items to autofil them
- Add ElvUI styling to the binding configuration UI
- Add support for localization
- Add support for WoW Classic

### Changed

- Show `<No one>` for a new target option instead of an empty string
- Don't display unloaded bindings at the bottom of the binding list
- Only show the `<Remove this target>` on secondary binding targets

### Removed

- Remove disabled button for item selection

### Fixed

- Fix an error when using custom macro bindings
- Fix mouse button 3, 4, and 5 not working
- Fix prioritization on global bindings
- Fix `/stopcasting` not always being applied correctly

## [0.4.1] - 2020-08-30

### Added

- Add support for hiding the minimap button in the UI options
- Add support for Blizzard compact raid frames

### Changed

- Hide spellbook when a spell was selected

### Fixed

- Fix keybinds not always being picked up when also configured on action bars
- Fix the `[@player]` section of a macro not always appearing as the last option
- Fix an error that occured if Clicked is the only enabled addon

## [0.4.0] - 2020-08-26

### Added

- Add support for custom target / menu buttons
- Add improved support for click-cast unit frames
- Add improved spellbook integration
- Add `/cc` as an alternative to `/clicked`

### Fixed

- Fix macro bindings not being activated
- Fix multiple bindings using the same keybinding not working
- Fix open menu not working on ElvUI unit frames
- Fix mouse button 3, 4, and 5 not working
- Fix action bar buttons staying highlighted after using the spellbook
- Fix various preventable errors occuring when Clique is enabled

## [0.3.0] - 2020-08-23

### Added

- Initial public release

[Unreleased]: https://github.com/Snakybo/Clicked/compare/1.1.2...master
[1.1.2]: https://github.com/Snakybo/Clicked/releases/tag/1.1.2
[1.1.1]: https://github.com/Snakybo/Clicked/releases/tag/1.1.1
[1.1.0]: https://github.com/Snakybo/Clicked/releases/tag/1.1.0
[1.0.0]: https://github.com/Snakybo/Clicked/releases/tag/1.0.0
[0.17.2]: https://github.com/Snakybo/Clicked/releases/tag/0.17.2
[0.17.1]: https://github.com/Snakybo/Clicked/releases/tag/0.17.1
[0.17.0]: https://github.com/Snakybo/Clicked/releases/tag/0.17.0
[0.16.2]: https://github.com/Snakybo/Clicked/releases/tag/0.16.2
[0.16.1]: https://github.com/Snakybo/Clicked/releases/tag/0.16.1
[0.16.0]: https://github.com/Snakybo/Clicked/releases/tag/0.16.0
[0.15.5]: https://github.com/Snakybo/Clicked/releases/tag/0.15.5
[0.15.4]: https://github.com/Snakybo/Clicked/releases/tag/0.15.4
[0.15.3]: https://github.com/Snakybo/Clicked/releases/tag/0.15.3
[0.15.2]: https://github.com/Snakybo/Clicked/releases/tag/0.15.2
[0.15.1]: https://github.com/Snakybo/Clicked/releases/tag/0.15.1
[0.15.0]: https://github.com/Snakybo/Clicked/releases/tag/0.15.0
[0.14.0]: https://github.com/Snakybo/Clicked/releases/tag/0.14.0
[0.13.4]: https://github.com/Snakybo/Clicked/releases/tag/0.13.4
[0.13.3]: https://github.com/Snakybo/Clicked/releases/tag/0.13.3
[0.13.2]: https://github.com/Snakybo/Clicked/releases/tag/0.13.2
[0.13.1]: https://github.com/Snakybo/Clicked/releases/tag/0.13.1
[0.13.0]: https://github.com/Snakybo/Clicked/releases/tag/0.13.0
[0.12.1]: https://github.com/Snakybo/Clicked/releases/tag/0.12.1
[0.12.0]: https://github.com/Snakybo/Clicked/releases/tag/0.12.0
[0.11.2]: https://github.com/Snakybo/Clicked/releases/tag/0.11.2
[0.11.1]: https://github.com/Snakybo/Clicked/releases/tag/0.11.1
[0.11.0]: https://github.com/Snakybo/Clicked/releases/tag/0.11.0
[0.10.3]: https://github.com/Snakybo/Clicked/releases/tag/0.10.3
[0.10.2]: https://github.com/Snakybo/Clicked/releases/tag/0.10.2
[0.10.1]: https://github.com/Snakybo/Clicked/releases/tag/0.10.1
[0.10.0]: https://github.com/Snakybo/Clicked/releases/tag/0.10.0
[0.9.3]: https://github.com/Snakybo/Clicked/releases/tag/0.9.3
[0.9.2]: https://github.com/Snakybo/Clicked/releases/tag/0.9.2
[0.9.1]: https://github.com/Snakybo/Clicked/releases/tag/0.9.1
[0.9.0]: https://github.com/Snakybo/Clicked/releases/tag/0.9.0
[0.8.3]: https://github.com/Snakybo/Clicked/releases/tag/0.8.3
[0.8.2]: https://github.com/Snakybo/Clicked/releases/tag/0.8.2
[0.8.1]: https://github.com/Snakybo/Clicked/releases/tag/0.8.1
[0.8.0]: https://github.com/Snakybo/Clicked/releases/tag/0.8.0
[0.7.1]: https://github.com/Snakybo/Clicked/releases/tag/0.7.1
[0.7.0]: https://github.com/Snakybo/Clicked/releases/tag/0.7.0
[0.6.2]: https://github.com/Snakybo/Clicked/releases/tag/0.6.2
[0.6.1]: https://github.com/Snakybo/Clicked/releases/tag/0.6.1
[0.6.0]: https://github.com/Snakybo/Clicked/releases/tag/0.6.0
[0.5.1]: https://github.com/Snakybo/Clicked/releases/tag/0.5.1
[0.5.0]: https://github.com/Snakybo/Clicked/releases/tag/0.5.0
[0.4.1]: https://github.com/Snakybo/Clicked/releases/tag/0.4.1
[0.4.0]: https://github.com/Snakybo/Clicked/releases/tag/0.4.0
[0.3.0]: https://github.com/Snakybo/Clicked/releases/tag/0.3.0

[#59]: https://github.com/Snakybo/Clicked/issues/59
[#58]: https://github.com/Snakybo/Clicked/pull/58
[#57]: https://github.com/Snakybo/Clicked/issues/57
[#52]: https://github.com/Snakybo/Clicked/issues/52
[#51]: https://github.com/Snakybo/Clicked/issues/51
[#50]: https://github.com/Snakybo/Clicked/issues/50
[#45]: https://github.com/Snakybo/Clicked/issues/45
[#41]: https://github.com/Snakybo/Clicked/issues/41
[#40]: https://github.com/Snakybo/Clicked/issues/40
[#39]: https://github.com/Snakybo/Clicked/issues/39
[#37]: https://github.com/Snakybo/Clicked/issues/37
[#30]: https://github.com/Snakybo/Clicked/issues/30
[#29]: https://github.com/Snakybo/Clicked/issues/29
[#27]: https://github.com/Snakybo/Clicked/issues/27
[#26]: https://github.com/Snakybo/Clicked/issues/26
[#24]: https://github.com/Snakybo/Clicked/issues/24
[#23]: https://github.com/Snakybo/Clicked/issues/23
[#22]: https://github.com/Snakybo/Clicked/issues/22
[#20]: https://github.com/Snakybo/Clicked/issues/20
[#18]: https://github.com/Snakybo/Clicked/issues/18
[#16]: https://github.com/Snakybo/Clicked/issues/16
[#15]: https://github.com/Snakybo/Clicked/issues/15
[#14]: https://github.com/Snakybo/Clicked/issues/14
[#13]: https://github.com/Snakybo/Clicked/issues/13
[#12]: https://github.com/Snakybo/Clicked/issues/12
[#11]: https://github.com/Snakybo/Clicked/issues/11
[#9]: https://github.com/Snakybo/Clicked/issues/9
[#8]: https://github.com/Snakybo/Clicked/issues/8
[#7]: https://github.com/Snakybo/Clicked/issues/7
[#5]: https://github.com/Snakybo/Clicked/issues/5
[#4]: https://github.com/Snakybo/Clicked/issues/4
[#2]: https://github.com/Snakybo/Clicked/issues/2
[#1]: https://github.com/Snakybo/Clicked/issues/1
