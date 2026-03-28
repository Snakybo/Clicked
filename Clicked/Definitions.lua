-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
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

--- @meta

--- @class DBSchema : AceDB.Schema
--- @field public global DBSchema.Global
--- @field public profile DBSchema.Profile

--- @class DBSchema.Global
--- @field public options DBSchema.Global.Options
--- @field public keyVisualizer DBSchema.Global.KeyVisualizer
--- @field public blacklist string[]
--- @field public nextUid integer
--- @field public logLevel LibLog-1.0.LogLevel
--- @field public version string
--- @field public groups Group2[]
--- @field public keybinds Keybind2[]

--- @class DBSchema.Global.Options
--- @field public onKeyDown boolean
--- @field public minimap LibDBIcon.button.DB
--- @field public bindUnassignedModifiers boolean
--- @field public autoBindActionBar boolean
--- @field public disableInHouse boolean

--- @class DBSchema.Global.KeyVisualizer
--- @field public lastKeyboardLayout? KeyboardLayout
--- @field public lastKeyboardSize? KeyboardSize
--- @field public showOnlyLoadedBindings boolean
--- @field public highlightEmptyKeys boolean

--- @class DBSchema.Profile
--- @field public version string
--- @field public groups Group2[]
--- @field public keybinds Keybind2[]

--- @class Group2
--- @field public uid integer
--- @field public name string
--- @field public icon string

--- @class Keybind2
--- @field public uid integer
--- @field public priority integer
--- @field public parent? integer
--- @field public key string
--- @field public type ActionType2
--- @field public sets ActionSet[]

--- @enum ActionType2
Clicked2.ActionType2 = {
	GLOBAL = 0,
	CLICKCAST = 1
}

--- @class ActionSet
--- @field public type string
--- @field public actions Action2[]

--- @class Action2
--- @field public flags UnitFlags
--- @field public load LoadConditionSet
--- @field public target? string

--- @enum UnitFlags
Clicked2.UnitFlags = {
	ALIVE = 1,
	DEAD = 2,
	FRIEND = 4,
	HOSTILE = 8
}

--- @class LoadConditionSet
--- @field public never? LoadCondition
--- @field public class? LoadCondition
--- @field public race? LoadCondition
--- @field public playerNameRealm? LoadCondition
--- @field public combat? LoadCondition
--- @field public spellKnown? LoadCondition
--- @field public inGroup? LoadCondition
--- @field public playerInGroup? LoadCondition
--- @field public form? LoadCondition
--- @field public pet? LoadCondition
--- @field public stealth? LoadCondition
--- @field public mounted? LoadCondition
--- @field public outdoors? LoadCondition
--- @field public swimming? LoadCondition
--- @field public flying? LoadCondition
--- @field public dynamicFlying? LoadCondition
--- @field public flyable? LoadCondition
--- @field public advancedFlyable? LoadCondition
--- @field public instanceType? LoadCondition
--- @field public zoneName? LoadCondition
--- @field public equipped? LoadCondition
--- @field public specialization? LoadCondition
--- @field public specRole? LoadCondition
--- @field public talent? LoadCondition
--- @field public pvpTalent? LoadCondition
--- @field public warMode? LoadCondition
--- @field public channeling? LoadCondition
--- @field public bonusbar? LoadCondition
--- @field public bar? LoadCondition

--- @class LoadCondition
--- @field public state LoadConditionFlags
--- @field public single? unknown
--- @field public multiple? unknown[]

--- @enum LoadConditionFlags
Clicked2.LoadConditionFlags = {
	ENABLED = 1,
	NEGATED = 2,
	MULTI = 4
}


















--- @class Profile
--- @field public version integer
--- @field public options Profile.Options
--- @field public groups Group[]
--- @field public bindings Binding[]
--- @field public blacklist table<string,boolean>

--- @class DataObject
--- @field public uid integer
--- @field public type DataObjectType
--- @field public scope DataObjectScope

--- @class Binding : DataObject
--- @field public actionType ActionType
--- @field public keybind string
--- @field public parent integer?
--- @field public action Binding.Action
--- @field public targets Binding.Targets
--- @field public load Binding.Load

--- @class Binding.Targets
--- @field public hovercast Binding.Target
--- @field public hovercastEnabled boolean
--- @field public regular Binding.Target[]
--- @field public regularEnabled boolean

--- @class Binding.Target
--- @field public unit? string
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
--- @field public stopSpellTarget boolean
--- @field public executionOrder integer
--- @field public spellMaxRank boolean
--- @field public startAutoAttack boolean
--- @field public startPetAttack boolean
--- @field public cancelQueuedSpell boolean
--- @field public cancelForm boolean
--- @field public targetUnitAfterCast boolean
--- @field public preventToggle boolean

--- @class Binding.Load
--- @field public never boolean
--- @field public class Binding.TriStateLoadOption
--- @field public race Binding.TriStateLoadOption
--- @field public playerNameRealm Binding.LoadOption
--- @field public combat Binding.LoadOption
--- @field public spellKnown Binding.LoadOption
--- @field public inGroup Binding.LoadOption
--- @field public playerInGroup Binding.LoadOption
--- @field public form Binding.NegatableTriStateLoadOption
--- @field public pet Binding.LoadOption
--- @field public stealth Binding.LoadOption
--- @field public mounted Binding.LoadOption
--- @field public outdoors Binding.LoadOption
--- @field public swimming Binding.LoadOption
--- @field public flying Binding.LoadOption
--- @field public dynamicFlying Binding.LoadOption
--- @field public flyable Binding.LoadOption
--- @field public advancedFlyable Binding.LoadOption
--- @field public instanceType Binding.TriStateLoadOption
--- @field public zoneName Binding.LoadOption
--- @field public equipped Binding.LoadOption
--- @field public specialization Binding.TriStateLoadOption
--- @field public specRole Binding.TriStateLoadOption
--- @field public talent Binding.TriStateLoadOption|Binding.MutliFieldLoadOption
--- @field public pvpTalent Binding.MutliFieldLoadOption
--- @field public warMode Binding.LoadOption
--- @field public channeling Binding.NegatableStringLoadOption
--- @field public bonusbar Binding.NegatableStringLoadOption
--- @field public bar Binding.NegatableStringLoadOption

--- @class Binding.LoadOption
--- @field public selected boolean
--- @field public value string|boolean

--- @class Binding.TriStateLoadOption
--- @field public selected integer
--- @field public single number|string
--- @field public multiple number[]|string[]

--- @class Binding.NegatableTriStateLoadOption : Binding.TriStateLoadOption
--- @field public negated boolean

--- @class Binding.MutliFieldLoadOption
--- @field public selected boolean
--- @field public entries Binding.MutliFieldLoadOption.Entry[]

--- @class Binding.MutliFieldLoadOption.Entry
--- @field public operation "AND"|"OR"
--- @field public negated boolean
--- @field public value string

--- @class Binding.NegatableStringLoadOption
--- @field public selected boolean
--- @field public negated boolean
--- @field public value string

--- @class Group : DataObject
--- @field public name string
--- @field public displayIcon integer|string

--- @class Action
--- @field public ability integer|string
--- @field public type string
--- @field public combat? string
--- @field public pet? string
--- @field public stealth? string
--- @field public mounted? string
--- @field public outdoors? string
--- @field public flying? string
--- @field public dynamicFlying? string
--- @field public flyable? string
--- @field public advFlyable? string
--- @field public swimming? string
--- @field public channeling? Action.NegatableValueString
--- @field public forms? Action.NegatableValueString
--- @field public bonusbar? Action.NegatableValueString
--- @field public bar? Action.NegatableValueString
--- @field public unit? string
--- @field public hostility? string
--- @field public vitals? string

--- @class Action.NegatableValueString
--- @field public negated boolean
--- @field public value string

--- @class Command
--- @field public keybind string
--- @field public hovercast boolean
--- @field public action? string
--- @field public data? any
--- @field public prefix? string
--- @field public suffix? string

--- @class Keybind
--- @field public key string
--- @field public identifier string

--- @class BindingReloadCause
--- @field public full boolean
--- @field public events table<string,boolean>
--- @field public conditions table<string,boolean>

--- @class BindingReloadCauses : BindingReloadCause
--- @field public binding table<integer,BindingReloadCause>

--- @class TalentInfo
--- @field public spellId integer
--- @field public text string
--- @field public icon integer
--- @field public specId integer

--- @alias ShareType "group"|"binding

--- @class ShareData
--- @field public version integer
--- @field public type ShareType
--- @field public group ShareData.Group?
--- @field public binding Binding?

--- @class ShareData.Group : Group
--- @field public bindings Binding[]

--- @class ExportProfile : Profile
--- @field public lightweight boolean
--- @field public type "profile"
--- @field private options nil
--- @field private blacklist nil
