-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
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

-- Deprecated in 11.0.0
local GetMouseFoci = GetMouseFoci or function() return { GetMouseFocus() } end

--- @class ClickedInternal
local Addon = select(2, ...)

--- @enum ActionType
Clicked.ActionType = {
	SPELL = "SPELL",
	ITEM = "ITEM",
	MACRO = "MACRO",
	APPEND = "APPEND",
	CANCELAURA = "CANCELAURA",
	UNIT_SELECT = "UNIT_SELECT",
	UNIT_MENU = "UNIT_MENU"
}

--- @enum CommandType
Addon.CommandType = {
	TARGET = "target",
	MENU = "menu",
	MACRO = "macro"
}

--- @enum TargetUnit
Addon.TargetUnit = {
	DEFAULT = "DEFAULT",
	PLAYER = "PLAYER",
	TARGET = "TARGET",
	TARGET_OF_TARGET = "TARGET_OF_TARGET",
	PET = "PET",
	PET_TARGET = "PET_TARGET",
	PARTY_1 = "PARTY_1",
	PARTY_2 = "PARTY_2",
	PARTY_3 = "PARTY_3",
	PARTY_4 = "PARTY_4",
	PARTY_5 = "PARTY_5",
	ARENA_1 = "ARENA_1",
	ARENA_2 = "ARENA_2",
	ARENA_3 = "ARENA_3",
	FOCUS = "FOCUS",
	MOUSEOVER = "MOUSEOVER",
	MOUSEOVER_TARGET = "MOUSEOVER_TARGET",
	CURSOR = "CURSOR"
}

--- @enum TargetHostility
Addon.TargetHostility = {
	ANY = "ANY",
	HELP = "HELP",
	HARM = "HARM"
}

--- @enum TargetVitals
Addon.TargetVitals = {
	ANY = "ANY",
	ALIVE = "ALIVE",
	DEAD = "DEAD"
}

--- @enum GroupState
Addon.GroupState = {
	PARTY_OR_RAID = "IN_GROUP_PARTY_OR_RAID",
	PARTY = "IN_GROUP_PARTY",
	RAID = "IN_GROUP_RAID",
	SOLO = "IN_GROUP_SOLO"
}

--- @enum InteractionType
Addon.InteractionType = {
	REGULAR = 1,
	HOVERCAST = 2
}

--- @type Binding[]
local activeBindings = {}

--- @type table<string,table<string,boolean>>
local bindingStateCache = {}

--- @type table<string,Binding[]>
local hovercastBucket = {}

--- @type table<string,Binding[]>
local regularBucket = {}

--- @type BindingReloadCauses
local pendingReloadCauses = {} --- @diagnostic disable-line: missing-fields

--- @type table<string,boolean>
local talentCache = {}

--- @type table<string,boolean>
local macroTooLongNotified = {}

local reloadBindingsDelayTicker = nil
local reloadTalentCacheDelayTicker = nil

--- @type string[]?
local reloadTalentCacheEvents = nil

-- Local support functions

--- @param action Action
--- @param interactionType number
--- @param isLast boolean
--- @return string
local function GetMacroSegmentFromAction(action, interactionType, isLast)
	local flags = {}
	local unit, needsExistsCheck = Addon:GetWoWUnitFromUnit(action.unit, true)

	--- @param condition boolean|string
	--- @param value string
	--- @param negated? string
	--- @param isUnit? boolean
	local function ParseNegatableBooleanCondition(condition, value, negated, isUnit)
		if condition == true then
			table.insert(flags, value)

			if isUnit then
				needsExistsCheck = false
			end
		elseif condition == false then
			negated = negated or ("no" .. value)
			table.insert(flags, negated)
		end
	end

	--- @param condition Action.NegatableValueString
	--- @param value string
	--- @param negated string
	local function ParseNegatableStringCondition(condition, value, negated)
		if condition ~= nil then
			local key = condition.negated and negated or value
			local macro = key

			if not Addon:IsNilOrEmpty(condition.value) then
				macro = macro .. ":" .. condition.value
			end

			table.insert(flags, macro)
		end
	end

	if unit ~= nil then
		table.insert(flags, unit)
	end

	if Addon:CanUnitBeHostile(action.unit) then
		if action.hostility == Addon.TargetHostility.HELP then
			table.insert(flags, "help")
			needsExistsCheck = false
		elseif action.hostility == Addon.TargetHostility.HARM then
			table.insert(flags, "harm")
			needsExistsCheck = false
		end
	end

	-- The overriding of the `needsExistsCheck` boolean only happens on the non-negated version of macro flags: `dead`, `pet`, etc. and NOT on the `nodead`,
	-- `nopet` version. Apperantly the `exists` check is implied for the standard variants but not for the negated variants.

	if Addon:CanUnitBeDead(action.unit) then
		if action.vitals == Addon.TargetVitals.ALIVE then
			table.insert(flags, "nodead")
		elseif action.vitals == Addon.TargetVitals.DEAD then
			table.insert(flags, "dead")
			needsExistsCheck = false
		end
	end

	ParseNegatableBooleanCondition(action.pet, "pet", "nopet", true)
	ParseNegatableBooleanCondition(action.combat, "combat")
	ParseNegatableBooleanCondition(action.stealth, "stealth")
	ParseNegatableBooleanCondition(action.mounted, "mounted")
	ParseNegatableBooleanCondition(action.outdoors, "outdoors", "indoors")
	ParseNegatableBooleanCondition(action.swimming, "swimming")
	ParseNegatableBooleanCondition(action.flying, "flying")
	ParseNegatableBooleanCondition(action.dynamicFlying, "bonusbar:5")
	ParseNegatableBooleanCondition(action.flyable, "flyable")
	ParseNegatableBooleanCondition(action.advFlyable, "advflyable")
	ParseNegatableStringCondition(action.channeling, "channeling", "nochanneling")
	ParseNegatableStringCondition(action.bonusbar, "bonusbar", "nobonusbar")
	ParseNegatableStringCondition(action.bar, "bar", "nobar")

	if interactionType == Addon.InteractionType.REGULAR and not isLast and needsExistsCheck then
		table.insert(flags, "exists")
	end

	if #action.forms.value > 0 then
		ParseNegatableStringCondition(action.forms, "form", "noform")
	end

	return table.concat(flags, ",")
end

--- @param binding Binding
--- @param target Binding.Target
--- @return Action
local function ConstructAction(binding, target)
	--- @type Action
	local action = {
		ability = Addon:GetBindingValue(binding) --[[@as string|integer]],
		type = binding.actionType
	}

	--- @param condition Binding.LoadOption
	--- @param key string
	local function AppendCondition(condition, key)
		if condition.selected then
			action[key] = condition.value
		end
	end

	--- @param condition Binding.NegatableStringLoadOption
	--- @param key string
	--- @param ignoreEmptyValue? boolean
	local function AppendNegatableStringCondition(condition, key, ignoreEmptyValue)
		if condition.selected and (not ignoreEmptyValue or not Addon:IsNilOrEmpty(condition.value)) then
			action[key] = {
				negated = condition.negated,
				value = condition.value
			}
		end
	end

	AppendCondition(binding.load.combat, "combat")
	AppendCondition(binding.load.pet, "pet")
	AppendCondition(binding.load.stealth, "stealth")
	AppendCondition(binding.load.mounted, "mounted")
	AppendCondition(binding.load.outdoors, "outdoors")
	AppendCondition(binding.load.swimming, "swimming")
	AppendNegatableStringCondition(binding.load.channeling, "channeling")
	AppendNegatableStringCondition(binding.load.bar, "bar", true)

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.BC then
		AppendCondition(binding.load.flying, "flying")
		AppendCondition(binding.load.flyable, "flyable")
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
		AppendNegatableStringCondition(binding.load.bonusbar, "bonusbar")
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		AppendCondition(binding.load.advancedFlyable, "advflyable")
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.TWW then
		AppendCondition(binding.load.dynamicFlying, "dynamicFlying")
	end

	do
		local forms = Addon:GetAvailableShapeshiftForms(binding)

		action.forms = {
			negated = binding.load.form.negated,
			value = table.concat(forms, "/")
		}
	end

	if Addon:IsRestrictedKeybind(binding.keybind) or target.unit == nil then
		action.unit = Addon.TargetUnit.MOUSEOVER
	else
		action.unit = target.unit
	end

	if target.hostility ~= Addon.TargetHostility.ANY then
		action.hostility = target.hostility
	else
		action.hostility = ""
	end

	if target.vitals ~= Addon.TargetVitals.ANY then
		action.vitals = target.vitals
	else
		action.vitals = ""
	end

	return action
end

--- @param binding Binding
--- @param interactionType number
--- @return Action[]
local function ConstructActions(binding, interactionType)
	--- @type Action[]
	local actions = {}

	if Addon:IsHovercastEnabled(binding) and interactionType == Addon.InteractionType.HOVERCAST then
		local action = ConstructAction(binding, binding.targets.hovercast)
		table.insert(actions, action)
	end

	if Addon:IsMacroCastEnabled(binding) and interactionType == Addon.InteractionType.REGULAR then
		for _, target in ipairs(binding.targets.regular) do
			local action = ConstructAction(binding, target)
			table.insert(actions, action)
		end
	end

	return actions
end

--- @param actions Action[]
--- @param indexMap table<Action,integer>
local function SortActions(actions, indexMap)
	---@param left Action
	---@param right Action
	---@return boolean
	local function SortFunc(left, right)
		local priority = {
			-- 1. Mouseover targets always come first
			{ left = left.unit, right = right.unit, value = Addon.TargetUnit.MOUSEOVER, comparison = "eq" },
			{ left = left.unit, right = right.unit, value = Addon.TargetUnit.MOUSEOVER_TARGET, comparison = "eq"},

			-- 2. Macro conditions take presedence over actions that don't specify them explicitly
			{ left = left.hostility, right = right.hostility, value = 0, comparison = "gt" },
			{ left = left.vitals, right = right.vitals, value = 0, comparison = "gt" },
			{ left = left.combat, right = right.combat, value = true, comparison = "eq" },
			{ left = left.forms, right = right.forms, value = 0, comparison = "gt" },
			{ left = left.pet, right = right.pet, value = true, comparison = "eq" },
			{ left = left.stealth, right = right.stealth, value = true, comparison = "eq" },
			{ left = left.mounted, right = right.mounted, value = true, comparison = "eq" },
			{ left = left.outdoors, right = right.outdoors, value = true, comparison = "eq" },
			{ left = left.swimming, right = right.swimming, value = true, comparison = "eq" },
			{ left = left.flying, right = right.flying, value = true, comparison = "eq" },
			{ left = left.dynamicFlying, right = right.dynamicFlying, value = true, comparison = "eq" },
			{ left = left.flyable, right = right.flyable, value = true, comparison = "eq" },
			{ left = left.advFlyable, right = right.advFlyable, value = true, comparison = "eq" },
			{ left = left.bonusbar, right = right.bonusbar, value = true, comparison = "eq" },
			{ left = left.bar, right = right.bar, value = true, comparison = "eq" },

			-- 3. Any actions that do not meet any of the criteria in this list will be placed here

			-- 4. The player, cursor, and default targets will always come last
			{ left = left.unit, right = right.unit, value = Addon.TargetUnit.PLAYER, comparison = "neq" },
			{ left = left.unit, right = right.unit, value = Addon.TargetUnit.CURSOR, comparison = "neq" },
			{ left = left.unit, right = right.unit, value = Addon.TargetUnit.DEFAULT, comparison = "neq" }
		}

		for _, item in ipairs(priority) do
			--- @type string|integer
			local l = item.left

			--- @type string|integer
			local r = item.right
			local v = item.value
			local c = item.comparison

			if c == "neq" then
				c = "eq"

				local t = l
				l = r
				r = t
			end

			if c == "eq" then
				if l == v and r ~= v then
					return true
				end

				if l ~= v and r == v then
					return false
				end
			elseif c == "gt" then
				l = l and #l or 0
				r = r and #r or 0

				if l > v and r == v then
					return true
				end

				if l == v and r > v then
					return false
				end
			end
		end

		return indexMap[left] < indexMap[right]
	end

	table.sort(actions, SortFunc)
end

local function ProcessBuckets()
	--- @param keybind string
	--- @param bindings Binding[]
	--- @param interactionType number
	--- @return Command?
	local function Process(keybind, bindings, interactionType)
		if #bindings == 0 then
			return nil
		end

		local reference = bindings[1]

		--- @type Command
		local command = {
			keybind = keybind,
			hovercast = interactionType == Addon.InteractionType.HOVERCAST
		}

		command.prefix, command.suffix = Addon:CreateAttributeIdentifier(command.keybind, command.hovercast)

		if Addon:GetInternalBindingType(reference) == Clicked.ActionType.MACRO then
			command.action = Addon.CommandType.MACRO
			command.data = Addon:GetMacroForBindings(bindings, interactionType)

			if strlenutf8(command.data) > 255 and not macroTooLongNotified[command.data] then
				macroTooLongNotified[command.data] = true

				local message = Addon.L["The generated macro for binding '%s' is too long and will not function, please adjust your bindings."]
				local name = Addon:GetBindingNameAndIcon(reference)

				print(Addon:GetPrefixedAndFormattedString(message, name))
			end
		elseif reference.actionType == Clicked.ActionType.UNIT_SELECT then
			command.action = Addon.CommandType.TARGET

			if reference.load.combat.selected then
				command.data = reference.load.combat.value
			end
		elseif reference.actionType == Clicked.ActionType.UNIT_MENU then
			command.action = Addon.CommandType.MENU

			if reference.load.combat.selected then
				command.data = reference.load.combat.value
			end
		else
			error("Unhandled binding type: " .. reference.actionType)
		end

		return command
	end

	--- @type Command[]
	local commands = {}

	for keybind, bindings in pairs(hovercastBucket) do
		local command = Process(keybind, bindings, Addon.InteractionType.HOVERCAST)

		if command ~= nil then
			table.insert(commands, command)
		end
	end

	for keybind, bindings in pairs(regularBucket) do
		local command = Process(keybind, bindings, Addon.InteractionType.REGULAR)

		if command ~= nil then
			table.insert(commands, command)
		end
	end

	Addon:StatusOutput_HandleCommandsGenerated(commands)
	Addon:ProcessCommands(commands)
end

--- @param bindings Binding[]
local function GenerateBuckets(bindings)
	--- @param bucket table<string,Binding>
	--- @param binding Binding
	local function Insert(bucket, binding)
		if #bucket == 0 then
			table.insert(bucket, binding)
		else
			local reference = bucket[1]

			if Addon:GetInternalBindingType(binding) == Addon:GetInternalBindingType(reference) then
				table.insert(bucket, binding)
			end
		end
	end

	wipe(hovercastBucket)
	wipe(regularBucket)

	for _, binding in ipairs(bindings) do
		--- @type string[]
		local keys = { binding.keybind }

		if Addon.db.profile.options.bindUnassignedModifiers and Addon:IsUnmodifiedKeybind(keys[1]) then
			local withModifiers = Addon:GetUnusedModifierKeyKeybinds(keys[1], bindings)

			for i = 1, #withModifiers do
				table.insert(keys, withModifiers[i])
			end
		end

		if Addon:IsHovercastEnabled(binding) then
			for _, key in ipairs(keys) do
				hovercastBucket[key] = hovercastBucket[key] or {}
				Insert(hovercastBucket[key], binding)
			end
		end

		if Addon:IsMacroCastEnabled(binding) then
			for _, key in ipairs(keys) do
				regularBucket[key] = regularBucket[key] or {}
				Insert(regularBucket[key], binding)
			end
		end
	end

	table.sort(hovercastBucket, function(a, b) return a.uid < b.uid end)
	table.sort(regularBucket, function(a, b) return a.uid < b.uid end)
end

--- @param str string
--- @return string
local function StripColorCodes(str)
	str = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
	str = string.gsub(str, "|c%x%x %x%x%x%x%x", "") -- the trading parts colour has a space instead of a zero for some weird reason
	str = string.gsub(str, "|r", "")

	return str
end

--- @param bindings Binding[]
--- @param full boolean
--- @param events string[]
--- @param conditions string[]
local function ProcessReloadArguments(bindings, full, events, conditions)
	pendingReloadCauses.events = pendingReloadCauses.events or {}
	pendingReloadCauses.binding = pendingReloadCauses.binding or {}
	pendingReloadCauses.conditions = pendingReloadCauses.conditions or {}

	if #bindings == 0 then
		if full then
			pendingReloadCauses.full = true
		end

		for _, item in ipairs(events) do
			pendingReloadCauses.events[item] = true
		end

		for _, item in ipairs(conditions) do
			pendingReloadCauses.conditions[item] = true
		end
	else
		for _, binding in ipairs(bindings) do
			local uid = binding.uid

			pendingReloadCauses.binding[uid] = pendingReloadCauses.binding[uid] or {}
			pendingReloadCauses.binding[uid].events = pendingReloadCauses.binding[uid].events or {}
			pendingReloadCauses.binding[uid].conditions = pendingReloadCauses.binding[uid].conditions or {}

			if full then
				pendingReloadCauses.binding[uid].full = true
			end

			for _, item in ipairs(events) do
				pendingReloadCauses.binding[uid].events[item] = true
			end

			for _, item in ipairs(conditions) do
				pendingReloadCauses.binding[uid].conditions[item] = true
			end
		end
	end
end

local function ReloadBindings()
	if reloadBindingsDelayTicker ~= nil or InCombatLockdown() then
		return
	end

	local function DoReloadBindings()
		reloadBindingsDelayTicker = nil

		-- The pendingReloadCauses can contains three "targets":
		--  1. a specific binding, using the `binding` property
		--  2. all bindings, using the '*' property
		--  3. a subset of bindings that are affected by an event using the `events` property (i.e. PLAYER_REGEN_DISABLED)

		wipe(activeBindings)

		for _, binding in Clicked:IterateConfiguredBindings() do
			Addon:UpdateBindingLoadState(binding, pendingReloadCauses)

			if Clicked:CanBindingLoad(binding) then
				table.insert(activeBindings, binding)
			end
		end

		wipe(pendingReloadCauses)

		Clicked:ProcessActiveBindings()

		Addon.BindingConfig.Window:OnBindingReload()
		Addon.KeyVisualizer:Redraw()
	end

	reloadBindingsDelayTicker = C_Timer.NewTimer(0, DoReloadBindings)
end

-- Public addon API

--- Reload the given binding(s). If omited, all bindings will be fully refreshed.
---
--- Bindings are always bulk-reloaded once per frame, this function will queue a reload for the next frame.
---
--- @param bindings? Binding|Binding[]
function Clicked:ReloadBindings(bindings)
	if bindings == nil then
		bindings = {}
	elseif bindings[1] == nil then
		bindings = { bindings }
	end

	ProcessReloadArguments(bindings, true, {}, {})
	ReloadBindings()

	Addon:UpdateLookupTable()
end

function Clicked:ProcessActiveBindings()
	if InCombatLockdown() then
		return
	end

	GenerateBuckets(activeBindings)
	ProcessBuckets()
end

--- Evaluate the generated macro for a binding and return the target unit if there is any.
---
--- @param binding Binding The input binding, cannot be `nil` and must be a valid binding table
--- @return string? hovercastTarget The first satisfied hovercast unit if any, `nil` otherwise. If this has a value it will always be `@mouseover`.
--- @return string? regularTarget The first satisfied regular unit if any, `nil` otherwise.
function Clicked:EvaluateBindingMacro(binding)
	assert(type(binding) == "table", "bad argument #1, expected table but got " .. type(binding))

	--- @type Binding[]
	local bindings = { binding }

	--- @type string?
	local hovercastTarget = nil

	--- @type string?
	local regularTarget = nil

	if Addon:IsHovercastEnabled(binding) then
		local _, hovercast = Addon:GetMacroForBindings(bindings, Addon.InteractionType.HOVERCAST)
		_, hovercastTarget = SecureCmdOptionParse(hovercast)
	end

	if Addon:IsMacroCastEnabled(binding) then
		local _, regular = Addon:GetMacroForBindings(bindings, Addon.InteractionType.REGULAR)
		_, regularTarget = SecureCmdOptionParse(regular)
	end

	return hovercastTarget, regularTarget
end

--- Iterate through all currently active bindings, this function can be used in a `for in` loop.
function Clicked:IterateActiveBindings()
	return ipairs(activeBindings)
end

--- Get all bindings that, when activated at this moment, will affect the specified unit. This builds a full profile and the resulting table contains all
--- bindings that meet the criteria.
---
--- This function additionally checks for _similar_ units, for example, if the input unit is `focus` but the `focus` unit is also the `target` unit, it will
--- also include any bindings aimed at the `target` unit.
---
--- For each binding it also validates that the specified load and target conditions have been met. A binding that is only active in certain shapeshift forms
--- will not be included if the player is not currently in that shapeshift form.
---
--- For target `friend`/`harm` and `dead`/`nodead` modifiers, a similar check is performed.
---
--- @param unit string
--- @return Binding[]
function Clicked:GetBindingsForUnit(unit)
	assert(type(unit) == "string", "bad argument #1, expected table but got " .. type(unit))

	--- @type Binding[]
	local result = {}

	--- @type table<string,boolean>
	local units = {
		[unit] = true
	}

	-- find other unit types that is valid for this target
	for k in pairs(Addon.TargetUnit) do
		local u = Addon:GetWoWUnitFromUnit(k)

		if u ~= nil and u ~= unit and UnitGUID(u) == UnitGUID(unit) then
			units[u] = true
		end
	end

	--- @param target Binding.Target
	--- @return boolean
	local function IsTargetValid(target)
		if target.hostility == Addon.TargetHostility.HELP and not UnitIsFriend("player", unit) or
		   target.hostility == Addon.TargetHostility.HARM and UnitIsFriend("player", unit) then
			return false
		end

		if target.vitals == Addon.TargetVitals.DEAD and not UnitIsDeadOrGhost(unit) or
		   target.vitals == Addon.TargetVitals.ALIVE and UnitIsDeadOrGhost(unit) then
			return false
		end

		return true
	end

	--- @param binding Binding
	--- @return boolean
	local function IsBindingValidForUnit(binding)
		if binding.actionType ~= Clicked.ActionType.SPELL and binding.actionType ~= Clicked.ActionType.ITEM then
			return false
		end

		if not Addon:IsBindingValidForCurrentState(binding) then
			return false
		end

		-- hovercast
		do
			local hovercast = binding.targets.hovercast
			local enabled = Addon:IsHovercastEnabled(binding)

			if enabled and IsTargetValid(hovercast) then
				local focus = GetMouseFoci()

				for i = 1, #focus do
					if focus[i] == WorldFrame then
						return false
					end
				end

				return true
			end
		end

		-- regular
		do
			local enabled = Addon:IsMacroCastEnabled(binding)

			if enabled then
				local _, target = Clicked:EvaluateBindingMacro(binding)

				if target ~= nil and units[target] then
					return true
				end
			end
		end

		return false
	end

	for _, binding in Clicked:IterateActiveBindings() do
		if IsBindingValidForUnit(binding) then
			table.insert(result, binding)
		end
	end

	return result
end

--- @param binding Binding
--- @return boolean
function Clicked:CanBindingLoad(binding)
	local state = bindingStateCache[binding.uid]

	if state == nil then
		return false
	end

	for _, value in pairs(state) do
		if not value then
			return false
		end
	end

	return true
end

--- @param binding Binding
--- @return boolean
function Clicked:IsBindingLoaded(binding)
	for _, active in ipairs(activeBindings) do
		if active.uid == binding.uid then
			return true
		end
	end

	return false
end

-- Private addon API

--- Reload all bindings, optionally only refresh conditions that depend on the specified events. If no events are given, all bindings will be fully refreshed.
---
--- Bindings are always bulk-reloaded once per frame, this function will queue a reload for the next frame.
---
--- @param ... string
function Addon:ReloadBindings(...)
	local events = { ... }

	ProcessReloadArguments({}, #events == 0, events, {})
	ReloadBindings()

	Addon:UpdateLookupTable()
end

--- Reload a binding, if `condition` is a string, only the specified condition will be refreshed, if it is `true`, the entire state will be refreshed.---
---
--- Bindings are always bulk-reloaded once per frame, this function will queue a reload for the next frame.
---
--- @param binding Binding
--- @param condition? string
--- @overload fun(self:Clicked, binding:Binding, full:boolean)
function Addon:ReloadBinding(binding, condition)
	local conditions = {}
	local full = false

	if type(condition) == "boolean" then
		full = condition
	elseif type(condition) == "string" then
		conditions[1] = condition
	end

	ProcessReloadArguments({ binding }, full, {}, conditions)
	ReloadBindings()

	Addon:UpdateLookupTable(binding)
end

--- @param ... string
function Addon:UpdateTalentCacheAndReloadBindings(...)
	local function DoUpdateTalentCache()
		reloadTalentCacheDelayTicker = nil

		if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
			wipe(talentCache)

			local configId = C_ClassTalents.GetActiveConfigID()
			if configId == nil then
				Addon:UpdateTalentCacheAndReloadBindings()
				return
			end

			local configInfo = C_Traits.GetConfigInfo(configId)
			if configInfo == nil then
				Addon:UpdateTalentCacheAndReloadBindings()
				return
			end

			local treeId = configInfo.treeIDs[1]
			local nodes = C_Traits.GetTreeNodes(treeId)

			for _, nodeId in ipairs(nodes) do
				local nodeInfo = C_Traits.GetNodeInfo(configId, nodeId)

				if nodeInfo.ID ~= 0 then
					-- check if the node was manually selected by the player, the easy way
					local isValid = nodeInfo.currentRank > 0

					-- check if the node was granted to the player automatically
					if not isValid then
						for _, conditionId in ipairs(nodeInfo.conditionIDs) do
							local conditionInfo = C_Traits.GetConditionInfo(configId, conditionId)

							if conditionInfo.isMet and conditionInfo.ranksGranted ~= nil and conditionInfo.ranksGranted > 0 then
								isValid = true
								break
							end
						end
					end

					if isValid then
						local entryId = nodeInfo.activeEntry ~= nil and nodeInfo.activeEntry.entryID or 0
						local entryInfo = entryId ~= nil and C_Traits.GetEntryInfo(configId, entryId) or nil
						local definitionInfo = entryInfo ~= nil and entryInfo.definitionID ~= nil and C_Traits.GetDefinitionInfo(entryInfo.definitionID) or nil

						if definitionInfo ~= nil then
							local name = StripColorCodes(TalentUtil.GetTalentNameFromInfo(definitionInfo))
							talentCache[name] = true
						end
					end
				end
			end
		elseif Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
			wipe(talentCache)

			for tab = 1, GetNumTalentTabs() do
				for index = 1, GetNumTalents(tab) do
					local name, _, _, _, rank  = GetTalentInfo(tab, index)

					if name ~= nil then
						talentCache[name] = rank > 0
					end
				end
			end
		end

		if reloadTalentCacheEvents ~= nil then
			Addon:ReloadBindings(unpack(reloadTalentCacheEvents))
			reloadTalentCacheEvents = nil
		else
			Addon:ReloadBindings()
		end
	end

	local args = { ... }

	if reloadTalentCacheDelayTicker == nil then
		if #args > 0 then
			reloadTalentCacheEvents = args
		end

		reloadTalentCacheDelayTicker = C_Timer.NewTimer(0, function()
			DoUpdateTalentCache()
		end)
	else
		if #args == 0 then
			reloadTalentCacheEvents = nil
		elseif reloadTalentCacheEvents ~= nil then
			for _, event in ipairs(args) do
				if not tContains(reloadTalentCacheEvents, event) then
					table.insert(reloadTalentCacheEvents, event)
				end
			end
		end
	end
end

--- Check if the specified binding is currently active based on the configuration
--- provided in the binding's Load Options, and whether the binding is actually
--- valid (it has a keybind and an action to perform)
---
--- @param binding Binding
--- @param causes BindingReloadCauses
function Addon:UpdateBindingLoadState(binding, causes)
	--- @param condition string
	--- @param events? string[]
	--- @return boolean
	local function ShouldPerformStateCheck(condition, events)
		-- All bindings should be updated
		if causes.full then
			return true
		end

		events = events or {}

		-- A specific binding should be updated
		local current = causes.binding[binding.uid]
		if current ~= nil then
			if current.full then
				return true
			end

			-- A specific event should be updated
			for _, cause in pairs(events) do
				if current.events[cause] then
					return true
				end
			end

			-- A specific condition should be updated
			if condition ~= nil and current.conditions[condition] then
				return true
			end
		end

		-- A specific event should be updated
		for _, cause in ipairs(events) do
			if causes.events[cause] then
				return true
			end
		end

		if condition ~= nil and causes.conditions[condition] then
			return true
		end

		return false
	end

	local state = bindingStateCache[binding.uid] or {}
	local conditions = Addon.Condition.Registry:GetConditionSet("load")

	if ShouldPerformStateCheck("keybind") then
		state.keybind = not Addon:IsNilOrEmpty(binding.keybind)
	end

	if ShouldPerformStateCheck("targets") then
		state.targets = Addon:IsHovercastEnabled(binding) or Addon:IsMacroCastEnabled(binding)
	end

	if ShouldPerformStateCheck("value") then
		state.value = not Addon:IsNilOrEmpty(Addon:GetBindingValue(binding))
	end

	for _, condition in ipairs(conditions.config) do
		--- @cast condition LoadCondition

		if ShouldPerformStateCheck(condition.id, condition.testOnEvents) then
			local load = binding.load[condition.id] or condition.init()
			local selected = condition.unpack(load)

			if selected ~= nil then
				local _, result = Addon:SafeCall(condition.test, selected)
				state[condition.id] = result
			else
				state[condition.id] = true
			end
		end
	end

	-- Remove true values from the data
	for key, value in pairs(state) do
		if value then
			state[key] = nil
		end
	end

	if bindingStateCache[binding.uid] == nil then
		bindingStateCache[binding.uid] = state
	end
end

--- Check if a binding is valid for the current state of the player, this will
--- check load conditions that aren't validated in `CanBindingLoad` as the state
--- of these attributes can change during combat.
---
--- @param binding Binding
--- @return boolean
function Addon:IsBindingValidForCurrentState(binding)
	local load = binding.load

	-- known
	do
		local name, _, id = Addon:GetSimpleSpellOrItemInfo(binding)

		if name == nil or id == nil then
			return false
		end

		if binding.actionType == Clicked.ActionType.SPELL and not IsSpellKnown(id) then
			return false
		end
	end

	-- cobmat
	do
		local combat = load.combat

		if combat.selected then
			if combat.value == true and not Addon:IsPlayerInCombat() or
			   combat.value == false and Addon:IsPlayerInCombat() then
				return false
			end
		end
	end

	-- form
	do
		local forms = Addon:GetAvailableShapeshiftForms(binding)
		local active = GetShapeshiftForm()
		local valid = false

		if #forms > 0 then
			for _, formId in ipairs(forms) do
				if formId == active then
					valid = true
					break
				end
			end

			if not valid then
				return false
			end
		end
	end

	-- pet
	do
		local pet = load.pet

		if pet.selected then
			if pet.value == true and not UnitIsVisible("pet") or
			   pet.value == false and UnitIsVisible("pet") then
				return false
			end
		end
	end

	return true
end

--- @param binding Binding
--- @return string
function Addon:GetInternalBindingType(binding)
	if binding.actionType == Clicked.ActionType.SPELL then
		return Clicked.ActionType.MACRO
	end

	if binding.actionType == Clicked.ActionType.ITEM then
		return Clicked.ActionType.MACRO
	end

	if binding.actionType == Clicked.ActionType.APPEND then
		return Clicked.ActionType.MACRO
	end

	if binding.actionType == Clicked.ActionType.CANCELAURA then
		return Clicked.ActionType.MACRO
	end

	return binding.actionType
end

--- Construct a valid macro that correctly prioritizes all specified bindings.
--- It will prioritize bindings in the following order:
---
--- 1. All custom macros
--- 2. All @mouseover bindings with the help or harm tag and a combat/nocombat flag
--- 3. All remaining @mouseover bindings with a combat/nocombat flag
--- 4. Any remaining bindings with the help or harm tag and a combat/nocombat flag
--- 5. Any remaining bindings with the combat/nocombat
--- 6. All @mouseover bindings with the help or harm tag
--- 7. All remaining @mouseover bindings
--- 8. Any remaining bindings with the help or harm tag
--- 9. Any remaining bindings
---
--- In text, this boils down to: combat -> mouseover -> hostility -> default
---
--- It will construct a /cast command that is mix-and-matched from all configured
--- bindings, so if there are two bindings, and one of them has Holy Light with the
--- `[@mouseover,help]` and `[@target]` target priority order, and the other one has
--- Crusader Strike with `[@target,harm]`, it will create a command like this:
--- `/cast [@mouseover,help] Holy Light; [@target,harm] Crusader Strike; [@target] Holy Light`
---
--- @param bindings Binding[]
--- @param interactionType number
--- @return string macro
--- @return string segments
function Addon:GetMacroForBindings(bindings, interactionType)
	assert(type(bindings) == "table", "bad argument #1, expected table but got " .. type(bindings))
	assert(type(interactionType) == "number", "bad argument #1, expected number but got " .. type(interactionType))

	--- @type string[]
	local lines = {
	}

	--- @type string[]
	local macroConditions = {}

	--- @type string[]
	local macroSegments = {}

	-- Add all prefix shared binding options
	do
		local interrupt = false
		local startAutoAttack = false
		local startPetAttack = false
		local cancelQueuedSpell = false
		local cancelForm = false
		local stopSpellTarget = false

		for _, binding in ipairs(bindings) do
			if binding.actionType == Clicked.ActionType.SPELL or binding.actionType == Clicked.ActionType.ITEM or binding.actionType == Clicked.ActionType.CANCELAURA then
				if not cancelQueuedSpell and binding.action.cancelQueuedSpell then
					cancelQueuedSpell = true
					table.insert(lines, "/cancelqueuedspell")
				end

				if interactionType == Addon.InteractionType.REGULAR then
					if not startAutoAttack and binding.action.startAutoAttack then
						startAutoAttack = true
						table.insert(lines, "/startattack")
					end

					if not startPetAttack and binding.action.startPetAttack then
						startPetAttack = true
						table.insert(lines, "/petattack")
					end

					if not cancelForm and binding.action.cancelForm then
						cancelForm = true
						table.insert(lines, "/cancelform")
					end
				end

				if not interrupt and binding.action.interrupt then
					interrupt = true
					table.insert(lines, "/stopcasting")
				end

				-- add a command to remove the blue casting cursor
				if not stopSpellTarget and binding.action.stopSpellTarget then
					stopSpellTarget = true
					table.insert(lines, "/stopspelltarget")
				end
			end
		end
	end

	-- Add all action groups in order
	do
		--- @param binding Binding
		--- @return string|nil
		local function GetPrefixForBinding(binding)
			if binding.actionType == Clicked.ActionType.SPELL or binding.actionType == Clicked.ActionType.ITEM then
				return "/cast "
			end

			if binding.actionType == Clicked.ActionType.CANCELAURA then
				return "/cancelaura "
			end

			return nil
		end

		-- Parse and sort action groups

		--- @type { [integer]: { prefix: string|nil }}
		local bindingGroups = {}

		--- @type table<Action,integer>
		local actionsSequence = {}

		--- @type table<integer,Action[]>
		local actions = {}

		--- @type table<integer,string[]|integer[]>
		local macros = {}

		--- @type table<integer,string[]|integer[]>
		local appends = {}

		for _, binding in ipairs(bindings) do
			local order = binding.action.executionOrder

			if bindingGroups[order] == nil then
				bindingGroups[order] = {
					prefix = GetPrefixForBinding(binding)
				}
			end

			local prefix = GetPrefixForBinding(binding)
			local other = bindingGroups[order].prefix

			if prefix == other or prefix == nil then
				table.insert(bindingGroups[order], binding)
			end
		end

		-- Generate actions for SPELL and ITEM bindings, and insert macro values
		do
			for order, group in pairs(bindingGroups) do
				actions[order] = {}
				macros[order] = {}
				appends[order] = {}

				local nextActionIndex = 1

				for _, binding in ipairs(group) do
					if binding.actionType == Clicked.ActionType.SPELL or binding.actionType == Clicked.ActionType.ITEM then
						for _, action in ipairs(ConstructActions(binding, interactionType)) do
							table.insert(actions[order], action)

							actionsSequence[action] = nextActionIndex
							nextActionIndex = nextActionIndex + 1
						end
					elseif binding.actionType == Clicked.ActionType.MACRO then
						local value = Addon:GetBindingValue(binding)
						table.insert(macros[order], value)
					elseif binding.actionType == Clicked.ActionType.APPEND then
						local value = Addon:GetBindingValue(binding)
						table.insert(appends[order], value)
					elseif binding.actionType == Clicked.ActionType.CANCELAURA then
						local target = Addon:GetNewBindingTargetTemplate()
						target.unit = Addon.TargetUnit.DEFAULT
						target.hostility = Addon.TargetHostility.ANY
						target.vitals = Addon.TargetVitals.ANY

						local action = ConstructAction(binding, target)

						table.insert(actions[order], action)

						actionsSequence[action] = nextActionIndex
						nextActionIndex = nextActionIndex + 1
					end
				end
			end
		end

		-- Add all commands to the macro
		for order, group in pairs(bindingGroups) do
			--- @type string[]
			local localSegments = {}

			-- Put any custom macros on top
			for _, macro in ipairs(macros[order]) do
				table.insert(lines, macro)
			end

			SortActions(actions[order], actionsSequence)

			for index, action in ipairs(actions[order]) do
				local conditions = GetMacroSegmentFromAction(action, interactionType, index == #actions[order])

				if #conditions > 0 then
					conditions = "[" .. conditions .. "]"
				end

				if not Addon:IsNilOrEmpty(conditions) then
					table.insert(macroConditions, conditions)
					table.insert(macroSegments, conditions .. action.ability)
					table.insert(localSegments, conditions .. action.ability)
				else
					table.insert(macroSegments, action.ability)
					table.insert(localSegments, action.ability)
				end
			end

			if #localSegments > 0 then
				local command = group.prefix .. table.concat(localSegments, ";")

				-- Insert any APPEND bindings
				for _, append in ipairs(appends[order]) do
					command = command .. ";" .. tostring(append)
				end

				table.insert(lines, command)
			end
		end
	end

	-- Add all suffix shared binding options
	do
		local targetUnitAfterCast = false

		if #macroConditions > 0 then
			for _, binding in ipairs(bindings) do
				if not targetUnitAfterCast and binding.action.targetUnitAfterCast then
					targetUnitAfterCast = true
					table.insert(lines, "/tar " .. table.concat(macroConditions, ""))
				end
			end
		end
	end

	return table.concat(lines, "\n"), table.concat(macroSegments, ";")
end

--- comment
--- @param binding Binding
--- @return table<string,boolean?>
function Addon:GetCachedBindingState(binding)
	return bindingStateCache[binding.uid]
end

--- Get all active bindings.
---
--- @return Binding[]
function Addon:GetActiveBindings()
	return activeBindings
end

--- @param name string
--- @return boolean
function Addon:IsTalentSelected(name)
	return talentCache[name] == true
end

--- @return boolean
function Addon:IsTalentCacheReady()
	return next(talentCache) ~= nil
end
