# Changelog

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

[Unreleased]: https://github.com/Snakybo/Clicked/compare/0.9.0...master
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

[#9]: https://github.com/Snakybo/Clicked/issues/9
[#7]: https://github.com/Snakybo/Clicked/issues/7
[#5]: https://github.com/Snakybo/Clicked/issues/5
[#4]: https://github.com/Snakybo/Clicked/issues/4
[#2]: https://github.com/Snakybo/Clicked/issues/2
[#1]: https://github.com/Snakybo/Clicked/issues/1
