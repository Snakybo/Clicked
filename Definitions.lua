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

--- @class Clicked : AceAddon, AceEvent-3.0
--- @field public VERSION string

--- @class DBSchema : AceDB.Schema
--- @field public profile DBSchema.Profile
--- @field public global DBSchema.Global

--- @class DBSchema.Profile
--- @field public version integer
--- @field public groups Group[]
--- @field public bindings Binding[]

--- @class DBSchema.Global
--- @field public version integer
--- @field public nextUid integer
--- @field public groups Group[]
--- @field public bindings Binding[]
--- @field public options DBSchema.Global.Options
--- @field public keyVisualizer DBSchema.Global.KeyVisualizer
--- @field public logLevel LibLog.LogLevel
--- @field public blacklist table<string,boolean>

--- @class DBSchema.Global.Options
--- @field public onKeyDown boolean
--- @field public tooltips boolean
--- @field public minimap LibDBIcon.button.DB
--- @field public bindUnassignedModifiers boolean
--- @field public autoBindActionBar boolean
--- @field public disableInHouse boolean

--- @class DBSchema.Global.KeyVisualizer
--- @field public lastKeyboardLayout? KeyboardLayout
--- @field public lastKeyboardSize? KeyboardSize
--- @field public showOnlyLoadedBindings boolean
--- @field public highlightEmptyKeys boolean

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
--- @field public load LoadConditionSet
--- @field public conditionals MacroConditionSet

--- @class Binding.Targets
--- @field public hovercast Binding.Target
--- @field public hovercastEnabled boolean
--- @field public regular Binding.Target[]
--- @field public regularEnabled boolean

--- @class Binding.Target
--- @field public unit? string
--- @field public flags TargetFlags

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
--- @field public spellIncludeSubtext boolean
--- @field public startAutoAttack boolean
--- @field public startPetAttack boolean
--- @field public cancelQueuedSpell boolean
--- @field public cancelForm boolean
--- @field public targetUnitAfterCast boolean
--- @field public preventToggle boolean

--- A load or macro condition. `value` contains either a single value, or a list of values. If `T` is a table type, `value` is always a list.
---
--- @class LoadCondition<T>
--- @field public state LoadConditionStates
--- @field public value T|T[]

--- @class TalentValue
--- @field public name string
--- @field public id? integer
--- @field public negate boolean

--- @class ZoneNameValue
--- @field public name string
--- @field public negate boolean

--- @class LoadConditionSet
--- @field public never? LoadCondition<boolean>
--- @field public class? LoadCondition<string>
--- @field public race? LoadCondition<string>
--- @field public nameRealm? LoadCondition<string>
--- @field public spellKnown? LoadCondition<string>
--- @field public groupType? LoadCondition<integer>
--- @field public playerInGroup? LoadCondition<string>
--- @field public instanceType? LoadCondition<integer>
--- @field public specialization? LoadCondition<integer>
--- @field public specRole? LoadCondition<integer>
--- @field public groupRole? LoadCondition<integer>
--- @field public zoneName? LoadCondition<ZoneNameValue>
--- @field public talent? LoadCondition<TalentValue[]>
--- @field public pvpTalent? LoadCondition<TalentValue[]>
--- @field public warMode? LoadCondition<boolean>
--- @field public ruleset? LoadCondition<integer>
--- @field public runeEquipped? LoadCondition<string>
--- @field public equipped? LoadCondition<string>

--- @class MacroConditionSet
--- @field public form? LoadCondition<integer>
--- @field public combat? LoadCondition<boolean>
--- @field public pet? LoadCondition<boolean>
--- @field public stealth? LoadCondition<boolean>
--- @field public mounted? LoadCondition<boolean>
--- @field public outdoors? LoadCondition<boolean>
--- @field public swimming? LoadCondition<boolean>
--- @field public channeling? LoadCondition<string>
--- @field public flying? LoadCondition<boolean>
--- @field public flyable? LoadCondition<boolean>
--- @field public dynamicFlying? LoadCondition<boolean>
--- @field public bonusbar? LoadCondition<string>
--- @field public bar? LoadCondition<string>

--- @class Group : DataObject
--- @field public name string
--- @field public displayIcon integer|string

--- @class Action
--- @field public ability integer|string
--- @field public type string
--- @field public conditionals table<string, LoadCondition>
--- @field public unit? string
--- @field public flags? TargetFlags

--- @class Command
--- @field public keybind string
--- @field public hovercast boolean
--- @field public action? string
--- @field public data? string|boolean
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

--- @class DataExport
--- @field public version integer
--- @field public bindings Binding[]
--- @field public groups Group[]
--- @field public options? DBSchema.Global.Options
--- @field public keyVisualizer? DBSchema.Global.KeyVisualizer
--- @field public logLevel? LibLog.LogLevel
--- @field public blacklist? table<string, boolean>
--- @field public isProfile? boolean
--- @correlated isProfile, options, keyVisualizer, logLevel, blacklist
