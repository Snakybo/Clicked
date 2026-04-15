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

--- @class AddonOptionsProvider
--- @field public GetAddonOptions fun(self: AddonOptionsProvider): table<string, AceConfig.OptionsTable>

--- @class SlashCommandHandler
--- @field public HandleSlashCommand fun(self: SlashCommandHandler, args: string[]): boolean

--- @class ClickedModule : AceModule, LibLog-1.0.Logger

--- @class DBSchema : AceDB.Schema
--- @field public global DBSchema.Global
--- @field public profile DBSchema.Profile

--- @class DBSchema.Global
--- @field public options DBSchema.Global.Options
--- @field public keyVisualizer DBSchema.Global.KeyVisualizer
--- @field public blacklist string[]
--- @field public nextUid integer
--- @field public logLevel LibLog-1.0.LogLevel
--- @field public version integer
--- @field public groups Group[]
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
--- @field public version integer
--- @field public groups Group[]
--- @field public keybinds Keybind2[]

--- @class Group
--- @field public uid integer
--- @field public name string
--- @field public icon string
--- @field public scope Scope runtime-only
--- @field public children Keybind2[] runtime-only

--- @class GroupUpdate
--- @field public name? string
--- @field public icon? string

--- @class Keybind2
--- @field public uid integer
--- @field public priority integer
--- @field public parent? integer
--- @field public scope Scope runtime-only
--- @field public key string
--- @field public type ActionType2
--- @field public sets ActionSet[]

--- @class KeybindUpdate
--- @field public key? string

--- @class ActionSet
--- @field public parent Keybind2 runtime-only
--- @field public uid integer
--- @field public type string
--- @field public actions Action2[]

--- @class Action2
--- @field public parent ActionSet runtime-only
--- @field public uid integer
--- @field public typeOverride? string
--- @field public flags UnitFlags
--- @field public load LoadConditionSet
--- @field public conditionals MacroConditionSet
--- @field public unit? string

--- @class ActionUpdate
--- @field public flags? UnitFlags
--- @field public load? LoadConditionSet
--- @field public conditionals? MacroConditionSet
--- @field public unit? string

--- @class LoadConditionSet
--- @field public never? LoadCondition
--- @field public class? LoadCondition
--- @field public race? LoadCondition
--- @field public playerNameRealm? LoadCondition
--- @field public combat? LoadCondition
--- @field public spellKnown? LoadCondition
--- @field public inGroup? LoadCondition
--- @field public playerInGroup? LoadCondition
--- @field public instanceType? LoadCondition
--- @field public specialization? LoadCondition
--- @field public specRole? LoadCondition
--- @field public talent? LoadCondition
--- @field public pvpTalent? LoadCondition
--- @field public warMode? LoadCondition

--- @class MacroConditionSet
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
--- @field public zoneName? LoadCondition
--- @field public equipped? LoadCondition
--- @field public channeling? LoadCondition
--- @field public bonusbar? LoadCondition
--- @field public bar? LoadCondition

--- @class LoadCondition
--- @field public state LoadConditionFlags
--- @field public single? unknown
--- @field public multiple? unknown

--- @class ActionHandler
--- @field public Create fun(action: Action2): Action2
--- @field public GetDatabaseDefaults? fun(): table

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
