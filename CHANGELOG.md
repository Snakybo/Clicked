# Changelog

This document will contain a chronological list of all notable changes made to Clicked.

The format of this changelog is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). The versioning scheme used is [Semantic Versioning](https://semver.org/spec/v2.0.0.html), the notable breakpoints of what defines a major, minor, or patch version are as follows:

* The MAJOR component is only used ceremonially and will likely not be incremented unless a significant rewrite happens that does not have backwards compatibility.
* The MINOR component is used whenever a version has backwards-compatible profile changes. This also indicates that the user can not switch back to a previous MINOR version without using a backup.
* The PATCH component is used for versions that do not contain profile format changes. Users can freely switch between PATCH versions without risk of data loss.

## [Unreleased]

### Added

* Add action bar page (`bar` and `nobar`) macro conditions [#183]
* Add input validation to bonus bar and action bar page macro conditions
* Add specialization role load condtion [#160]

### Fixed

* Properly hide unavailable load conditions on Classic [#223]

## [1.16.2] - 2024-09-05

### Added

* Add duplicate option to groups

### Fixed

* Fix item bindings not always loading upon login
* Fix various minor Lua errors when deleting bindings
* Improve behavior when changing scope of groups

### Changed

* Optimize binding reload logic for better performance

## [1.16.1] - 2024-08-30

### Fixed

* Fix unit select and unit menu bindings not working
* Fix Lua error for invalid localization string

## [1.16.0] - 2024-08-29

### Added

* Add multi-selection to the bindings list, use ctrl+click and shift+click to select multiple bindings
* Add multi-selection editing, select multiple items and edit them all at once
* Remember last selected sorting method when closing the binding window
* Remember last selected binding(s) when closing the binding window
* Add profession abilities to spell autofill
* Add profession abilities to spellbook import
* Add Dominos action bars to quick start import
* Include shapeshift-specific action bars in quick start import
* Include all 7 action bars in quick start import, up from 4
* Include all 15 Bartender4 action bars in quick start import, up from 6
* Include all 15 ElvUI bars action bars in quick start import, up from 6
* Add more information to a bunch of tooltips in the binding configuration window
* Add spell ranks to spell autofill in Classic Era
* Create bindings when dragging a macro into the binding configuration window
* Add quick start import from macros
* Add chat command to disable (or re-enable) the self-cast warning

### Fixed

* Fix a potential issue when pasting binding contents onto a binding in a different scope
* Optimize binding configuration window performance
* Fix an issue where the binding configuration window would reload completely when a binding is reloaded
* Fix dragging bindings onto an empty space not doing anything
* Fix duplicate binding check when importing from spellbook or action bar
* Fix cancelaura spell input not parsing correctly [#216] [#217]
* Fix spell autofill for flyout abilities [#212]
* Fix a game freeze when clearing the search box
* Fix macro length calculation for non-English letters
* Fix Lua error in the keyboard visualizer
* Fix missing UI elements in unit frame blacklist

### Changed

* Move search bar above the bindings list
* Merge the import window into the binding window
* Merge the export window into the binding window
* Update design of various UI screens
* Update copy in various places
* Show self-cast warning upon login

### Removed

* Remove the ability to search for macro contents
* Remove WeakAuras integration

## [1.15.6] - 2024-08-18

### Added

* Show icon in the selected dropdown item

### Fixed

* Fix TOC version for The War Within 11.0.2
* Fix potential Lua error when retrieving talents on Cataclysm Classic
* Fix potential Lua error when importing from spellbook in Classic Era
* Fix minor UI issues in Classic Era

## [1.15.5] - 2024-08-07

### Fixed

* Fix Lua error when opening the targets page on Cataclysm Classic on Hunter and Warlock [#210]

## [1.15.4] - 2024-08-06

### Added

* Add support for the Earthen race

### Fixed

* Fix Lua error when opening the targets page on Cataclysm Classic [#209]

## [1.15.3] - 2024-07-30

### Added

* Add pet abilities to spell autofill
* Add drag support for pet abilities into the spell name input field

### Fixed

* Fix Lua error when dragging a spell from the spellbook into the spell name input field [#203]
* Fix dragging spells from the spellbook into the binding configuration window

## [1.15.2] - 2024-07-28

### Fixed

* Fix Lua error when importing from spellbook [#201]

## [1.15.1] - 2024-07-25

### Added

* Include talent tree in spell library
* Include PvP talents in spell library

### Fixed

* Fix macro conditional sorting for `bonusbar`, `advflyable`, and dynamic flying
* Fix Lua error in the key visualizer when including action bar buttons [#199]

### Changed

* Rename Dynamic Flying to Skyriding

## [1.15.0] - 2024-07-24

### Added

* Add support for The War Within 11.0.0
* Add support for Classic 1.15.3
* Add Dynamic Flying macro condition
* Add message when a generated macro is too long to be used
* Add auto-completion to the spell name input field, containing all spells in the spellbook
* Add the ability to drag spells from the spellbook into the spell name input field
* Add icons from The War Within 11.0.2 to icon picker
* Add icons from Cataclysm Classic 4.4.0 to icon picker
* Add icons from Classic 1.15.3 to icon picker
* Update PvP talent data

### Fixed

* Fix a Lua error when using the keyboard visualizer with ElvUI enabled on Classic
* Fix double 'Z' keys on the AZERTY layout in the keyboard visualizer

### Removed

* Remove spellbook integration

## [1.14.10] - 2024-06-19

### Fixed

* Fix a Lua error when playing Mage in Cataclysm Classic [#196] (by [Aeceon])

### Changed

* Spells are now always saved as IDs instead of names [#195]

## [1.14.9] - 2024-05-20

### Added

* Add support for Dragonflight 10.2.7

## [1.14.8] - 2024-05-07

### Fixed

* Fix message about using a development version showing up on non-development versions
* Fix bindings not correctly loading after talent changes in Retail

## [1.14.7] - 2024-05-01

### Added

* Add support for Cataclysm Classic 4.4.0
* Add new talent selection UI for Cataclysm Classic

## [1.14.6] - 2024-04-07

### Added

* Add support for Classic Era 1.15.2

### Fixed

* Fix not all frames being visible in the frame blacklist dropdown [#193]

## [1.14.5] - 2024-03-24

### Added

* Add support for Dragonflight 10.2.6
* Add icons from Dragonflight 10.2.6 to icon picker

### Fixed

* Fix error when unequipping items that are bound via slot IDs [#191]

## [1.14.4] - 2024-02-11

### Added

* Add support for Classic Era 1.15.1
* Add icons from Classic Era 1.15.1 to icon picker
* Onky re-process bingings when entering and leaving combat if required [#189]

## [1.14.3] - 2024-01-17

### Added

* Add support for Dragonflight 10.2.5
* Add icons from Dragonflight 10.2.5 to icon picker

## [1.14.2] - 2023-12-19

### Fixed

* Fix Lua error on Classic Era when accessing macro conditions on a Druid [#186]
* Display both Tree of Life and Moonkin Form in the Form macro condition for Druid on Classic Era

## [1.14.1] - 2023-12-03

### Added

* Add support for rune engravings on Classic Era 1.15.0

## [1.14.0] - 2023-12-01

### Added

* Add keybind visualizer window
* Bind all unassigned modifier key combinations when automatic binding is enabled [#184]
  * This will now include combinations such as 'ALT-SHIFT-Q', 'CTRL-ALT-SHIFT-Q', etc.
* Improved keybind button, press 'ESCAPE' to cancel keybind mode or press the right mouse button to unassign the current keybind
* Add support for Classic Era 1.15.0
* Add icons from Classic Era 1.15.0 to icon picker

### Fixed

* Fix configuration window(s) not always opening
* Hopefully fix modifier key combinations on MacOS [#90] [#182]

## [1.13.5] - 2023-11-08

### Added

* Add support for Dragonflight 10.2.0
* Add icons from Dragonflight 10.2.0 to icon picker
* Add icons from WotLK Classic 3.4.3 to icon picker
* Add icons from Classic Era 1.14.4 to icon picker
* Update PvP talent data

### Fixed

* Fix icon IDs not always matching the icon file name

## [1.13.4] - 2023-10-10

### Added

* Close the binding configuration window automatically when entering combat
  * It will be reopened when leaving combat if it was open before
  * Attempting to open it during combat will instead open it as soon as combat ends
* Add support for WotLK Classic 3.4.3
* Add icons from WotLK Classic 3.4.3 to icon picker

### Fixed

* Fix action blocked error when the binding configuration window is open [#179]
* Fix a Lua error when LibSharedMedia-3.0 is not installed [#181]

## [1.13.3] - 2023-09-06

### Added

* Add support for WotLK Classic 3.4.2
* Add support for Classic Era 1.14.4
* Add support for Dragonflight 10.1.7
* Add icons from Dragonflight 10.1.7 to icon picker

## [1.13.2] - 2023-07-12

### Fixed

* Fix Lua error on macro conditions page for Augmentation Evoker [#172]

## [1.13.1] - 2023-07-12

### Added

* Add support for Dragonflight 10.1.5
* Add icons from Dragonflight 10.1.5 to icon picker
* Update PvP talent data
* Add new selection UI for both talents and PvP talents
* Improve talent selection input field
  * Show all available talents when focusing an empty input field
  * Show predicted talents when focusing an input field
  * Improve behavior of escape and focus loss
  * Add navigation through the entire talent tree using (shift-) tab or the arrow keys
  * Add the ability to show all talents instead of only the current prediction using shift-space
  * Improve the talent prediction algorithm

## [1.13.0] - 2023-07-11 [YANKED]

### Added

* Add support for Dragonflight 10.1.5
* Add icons from Dragonflight 10.1.5 to icon picker
* Update PvP talent data
* Add new selection UI for both talents and PvP talents
* Improve talent selection input field
  * Show all available talents when focusing an empty input field
  * Show predicted talents when focusing an input field
  * Improve behavior of escape and focus loss
  * Add navigation through the entire talent tree using (shift-) tab or the arrow keys
  * Add the ability to show all talents instead of only the current prediction using shift-space
  * Improve the talent prediction algorithm

## [1.12.2] - 2023-06-22

### Added

* Use new import and export window for profile import, export, and direct player share
* Improve warning shown when the self-cast modifier is enabled
* Add `bonusbar` and `nobonusbar` macro conditions
  * For Dragonriding, use bonus bar 5, for Dracthyr Soar use bonus bar 1
* Add syntax higlighting to the generated macro text
* Add monospaced font for the macro text fields to improve readability
* Add the `/clicked options` (or `/clicked opt`) command to open the addon options

### Fixed

* Fix conflict between Dragonriding and Evoker abilities [#170] (by [nihilistzsche])
* Fix potential Lua error in talent selection dropdown

### Removed

* Remove the `/clicked profile` and `/clicked blacklist` commands

## [1.12.1] - 2023-05-21

### Fixed

* Fix Lua error when pressing tab on the talent selection dropdown
* Fix binding config sorting not working

### Changed

* Don't open the top-most group automatically when opening the binding configuration window

## [1.12.0] - 2023-05-16

### Added

* Add option to disable the addon compartment button to the options menu
* Add new import and export window for individual bindings and groups [#141]
* Add global bindings, which are always active regardless of the selected profile [#142]

### Fixed

* Fix Lua error when using shapeshift load condition on WotLK Classic

## [1.11.2] - 2023-05-07

### Fixed

* Fix Lua error on WotLK Classic [#169]

## [1.11.1] - 2023-05-03

### Added

* Add support for Dragonflight 10.1.0
* Add icons from Dragonflight 10.1.0 to icon picker
* Add support for AddOn compartment
* Use in-game API to retrieve talent data
  * Make new talent selection UI available for non en-US locales
* Update PvP talent data

### Fixed

* Fix talent dropdown item sometimes being unclickable

## [1.11.0] - 2023-03-22

### Added

* Add support for Dragonflight 10.0.7
* Add new "Advanced Flyable" macro conditional to determine whether Dragonriding is possible
* Add icons from Dragonflight 10.0.5 and 10.0.7 to icon picker

## [1.10.6] - 2023-01-26

### Added

* Add support for Dragonflight 10.0.5
* Add support for WotLK Classic 3.4.1

### Fixed

* Fix occasional Lua error when using forms [#166]
* Fix Lua error on stance macro load option on WotLK Classic

## [1.10.5] - 2023-01-06

### Fixed

* Fix Lua error when using the talent load condition on WotLK Classic [#163]

## [1.10.4] - 2023-01-06

### Added

* New binding reload and status logic, improving performance significantly

### Fixed

* Fix talent load options not always being in the correct state after switching spec or talent loadout
* Fix Lua error related to talent information not being available sometimes
* Fix talent tree spell tooltips not always showing "Bound to" text

## [1.10.3] - 2022-12-14

### Fixed

* Fix Lua error for non-English locales when using the talent load option [#155]

## [1.10.2] - 2022-12-13

### Fixed

* Fix talent selection input on non-English locales [#146]
* Fix a Lua error when selecting spell from the spellbook
* Fix talent known condition not working with talents granted automatically
* Improve performance when switching specializations or talent loadouts

## [1.10.1] - 2022-11-28

### Added

* Removed forced class and specialization load option when the talent load option is enabled

## [1.10.0] - 2022-11-28

### Added

* Add `/cancelform` option [#133] [#121]
* Add new talent selection UI [#127] [#136]
  * Add the ability to combine talent requirments (talent 1 AND talent 2 OR talent 3)
  * Add the ability to negate talent requirements (NOT talent 1)

### Fixed

* Fix pasting binding data sometimes hiding bindings completely
* Fix minor import related issues
* Check for overriden spells with the spell known load condition [#137]

### Changed

* Disable the automatic binding of unassigned modifier keys by default [#134]

## [1.9.1] - 2022-11-16

### Added

* Update Chinese translations (by Jokey)
* Update Evoker talent data

### Fixed

* Improve performance of unit tooltips

## [1.9.0] - 2022-11-15

### Added

* Add support for Dragonflight 10.0.2
* Add the option to automatically import bindings from action bars (Default UI, ElvUI, and Bartender4) [#120]
* Update talent data

### Fixed

* Fix the spell known load condition not correctly checking if the spell is known (by [novsirion])
* Fix not all data being imported when importing a profile [#128]

## [1.8.1] - 2022-10-26

### Fixed

* Fix class and talent specialization options not always being force enabled on Retail
* Fix forced class and specialization options not reloading bindings
* Fix automatically bound modifiers overriding built-in keybindings
* Fix missing Paladin stances
* Fix missing Arms Warrior stance
* Fix talent selected option not always behaving accurately
* Improve binding search bar performance

## [1.8.0] - 2022-10-25

### Added

* Add support for Dragonflight 10.0.0
* Add support for the Dracthyr race [#104]
* Add support for the Evoker class [#104]
* Add support for the new talent tree system [#105]
* Add 10.0.0 icons to icon picker [#107]
* Add option to automatically bind unassigned modifier keys to cast a binding
  * Creating a binding for 'Q' can automatically also bind 'SHIFT-Q', 'ALT-Q', etc
* Add tooltip explaining search filters to search box
* Add small delay before showing tooltips
* Add the ability to invert stance selection, changing the macro from `form` to `noform`
* Add stance macro condition for Warrior
* Add stance/form macro conditional for Classic [#68] [#69] (by [yannlugrin])
* Simplify frame blacklist dropdown

### Fixed

* Fix text color not always being set correctly in the binding list
* Fix compact unit frame center status icon not being registered for click-casting

### Changed

* Removed covenant selected load option
* Hide macro conditions panel from custom macros

## [1.7.7] - 2022-09-02

### Fixed

* Fix keybinds being active while in a vehicle on WotLK Classic
* Fix WotLK Classic specific features not working due to Blizzard code change
* Fix empty groups not being visible with an empty search term

## [1.7.6] - 2022-08-31

### Added

* Add search filters
  * Type `k:` to search for exact keybinds, for example `k:f` to search for all bindings bound to the `F` key
* Ignore group names in searches

### Fixed

* Fix a Lua error on Classic Era when opening the binding load condtions page

## [1.7.5] - 2022-08-29

### Added

* Add support for WotLK Classic 3.4.0
* Add talent selected load condtion for WotLK Classic
* Add specialization selected load condition for WotLK Classic [#101]
* Add improved (and hopefully more complete) icon data for all versions
* Add the ability to search for icons by file ID

### Changed

* Automatically set the class load condition when importing from spellbook

### Fixed

* Improve icon picker load speed
* Fix a Lua when using the shapeshit macro condtion in addition to the class load condtion

## [1.7.4] - 2022-08-25

### Fixed

* Fix item equipment slot IDs not casting [#108]

## [1.7.3] - 2022-08-22

### Changed

* Change `/use` command to `/cast` to prioritize spells over items [#102]

## [1.7.2] - 2022-08-17

### Added

* Switch to single addon package release mode
* Update Chinese translations (by Jokey)
* Add support for Shadowlands 9.2.7

### Fixed

* Fix click-cast targeting issue after entering or leaving combat

## [1.7.1] - 2022-08-10

### Fixed

* Fix Lua error when a macro icon is a file ID [#100]

## [1.7.0] - 2022-08-04

### Added

* Add combat modifier to unit target and menu bindings [#97]
* Allow `channeling` and `nochanneling` without a value
* Add cancelaura binding type [#76]

## [1.6.12] - 2022-06-27

### Fixed

* Fix error in ToC

## [1.6.11] - 2022-06-01

### Added

* Add support for Shadowlands 9.2.5
* Update talent data for WoW 9.2.5
* Update icons for WoW 9.2.5

## [1.6.10] - 2022-05-05

### Added

* Add support for TBC Classic 2.5.4

### Changed

* Switch to single package release

### Fixed

* Fix binding config search bar permanently filtering out items

## [1.6.9] - 2022-04-02

### Fixed

* Fix Restoration Druid 4-Set not being detected as Incarnation: Tree of Life (by [Squishes])
* Fix covenant load condition not always being triggered immediately after switching covenants

## [1.6.8] - 2022-02-22

### Added

* Add support for Shadowlands 9.2.0
* Add support for Classic Era 1.14.2
* Add support for TBC Classic 2.5.3
* Update talent data for WoW 9.2.0
* Update icons for WoW 9.2.0
* Update icons for WoW Classic 1.14.2
* Update icons for WoW Burning Crusade Classic 2.5.3
* Desaturate group icons when all bindings in a group are disabled [#91]
* Sort groups with active bindings above groups without [#91]
* Update Chinese translations (by Jokey)

## [1.6.7] - 2021-11-12

### Fixed

* Fix META key not working in conjunction with other modifiers [#84] (by [tflo])
* Visualize META key as CMD on Mac clients

## [1.6.6] - 2021-11-03

### Added

* Add support for Shadowlands 9.1.5
* Update talent data for WoW 9.1.5
* Update icons for WoW 9.1.5
* Update icons for Burning Crusade Classic 2.5.2
* Update icons for WoW Classic 1.14.0

## [1.6.5] - 2021-09-29

### Added

* Add support for Classic Era 1.14.0

### Fixed

* Fix "Bound to" tooltip text appearing twice on talents

## [1.6.4] - 2021-09-01

### Added

* Add support for TBC Classic 2.5.2

## [1.6.3] - 2021-08-07

### Added

* Update Chinese translations (by Jokey)

## [1.6.2] - 2021-07-12

### Fixed

* **Breaking Change** Fix zone name condition not working when a zone has a comma in the name, a semicolon is now used to OR the zone load condition
* Fix "open unit menu" not working with all unit frames (VuhDo)

## [1.6.1] - 2021-06-30

### Fixed

* Fix error when opening the binding configuration window with ElvUI skinning enabled

## [1.6.0] - 2021-06-29

### Added

* Add support for Shadowlands 9.1
* Add binding template for a hovercast spell [#71]
* Add the ability to create bindings by dragging spells/items into the Clicked window [#71]
* Improve visualization of unloaded bindings [#74] (by [gitarrg])
* Add "spell known" load condition for WeakAuras export
* Add the ability to remove a spell rank on Classic Era and TBC Classic [#70]
* Make import from spellbook only import new spells on subsequent imports [#75]

## [1.5.3] - 2021-06-08

### Fixed

* Fix binding configuration pages not properly redrawing (revert from 1.5.2)

## [1.5.2] - 2021-06-03

### Added

* Prevent binding configuration window from redrawing the selected element

### Fixed

* Fix a rare occurance where unit frames would not respect the cast on key down setting

## [1.5.1] - 2021-05-27

### Added

* Add "target of mouseover" target (`@mouseovertarget`)
* Add support for multiple "bound to" labels on spell tooltips

### Fixed

* Fix a Lua error if click-cast frames don't have a name [#55]
* Fix a Lua error when opening the binding configuration window if the profession spell book is open
* Fix an issue with the on key down setting not being respected in all scenarios [#54]

## [1.5.0] - 2021-05-19

### Fixed

* Fix Lua error on characters migrated from Classic Era

## [1.4.1] - 2021-05-17

### Added

* Show keybind in spell tooltip when bound

### Fixed

* Fix icon picker on Classic Era and TBC Classic

## [1.4.0] - 2021-05-13

### Added

* Add support for TBC Classic 2.5.1
* Add missing instance type load option to Classic Era
* Hide spellbook spell icon highlight when an active binding casts the spell
* Add `channeling` and `nochanneling` macro options

### Fixed

* Fix a potential Lua error when opening binding load options

### Removed

* Remove `Focus` binding target on Classic Era
* Remove `Arena` binding targets on Classic Era

## [1.3.2] - 2021-04-27

### Fixed

* Fix a Lua error when searching if an equipment slot has no item equipped [#64]

## [1.3.1] - 2021-04-25

### Added

* Add Chinese translations (by Jokey)

### Changed

* Allow `/startattack` to target a unit if none is specified [#63]
* Don't enable the "Start auto attacks" for new bindings automatically

## [1.3.0] - 2021-04-17

### Added

* Add shared binding option to start pet attacks

### Fixed

* Fixed a Lua error when copy-pasting binding data

## [1.2.0] - 2021-04-06

### Added

* Show icon next to spell/item ID
* Show spell/item tooltip when hovering over the ID
* Add item equipped load option to bindings
* Add tooltips to load options
* Add quick start create option to import the entire spellbook and talent pane

### Fixed

* Fix equipped usable items not working after changing equipped items
* Fix empty `/tar` commands being generated if a target cannot be inferred from the binding

## [1.1.2] - 2021-03-29

### Fixed

* Fix Lua error on Classic Era [#59]

## [1.1.1] - 2021-03-29

### Fixed

* Fix PvP talent ordering for some specs
* Fix a Lua error when creating a new profile [#58] (by [hythloday])

## [1.1.0] - 2021-03-26

### Added

* Update retail icons with new ones from 9.0.5

### Fixed

* Fix binding config occasionally resetting input field text whilst typing
* Fix spell ranks being ignored on Classic Era
* Fix not being able to create a "Open the unit menu" binding

## [1.0.0] - 2021-03-21

### Added

* Show spell and item ID next to text field
* Add `stealth`/`nostealth` macro condition
* Add `mounted`/`nomounted` macro condition
* Add `outdoors`/`indoors` macro condition
* Add `flying`/`noflying` macro condition
* Add `flyable`/`noflyable` macro condition
* Add `swimming`/`noswimming` macro condition
* Add Zone Name(s) load condition, specify multiple using comma as a seperator, or use `!` to negate a condition
* Add the option to execute multiple actions in a single macro, see action groups on the binding Action page
* Add a new binding type to replace the "Append" macro behavior
* Add shared binding options to macros

### Fixed

* Fix various issues with binding display names
* Improve behavior of target spell and item text field shift-clicks
* Fix shared binding options being changable during combat
* Fix custom macros that call protected functions not working [#57]

### Removed

* Remove the macro mode dropdown, the "Run first" and "Run last" behavior can now be achieved by modifying the action group

### Changed

* Save spells and items as ID instead of name
* Separate macro conditions from load conditions
* Replace the binding type dropdown with a the right click context menu option
* Hide binding status page if the binding is not loaded
* Hide binding status page from target/menu bindings
* Simplify the binding status page, remove the "local" macro and condense the related bindings into one list
* Hide binding action page from "Target the unit" and "Open the unit menu" binding types
* Slightly increase width of the binding configuration window
* Rework the binding templates list, it now lists presets of all available binding types, to replace the binding type dropdown

## [0.17.2] - 2021-03-10

### Added

* Add support for Shadowlands 9.0.5

## [0.17.1] - 2021-02-27

### Fixed

* Fix an issue where the `exists` check was incorrectly added when used in combination with the Stance/Form condition

## [0.17.0] - 2021-02-27

### Added

* Add support for mouse button 6+ [#52]

### Changed

* Major internal refactor and cleanup

### Fixed

* Fix an issue where some abilities appear twice in tooltips
* Fix an issue where uncastable spells or items would appear in the tooltip [#51]

## [0.16.2] - 2021-02-20

### Fixed

* Fix an error when logging in on Classic Era
* Fix an error when enabling tooltips on Classic Era

## [0.16.1] - 2021-02-20

### Added

* Expand tooltip system to support any bindings that are currently valid for the target

### Fixed

* Add missing Concentration Aura to the stance load options for Paladin
* Hide tooltip entries if the form/stance load condtion has not been met
* Hide tooltip etnries if the pet laod condtion has not been met

## [0.16.0] - 2021-02-18

### Added

* Add an option to show unit-frame bindings on tooltips (by [h2oboi89])
* Add an experimental WeakAura export function for spells and items, creates an icon that shows the spell/item status

## [0.15.5] - 2021-02-15

### Fixed

* Fix popups appearing behind the main Clicked frame [#50]

## [0.15.4] - 2021-02-13

### Added

* Add user-friendly tooltips explaining the binding action page
* Update Korean translations (by [netaras](https://www.curseforge.com/members/netaras))

## [0.15.3] - 2021-02-01

### Fixed

* Fix binding target sorting not always following the specified order

### Removed

* Remove restriction to add target units after a dead end (i.e. player or cursor)

## [0.15.2] - 2021-01-21

### Added

* Add click-cast support for `Boss5TargetFrame` [#45]

## [0.15.1] - 2021-01-21

### Added

* Add arena 1-3 binding targets
* Add spellbook spell rank support for Classic Era

## [0.15.0] - 2021-01-12

### Added

* Add a load condition to only load bindings in specific instance types (dungeon, raid, arena, etc.)

### Fixed

* Fix missing `exists` condition on `noX` macro conditions (`nodead`, `nopet`, etc.)

## [0.14.0] - 2021-01-08

### Added

* Add Covenant Selected load condition
* Add an option to target a unit after casting on them
* Update Korean translations (by [netaras](https://www.curseforge.com/members/netaras))

### Changed

* Optimized file size
* Removed non-icons from the icon selector

## [0.13.4] - 2020-12-26

### Added

* Add Korean translations (by [netaras](https://www.curseforge.com/members/netaras))

### Fixed

* Fix blacklisted unit frames intercepting clicks
* Fix a Lua error on Druid characters on Classic Era [#41]

## [0.13.3] - 2020-12-22

### Added

* Add an option to export and import profiles
* Add an option to share the current profile to another player

### Fixed

* Fix an error when selecting alphabetical sort

## [0.13.2] - 2020-12-19

### Fixed

* Fix blank binding configuration window on Classic Era with ElvUI installed [#39]

## [0.13.1] - 2020-12-17

### Fixed

* Fix tertiary mouse buttons not activating [#40]

## [0.13.0] - 2020-12-16

### Added

* Add an option to overwrite the currently queued spell
* Add dynamic icon and name for bindings that target equipment slots

### Fixed

* Fix an issue that could cause the mouse cursor to lock up when clicking on the edge of a unit frame [#37]
* Fix an error that could sometimes occur after a loading screen

## [0.12.1] - 2020-12-05

### Removed

* Remove support for loading and upgrading profiles from before version 0.5.0

### Fixed

* Fix an error when loading a profile multipe versions old

## [0.12.0] - 2020-12-05

### Added

* Add localization compatiblity with CurseForge
* Add the ability to re-order binding targets
* Add shared binding options, checkboxes will turn gray if they're enabled by a binding sharing the keybind
* Add shared binding option to allow starting of auto-attacks
* Add support for Classic Era 1.13.6

### Changed

* Automatically apply target hostility and vital settings from the previous target when adding a new target
* Update various texts to improve consistency
* Gray out binding targets that are inactive instead of deleting them
* Improve data format of saved profiles

### Fixed

* Remove a debug message that was printed to the chat when shift-clicking a talent
* No longer unlock bindings when in a vehicle that doesn't override the action bar (will fix some world quests and the Maw)
* Unlock bindings when the override bar is visible
* Fix binding reloads if a player joins or leaves the group during combat
* Fix an excessive amount of binding reloads when in a group

## [0.11.2] - 2020-11-23

### Added

* Add icons from Shadowlands 9.0.2 to icon picker

### Fixed

* Fix an error when using `-` (dash) as a keybind [#30]

## [0.11.1] - 2020-11-18

### Added

* Add the ability to close the configuration frame using Escape
* Add support for Shadowlands 9.0.2
* Update libraries to support newly added (PvP) talents

### Changed

* Rename the binding `Actions` tab to `Action`
* Rename the `Pet Target` target to `Pet target` for consistency

### Fixed

* Remove redundant macro `exists` modifiers when it's already implied
* Fix macro attribute data display on `/cc dump`
* Fix mouse buttons sometimes not working after leaving combat or deselecting a target [#29]

## [0.11.0] - 2020-11-16

### Added

* Add icon selector for custom macros and groups [#23]
* Add a binding template for custom macros
* Add support for other targets when the unit frame target is selected [#22]
* Add a new visualization for the binding targets page, the unit frame target and regular targets are now separated and togglable using a checkbox
* Add an improved visualization of the `/cc dump` frame with clearer and more data
* Add a message when using the Mouseover target with a mouse button that the Unit Frame Target should be enabled in order to enable clicking on unit frames
* Add support for shift-clicking spells and talents in spell bindings
* Add a button to sort the bindings list alphabetically
* Add the binding search box to the scroll frame instead of above it

### Changed

* Increase the width of the binding tree to better suit groups
* Immediately process shift-clicking items rather than when the enter key is pressed
* Change the order of custom macros using the `FIRST` mode slightly. The "dangling blue cursor" will now always be cleared first
* Optimize internal binding generation for less memory usage and better performance
* Use the per-class profile by default instead of per-character profiles
* Update the healer binding template to target unit frames instead of Mouseover targets

### Removed

* Remove the ability for Mouseover targets to activate when hovering over a unit frame, the Unit Frame Target should be enabled to support unit frame clicks

### Fixed

* Fix the `/startattack` command being included in some bindings that don't include the "Target" target unit
* Fix the `/startattack` command being included in bindings that never target an enemy
* Fix groups not showing the assigned icon [#24]
* Fix custom macros using the `LAST` mode not being registered
* (Potentially) fix bindings sometimes not activating [#8]
* Fix mouseover bindings that share a keybind with a unit frame binding not working
* Fix bindings restricted to Moonkin Form while in Balance not working [#26]
* Fix that the binding targets page for custom macros showed invalid units in the dropdown

## [0.10.3] - 2020-11-05

### Changed

* Optimized binding loading for better performance

### Fixed

* Fix stance/form label for low level Druids
* Fix Lua error when entering instances if the form load option is enabled [#20]

## [0.10.2] - 2020-11-05

### Fixed

* Fix talent specializations for Priest

## [0.10.1] - 2020-11-04

### Fixed

* Fix Lua errors on new and low level characters [#16] [#18] (by [Squishes])

## [0.10.0] - 2020-11-03

### Added

* Add right click context menu items to bindings in the list view which can be used to copy, paste, duplciate, and remove them
* Add a new item template creation window which lists commonly used binding configurations
* Add the ability to create groups/folders to organize bindings [#14]
* Add a class load option [#14]
* Add a player name-realm load option [#14]
* Add a player race load option
* Add desaturated icons for unloaded bindings
* Add status page for each binding showing their generated macros and other bindings they share a keybind with
* Automatically update listed specializations, talents, and PvP talents based on the selected class/spec load option
* Remember the selected binding page (action, targets, conditions) when switching between bindings

### Changed

* Rename "Load Options" to "Conditions"
* Rename "Create" to "Add"
* Rename forms to stances when the selected class is not a Druid
* List unloaded bindings last under all loaded bindings [#12]

### Removed

* Remove the "L" and "U" labels used to indicate load state
* Remove the Copy, Paste, Duplciate, and Delete buttons from the configuration panel

### Fixed

* Fix Druid shapeshift form identifiers not always being consistent with forms selected in the UI [#13]
* Fix default dropdown value for the War Mode condition
* Fix ElvUI skinning if the "Ace3" option is disabled within ElvUI
* Fix binding list not always remembering the selected binding after deleting one
* Fix PvP talents being listed multiple times
* Fix load order for forms/stances and combat state, they no longer overwrite all other bindings [#11] [#15]

## [0.9.3] - 2020-10-22

### Changed

* [0.9.2] Only try starting auto attacks on the current target if it's enemy and exists, will prevent "you cannot attack this target" messages and automatic target switching as melee

### Removed

* [0.9.2] Removed manual option to start auto attacks

### Fixed

* [0.9.3] Start auto attacks if any of the configured target units are the current target

## [0.9.2] - 2020-10-22 [YANKED]

### Changed

* Only try starting auto attacks on the current target if it's enemy and exists, will prevent "you cannot attack this target" messages and automatic target switching as melee

### Removed

* Remove manual option to start auto attacks

## [0.9.1] - 2020-10-21

### Fixed

* Fix search box text field sometimes losing focus when typing (regression in [0.9.0])

## [0.9.0] - 2020-10-19

### Added

* Add support for new meta key modifier on MacOS (and Windows key in the future)
* Add support for Druid Incarnation: Tree of Life and other hidden shapeshift forms [#9]
* Add support for equipment slots in item bindings
* Add support for starting auto-attacks

### Changed

* Rename stances to forms
* (!) Reset form configuration due to a bug in the stances configuration

### Fixed

* Fix an error when entering a number in the "use an item" text field
* Fix the "interrupt current cast" toggle not working on item bindings

## [0.8.3] - 2020-10-14

### Changed

* Update libraries to Shadowlands compatible versions

### Fixed

* Fix a potention Lua error when opening the binding configuration frame

## [0.8.2] - 2020-10-12

### Added

* Add target alive/dead status to binding tooltips

### Changed

* Don't reload bindings on entering and leaving combat

### Fixed

* Fix a Lua error when closing the professions book

## [0.8.1] - 2020-10-10

### Changed

* Improve the blacklist UI

### Fixed

* Fix a potential error that could occur from the spellbook
* Fix the "Select from spellbook" button not working if the spellbook is already open

## [0.8.0] - 2020-10-07

### Added

* Add a target modifier for dead and alive status [#4]
* Add support for custom macro names and icons [#5]
* Add support for casting on key down instead of key up [#7]
* Add support for spellbook flyout buttons (Mage teleport, Hunter pet utilities, etc)
* Add a load option for War Mode status
* Add a load option for PvP talents
* Add a load option for pets
* Add a binding target option for pet and pet target
* Add a message to the chat when the binding configuration is opened when in combat

### Changed

* Improve formatting of binding tooltips
* Improve data loading and database upgrading
* Improve various informational messages
* Change "Mouseover unit frame" to "Unit frame"
* Change "Global (no target)" to "Default"
* Set the default target for new bindings to "Default" instead of "Target" to mimic standard Blizzard behavior

### Fixed

* Fix custom macro target option for unit frames

## [0.7.0] - 2020-09-24

### Added

* Add the ability to duplicate bindings
* Add a confirmation popup when deleting bindings (hold shift to skip)
* Add the ability to search in the binding UI (search for bindings with spells, items, keybindings, or even macro contents)
* Add the ability to blacklist frames [#2]
* Add the ability to configure target hostility for unit frame bindings
* Add the ability to specify global bindings at any part in the target order
* Add the ability to configure run options for macros, run them first, last, or enter a special mode and append them to the auto-generated command (advanced feature)
* Add slash command shortcuts to open various menus: `/cc profile`, `/cc blacklist`
* Add a debug output window: `/cc dump`

### Changed

* Improve and polish binding configuration UI
* Improve spellbook integration stability
* Disallow selecting of passive abilities in the spellbook
* Bug fixes and stability improvements

## [0.6.2] - 2020-09-19

### Changed

* Improve spellbook integration

### Removed

* Remove the escape button closing the binding configuration UI

### Fixed

* Fix a potential error that could occur when using Blizzard compact raid frames

## [0.6.1] - 2020-09-14

### Added

* Automatically remove the "blue cursor" when casting on a dead or invalid unit

## [0.6.0] - 2020-09-12

### Added

* Add the mouse cursor as a binding target (`[@cursor]`)
* Add support for copy/pasting binding data between each other
* Automatically navigate to the spellbook if the professions book is open
* Automatically disable bindings in vehicles, pet battles, and when you're possessed (whenever you have a different action bar)
* Add a load option for stances/forms
* Add support for combat flags for unit frame only bindings
* Add help tooltip texts to targeting mode dropdown items
* Add icons to the talent selected load option

### Changed

* Improve various texts
* Improve binding configuration UI performance

### Removed

* Remove the ability to designate targets _after_ the Player target in a binding as those would never be valid

### Fixed

* Fix ctrl/alt/shift + mouse button not working [#1]

## [0.5.1] - 2020-09-07

### Changed

* Merge the main development branch and the Shadowlands beta branch

## [0.5.0] - 2020-09-06

### Added

* Add support for click-cast bindings that don't use the primary mouse buttons
* Add a default target for new bindings
* Add a load option for group status (in group, in raid, not in group)
* Add a load option for a specific player in your group
* Add support for shift-clicking items to autofil them
* Add ElvUI styling to the binding configuration UI
* Add support for localization
* Add support for Classic Era 1.13.2

### Changed

* Show `<No one>` for a new target option instead of an empty string
* Don't display unloaded bindings at the bottom of the binding list
* Only show the `<Remove this target>` on secondary binding targets

### Removed

* Remove disabled button for item selection

### Fixed

* Fix an error when using custom macro bindings
* Fix mouse button 3, 4, and 5 not working
* Fix prioritization on global bindings
* Fix `/stopcasting` not always being applied correctly

## [0.4.1] - 2020-08-30

### Added

* Add support for hiding the minimap button in the UI options
* Add support for Blizzard compact raid frames

### Changed

* Hide spellbook when a spell was selected

### Fixed

* Fix keybinds not always being picked up when also configured on action bars
* Fix the `[@player]` section of a macro not always appearing as the last option
* Fix an error that occured if Clicked is the only enabled addon

## [0.4.0] - 2020-08-26

### Added

* Add support for custom target / menu buttons
* Add improved support for click-cast unit frames
* Add improved spellbook integration
* Add `/cc` as an alternative to `/clicked`

### Fixed

* Fix macro bindings not being activated
* Fix multiple bindings using the same keybinding not working
* Fix open menu not working on ElvUI unit frames
* Fix mouse button 3, 4, and 5 not working
* Fix action bar buttons staying highlighted after using the spellbook
* Fix various preventable errors occuring when Clique is enabled

## [0.3.0] - 2020-08-23

### Added

* Initial public release

[Unreleased]: https://github.com/Snakybo/Clicked/compare/1.16.2...master
[1.16.2]: https://github.com/Snakybo/Clicked/releases/tag/1.16.2
[1.16.1]: https://github.com/Snakybo/Clicked/releases/tag/1.16.1
[1.16.0]: https://github.com/Snakybo/Clicked/releases/tag/1.16.0
[1.15.6]: https://github.com/Snakybo/Clicked/releases/tag/1.15.6
[1.15.5]: https://github.com/Snakybo/Clicked/releases/tag/1.15.5
[1.15.4]: https://github.com/Snakybo/Clicked/releases/tag/1.15.4
[1.15.3]: https://github.com/Snakybo/Clicked/releases/tag/1.15.3
[1.15.2]: https://github.com/Snakybo/Clicked/releases/tag/1.15.2
[1.15.1]: https://github.com/Snakybo/Clicked/releases/tag/1.15.1
[1.15.0]: https://github.com/Snakybo/Clicked/releases/tag/1.15.0
[1.14.10]: https://github.com/Snakybo/Clicked/releases/tag/1.14.10
[1.14.9]: https://github.com/Snakybo/Clicked/releases/tag/1.14.9
[1.14.8]: https://github.com/Snakybo/Clicked/releases/tag/1.14.8
[1.14.7]: https://github.com/Snakybo/Clicked/releases/tag/1.14.7
[1.14.6]: https://github.com/Snakybo/Clicked/releases/tag/1.14.6
[1.14.5]: https://github.com/Snakybo/Clicked/releases/tag/1.14.5
[1.14.4]: https://github.com/Snakybo/Clicked/releases/tag/1.14.4
[1.14.3]: https://github.com/Snakybo/Clicked/releases/tag/1.14.3
[1.14.2]: https://github.com/Snakybo/Clicked/releases/tag/1.14.2
[1.14.1]: https://github.com/Snakybo/Clicked/releases/tag/1.14.1
[1.14.0]: https://github.com/Snakybo/Clicked/releases/tag/1.14.0
[1.13.5]: https://github.com/Snakybo/Clicked/releases/tag/1.13.5
[1.13.4]: https://github.com/Snakybo/Clicked/releases/tag/1.13.4
[1.13.3]: https://github.com/Snakybo/Clicked/releases/tag/1.13.3
[1.13.2]: https://github.com/Snakybo/Clicked/releases/tag/1.13.2
[1.13.1]: https://github.com/Snakybo/Clicked/releases/tag/1.13.1
[1.13.0]: https://github.com/Snakybo/Clicked/releases/tag/1.13.0
[1.12.2]: https://github.com/Snakybo/Clicked/releases/tag/1.12.2
[1.12.1]: https://github.com/Snakybo/Clicked/releases/tag/1.12.1
[1.12.0]: https://github.com/Snakybo/Clicked/releases/tag/1.12.0
[1.11.2]: https://github.com/Snakybo/Clicked/releases/tag/1.11.2
[1.11.1]: https://github.com/Snakybo/Clicked/releases/tag/1.11.1
[1.11.0]: https://github.com/Snakybo/Clicked/releases/tag/1.11.0
[1.10.6]: https://github.com/Snakybo/Clicked/releases/tag/1.10.6
[1.10.5]: https://github.com/Snakybo/Clicked/releases/tag/1.10.5
[1.10.4]: https://github.com/Snakybo/Clicked/releases/tag/1.10.4
[1.10.3]: https://github.com/Snakybo/Clicked/releases/tag/1.10.3
[1.10.2]: https://github.com/Snakybo/Clicked/releases/tag/1.10.2
[1.10.1]: https://github.com/Snakybo/Clicked/releases/tag/1.10.1
[1.10.0]: https://github.com/Snakybo/Clicked/releases/tag/1.10.0
[1.9.1]: https://github.com/Snakybo/Clicked/releases/tag/1.9.1
[1.9.0]: https://github.com/Snakybo/Clicked/releases/tag/1.9.0
[1.8.1]: https://github.com/Snakybo/Clicked/releases/tag/1.8.1
[1.8.0]: https://github.com/Snakybo/Clicked/releases/tag/1.8.0
[1.7.7]: https://github.com/Snakybo/Clicked/releases/tag/1.7.7
[1.7.6]: https://github.com/Snakybo/Clicked/releases/tag/1.7.6
[1.7.5]: https://github.com/Snakybo/Clicked/releases/tag/1.7.5
[1.7.4]: https://github.com/Snakybo/Clicked/releases/tag/1.7.4
[1.7.3]: https://github.com/Snakybo/Clicked/releases/tag/1.7.3
[1.7.2]: https://github.com/Snakybo/Clicked/releases/tag/1.7.2
[1.7.1]: https://github.com/Snakybo/Clicked/releases/tag/1.7.1
[1.7.0]: https://github.com/Snakybo/Clicked/releases/tag/1.7.0
[1.6.12]: https://github.com/Snakybo/Clicked/releases/tag/1.6.12
[1.6.11]: https://github.com/Snakybo/Clicked/releases/tag/1.6.11
[1.6.10]: https://github.com/Snakybo/Clicked/releases/tag/1.6.10
[1.6.9]: https://github.com/Snakybo/Clicked/releases/tag/1.6.9
[1.6.8]: https://github.com/Snakybo/Clicked/releases/tag/1.6.8
[1.6.7]: https://github.com/Snakybo/Clicked/releases/tag/1.6.7
[1.6.6]: https://github.com/Snakybo/Clicked/releases/tag/1.6.6
[1.6.5]: https://github.com/Snakybo/Clicked/releases/tag/1.6.5
[1.6.4]: https://github.com/Snakybo/Clicked/releases/tag/1.6.4
[1.6.3]: https://github.com/Snakybo/Clicked/releases/tag/1.6.3
[1.6.2]: https://github.com/Snakybo/Clicked/releases/tag/1.6.2
[1.6.1]: https://github.com/Snakybo/Clicked/releases/tag/1.6.1
[1.6.0]: https://github.com/Snakybo/Clicked/releases/tag/1.6.0
[1.5.3]: https://github.com/Snakybo/Clicked/releases/tag/1.5.3
[1.5.2]: https://github.com/Snakybo/Clicked/releases/tag/1.5.2
[1.5.1]: https://github.com/Snakybo/Clicked/releases/tag/1.5.1
[1.5.0]: https://github.com/Snakybo/Clicked/releases/tag/1.5.0
[1.4.1]: https://github.com/Snakybo/Clicked/releases/tag/1.4.1
[1.4.0]: https://github.com/Snakybo/Clicked/releases/tag/1.4.0
[1.3.2]: https://github.com/Snakybo/Clicked/releases/tag/1.3.2
[1.3.1]: https://github.com/Snakybo/Clicked/releases/tag/1.3.1
[1.3.0]: https://github.com/Snakybo/Clicked/releases/tag/1.3.0
[1.2.0]: https://github.com/Snakybo/Clicked/releases/tag/1.2.0
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

[#223]: https://github.com/Snakybo/Clicked/issues/223
[#217]: https://github.com/Snakybo/Clicked/issues/217
[#216]: https://github.com/Snakybo/Clicked/issues/216
[#212]: https://github.com/Snakybo/Clicked/issues/212
[#210]: https://github.com/Snakybo/Clicked/issues/210
[#204]: https://github.com/Snakybo/Clicked/issues/204
[#203]: https://github.com/Snakybo/Clicked/issues/203
[#201]: https://github.com/Snakybo/Clicked/issues/201
[#199]: https://github.com/Snakybo/Clicked/issues/199
[#193]: https://github.com/Snakybo/Clicked/issues/193
[#191]: https://github.com/Snakybo/Clicked/issues/191
[#189]: https://github.com/Snakybo/Clicked/issues/189
[#186]: https://github.com/Snakybo/Clicked/issues/186
[#184]: https://github.com/Snakybo/Clicked/issues/184
[#183]: https://github.com/Snakybo/Clicked/issues/183
[#182]: https://github.com/Snakybo/Clicked/issues/182
[#181]: https://github.com/Snakybo/Clicked/issues/181
[#179]: https://github.com/Snakybo/Clicked/issues/179
[#172]: https://github.com/Snakybo/Clicked/issues/172
[#170]: https://github.com/Snakybo/Clicked/pull/170
[#169]: https://github.com/Snakybo/Clicked/issues/169
[#166]: https://github.com/Snakybo/Clicked/issues/166
[#163]: https://github.com/Snakybo/Clicked/issues/163
[#160]: https://github.com/Snakybo/Clicked/issues/160
[#155]: https://github.com/Snakybo/Clicked/issues/155
[#146]: https://github.com/Snakybo/Clicked/issues/146
[#142]: https://github.com/Snakybo/Clicked/issues/142
[#141]: https://github.com/Snakybo/Clicked/issues/141
[#137]: https://github.com/Snakybo/Clicked/issues/137
[#136]: https://github.com/Snakybo/Clicked/issues/136
[#134]: https://github.com/Snakybo/Clicked/issues/134
[#133]: https://github.com/Snakybo/Clicked/issues/133
[#128]: https://github.com/Snakybo/Clicked/issues/128
[#127]: https://github.com/Snakybo/Clicked/issues/127
[#121]: https://github.com/Snakybo/Clicked/issues/121
[#120]: https://github.com/Snakybo/Clicked/issues/120
[#109]: https://github.com/Snakybo/Clicked/issues/109
[#108]: https://github.com/Snakybo/Clicked/issues/108
[#107]: https://github.com/Snakybo/Clicked/issues/107
[#105]: https://github.com/Snakybo/Clicked/issues/105
[#104]: https://github.com/Snakybo/Clicked/issues/104
[#102]: https://github.com/Snakybo/Clicked/issues/102
[#101]: https://github.com/Snakybo/Clicked/issues/101
[#100]: https://github.com/Snakybo/Clicked/issues/100
[#97]: https://github.com/Snakybo/Clicked/issues/97
[#91]: https://github.com/Snakybo/Clicked/issues/91
[#90]: https://github.com/Snakybo/Clicked/issues/90
[#84]: https://github.com/Snakybo/Clicked/issues/84
[#76]: https://github.com/Snakybo/Clicked/issues/76
[#75]: https://github.com/Snakybo/Clicked/issues/75
[#74]: https://github.com/Snakybo/Clicked/pull/74
[#71]: https://github.com/Snakybo/Clicked/issues/71
[#70]: https://github.com/Snakybo/Clicked/issues/70
[#69]: https://github.com/Snakybo/Clicked/pull/69
[#68]: https://github.com/Snakybo/Clicked/issues/68
[#64]: https://github.com/Snakybo/Clicked/issues/64
[#63]: https://github.com/Snakybo/Clicked/issues/63
[#59]: https://github.com/Snakybo/Clicked/issues/59
[#58]: https://github.com/Snakybo/Clicked/pull/58
[#57]: https://github.com/Snakybo/Clicked/issues/57
[#55]: https://github.com/Snakybo/Clicked/issues/55
[#54]: https://github.com/Snakybo/Clicked/issues/54
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

[Squishes]: https://github.com/Squishes
[h2oboi89]: https://github.com/h2oboi89
[hythloday]: https://github.com/hythloday
[gitarrg]: https://github.com/gitarrg
[tflo]: https://github.com/tflo
[yannlugrin]: https://github.com/yannlugrin
[novsirion]: https://github.com/novsirion
[nihilistzsche]: https://github.com/nihilistzsche
[Aeceon]: https://github.com/Aeceon
