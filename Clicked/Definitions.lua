-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

--- @class Clicked : AceAddon
--- @field public VERSION string

--- @class ClickedInternal : AceEvent-3.0
--- @field L table<string,string>

--- @class Database : AceDB-3.0

--- @class Profile
--- @field public version integer
--- @field public options Profile.Options
--- @field public groups Group[]
--- @field public bindings Binding[]
--- @field public blacklist table<string,boolean>
--- @field public nextGroupId integer
--- @field public nextBindingId integer

--- @class Profile.Options
--- @field public onKeyDown boolean
--- @field public tooltips boolean
--- @field public minimap Profile.Options.Minimap

--- @class Profile.Options.Minimap
--- @field public hide boolean
--- @field public minimapPos number

--- @class Binding
--- @field public type string
--- @field public identifier integer
--- @field public keybind string
--- @field public parent string
--- @field public action Binding.Action
--- @field public targets Binding.Targets
--- @field public load Binding.Load
--- @field public integrations table<string,any>

--- @class Binding.Targets
--- @field public hovercast Binding.Target
--- @field public hovercastEnabled boolean
--- @field public regular Binding.Target[]
--- @field public regularEnabled boolean

--- @class Binding.Target
--- @field public unit string
--- @field public hostility string
--- @field public vitals string

--- @class Binding.Action
--- @field public spellValue string|integer
--- @field public itemValue string|integer
--- @field public macroValue string
--- @field public macroName string
--- @field public macroIcon string|integer
--- @field public auraName string|integer
--- @field public interrupt boolean
--- @field public executionOrder integer
--- @field public convertValueToId boolean
--- @field public startAutoAttack boolean
--- @field public startPetAttack boolean
--- @field public cancelQueuedSpell boolean
--- @field public targetUnitAfterCast boolean

--- @class Binding.Load
--- @field public never boolean
--- @field public class Binding.TriStateLoadOption
--- @field public race Binding.TriStateLoadOption
--- @field public playerNameRealm Binding.LoadOption
--- @field public combat Binding.LoadOption
--- @field public spellKnown Binding.LoadOption
--- @field public inGroup Binding.LoadOption
--- @field public playerInGroup Binding.LoadOption
--- @field public form Binding.TriStateLoadOption
--- @field public pet Binding.LoadOption
--- @field public stealth Binding.LoadOption
--- @field public mounted Binding.LoadOption
--- @field public outdoors Binding.LoadOption
--- @field public swimming Binding.LoadOption
--- @field public flying Binding.LoadOption
--- @field public flyable Binding.LoadOption
--- @field public instanceType Binding.TriStateLoadOption
--- @field public zoneName Binding.LoadOption
--- @field public equipped Binding.LoadOption
--- @field public specialization Binding.TriStateLoadOption
--- @field public talent Binding.TriStateLoadOption
--- @field public pvpTalent Binding.TriStateLoadOption
--- @field public warMode Binding.LoadOption
--- @field public channeling Binding.NegatableStringLoadOption

--- @class Binding.LoadOption
--- @field public selected boolean
--- @field public value string|boolean

--- @class Binding.TriStateLoadOption
--- @field public selected integer
--- @field public single number|string
--- @field public multiple number[]|string[]

--- @class Binding.NegatableTriStateLoadOption : Binding.TriStateLoadOption
--- @field public negated boolean

--- @class Binding.NegatableStringLoadOption
--- @field public selected boolean
--- @field public negated boolean
--- @field public value string

--- @class Group
--- @field public name string
--- @field public displayIcon integer|string
--- @field public identifier string

--- @class Action
--- @field public ability integer|string
--- @field public combat string
--- @field public pet string
--- @field public stealth string
--- @field public mounted string
--- @field public outdoors string
--- @field public flying string
--- @field public flyable string
--- @field public swimming string
--- @field public channeling Action.NegatableValueString
--- @field public forms Action.NegatableValueString
--- @field public unit string
--- @field public hostility string
--- @field public vitals string

--- @class Action.NegatableValueString
--- @field public negated boolean
--- @field public value string

--- @class Command
--- @field public keybind string
--- @field public hovercast boolean
--- @field public action string
--- @field public data any
--- @field public prefix string
--- @field public suffix string

--- @class Keybind
--- @field public key string
--- @field public identifier string
