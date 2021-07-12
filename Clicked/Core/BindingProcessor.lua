--- @type ClickedInternal
local _, Addon = ...

Addon.BindingTypes = {
	SPELL = "SPELL",
	ITEM = "ITEM",
	MACRO = "MACRO",
	APPEND = "APPEND",
	UNIT_SELECT = "UNIT_SELECT",
	UNIT_MENU = "UNIT_MENU"
}

Addon.CommandType = {
	TARGET = "target",
	MENU = "menu",
	MACRO = "macro"
}

Addon.TargetUnits = {
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

Addon.TargetHostility = {
	ANY = "ANY",
	HELP = "HELP",
	HARM = "HARM"
}

Addon.TargetVitals = {
	ANY = "ANY",
	ALIVE = "ALIVE",
	DEAD = "DEAD"
}

Addon.GroupState = {
	PARTY_OR_RAID = "IN_GROUP_PARTY_OR_RAID",
	PARTY = "IN_GROUP_PARTY",
	RAID = "IN_GROUP_RAID",
	SOLO = "IN_GROUP_SOLO"
}

Addon.InteractionType = {
	REGULAR = 1,
	HOVERCAST = 2
}

--- @type Binding[]
local activeBindings = {}

--- @type table<string,Binding[]>
local hovercastBucket = {}

--- @type table<string,Binding[]>
local regularBucket = {}

local isPendingReload = false

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
	--- @param negated string
	--- @param isUnit boolean
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
			table.insert(flags, key .. ":" .. condition.value)
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
	ParseNegatableBooleanCondition(action.flyable, "flyable")
	ParseNegatableStringCondition(action.channeling, "channeling", "nochanneling")

	if interactionType == Addon.InteractionType.REGULAR and not isLast and needsExistsCheck then
		table.insert(flags, "exists")
	end

	if #action.forms > 0 then
		table.insert(flags, "form:" .. action.forms)
	end

	return table.concat(flags, ",")
end

--- @param binding Binding
--- @param target Binding.Target
--- @return Action
local function ConstructAction(binding, target)
	--- @type Action
	local action = {
		ability = Addon:GetBindingValue(binding),
		type = binding.type
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
	local function AppendNegatableStringCondition(condition, key)
		if condition.selected and not Addon:IsStringNilOrEmpty(condition.value) then
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

	if Addon:IsGameVersionAtleast("BC") then
		AppendCondition(binding.load.flying, "flying")
		AppendCondition(binding.load.flyable, "flyable")
	end

	do
		local forms = Addon:GetAvailableShapeshiftForms(binding)
		action.forms = table.concat(forms, "/")
	end

	if Addon:IsRestrictedKeybind(binding.keybind) or target.unit == nil then
		action.unit = Addon.TargetUnits.MOUSEOVER
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
	local actions = {}

	if binding.targets.hovercastEnabled and interactionType == Addon.InteractionType.HOVERCAST then
		local action = ConstructAction(binding, binding.targets.hovercast)
		table.insert(actions, action)
	end

	if binding.targets.regularEnabled and interactionType == Addon.InteractionType.REGULAR then
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
			{ left = left.unit, right = right.unit, value = Addon.TargetUnits.MOUSEOVER, comparison = "eq" },
			{ left = left.unit, right = right.unit, value = Addon.TargetUnits.MOUSEOVER_TARGET, comparison = "eq"},

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
			{ left = left.flyable, right = right.flyable, value = true, comparison = "eq" },

			-- 3. Any actions that do not meet any of the criteria in this list will be placed here

			-- 4. The player, cursor, and default targets will always come last
			{ left = left.unit, right = right.unit, value = Addon.TargetUnits.PLAYER, comparison = "neq" },
			{ left = left.unit, right = right.unit, value = Addon.TargetUnits.CURSOR, comparison = "neq" },
			{ left = left.unit, right = right.unit, value = Addon.TargetUnits.DEFAULT, comparison = "neq" }
		}

		for _, item in ipairs(priority) do
			local l = item.left
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

--- @param binding Binding
--- @return string
local function GetInternalBindingType(binding)
	if binding.type == Addon.BindingTypes.SPELL then
		return Addon.BindingTypes.MACRO
	end

	if binding.type == Addon.BindingTypes.ITEM then
		return Addon.BindingTypes.MACRO
	end

	if binding.type == Addon.BindingTypes.APPEND then
		return Addon.BindingTypes.MACRO
	end

	return binding.type
end

local function ProcessBuckets()
	--- @param keybind string
	--- @param bindings Binding[]
	--- @param interactionType number
	--- @return Command
	local function Process(keybind, bindings, interactionType)
		if #bindings == 0 then
			return nil
		end

		local reference = bindings[1]
		local command = {
			keybind = keybind,
			hovercast = interactionType == Addon.InteractionType.HOVERCAST
		}

		command.prefix, command.suffix = Addon:CreateAttributeIdentifier(command.keybind, command.hovercast)

		if GetInternalBindingType(reference) == Addon.BindingTypes.MACRO then
			command.action = Addon.CommandType.MACRO
			command.data = Addon:GetMacroForBindings(bindings, interactionType)
		elseif reference.type == Addon.BindingTypes.UNIT_SELECT then
			command.action = Addon.CommandType.TARGET
		elseif reference.type == Addon.BindingTypes.UNIT_MENU then
			command.action = Addon.CommandType.MENU
		else
			error("Unhandled binding type: " .. reference.type)
		end

		return command
	end

	--- @type Command[]
	local commands = {}

	for keybind, bindings in pairs(hovercastBucket) do
		local command = Process(keybind, bindings, Addon.InteractionType.HOVERCAST)
		table.insert(commands, command)
	end

	for keybind, bindings in pairs(regularBucket) do
		local command = Process(keybind, bindings, Addon.InteractionType.REGULAR)
		table.insert(commands, command)
	end

	Addon:StatusOutput_HandleCommandsGenerated(commands)
	Addon:ProcessCommands(commands)
end

--- @param bindings Binding[]
local function GenerateBuckets(bindings)
	---@param bucket table<string,Binding>
	---@param binding Binding
	local function Insert(bucket, binding)
		if #bucket == 0 then
			table.insert(bucket, binding)
		else
			local reference = bucket[1]

			if GetInternalBindingType(binding) == GetInternalBindingType(reference) then
				table.insert(bucket, binding)
			end
		end
	end

	wipe(hovercastBucket)
	wipe(regularBucket)

	--- @type Binding
	for _, binding in ipairs(bindings) do
		local key = binding.keybind

		if binding.targets.hovercastEnabled then
			hovercastBucket[key] = hovercastBucket[key] or {}
			Insert(hovercastBucket[key], binding)
		end

		if binding.targets.regularEnabled then
			regularBucket[key] = regularBucket[key] or {}
			Insert(regularBucket[key], binding)
		end
	end
end

-- Public addon API

--- Reload the active bindings, this should be called any time changes have been made to data of a binding, or potential load conditions change.
--- If this is called during combat, it will instead be deferred until the combat finishes.
function Clicked:ReloadActiveBindings()
	if InCombatLockdown() then
		isPendingReload = true
		return
	end

	wipe(activeBindings)

	for _, binding in Clicked:IterateConfiguredBindings() do
		if Addon:CanBindingLoad(binding) then
			table.insert(activeBindings, binding)
		end
	end

	GenerateBuckets(activeBindings)
	ProcessBuckets()

	Addon:BindingConfig_Redraw()
end

--- Evaluate the generated macro for a binding and return the target unit if there is any.
---
--- @param binding Binding The input binding, cannot be `nil` and must be a valid binding table
--- @return string hovercastTarget The first satisfied hovercast unit if any, `nil` otherwise. If this has a value it will always be `@mouseover`.
--- @return string regularTarget The first satisfied regular unit if any, `nil` otherwise.
function Clicked:EvaluateBindingMacro(binding)
	assert(Addon:IsBindingType(binding), "bad argument #1, expected Binding but got " .. type(binding))

	local bindings = { binding }

	local hovercastTarget = nil
	local regularTarget = nil

	if binding.targets.hovercastEnabled then
		local _, hovercast = Addon:GetMacroForBindings(bindings, Addon.InteractionType.HOVERCAST)
		_, hovercastTarget = SecureCmdOptionParse(hovercast)
	end

	if binding.targets.regularEnabled then
		local _, regular = Addon:GetMacroForBindings(bindings, Addon.InteractionType.REGULAR)
		_, regularTarget = SecureCmdOptionParse(regular)
	end

	return hovercastTarget, regularTarget
end

--- Iterate through all currently active bindings, this function can be used in a `for in` loop.
---
--- @return function iterator
--- @return table t
--- @return number i
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

	local result = {}
	local units = {
		[unit] = true
	}

	-- find other unit types that is valid for this target
	for k in pairs(Addon.TargetUnits) do
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
		if binding.type ~= Addon.BindingTypes.SPELL and binding.type ~= Addon.BindingTypes.ITEM then
			return false
		end

		if not Addon:IsBindingValidForCurrentState(binding) then
			return false
		end

		-- hovercast
		do
			local hovercast = binding.targets.hovercast
			local enabled = binding.targets.hovercastEnabled

			if enabled and GetMouseFocus() ~= WorldFrame and IsTargetValid(hovercast) then
				return true
			end
		end

		-- regular
		do
			local enabled = binding.targets.regularEnabled

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

-- Private addon API

function Addon:ReloadActiveBindingsIfPending()
	if not isPendingReload then
		return
	end

	isPendingReload = false
	Clicked:ReloadActiveBindings()
end

--- Check if the specified binding is currently active based on the configuration
--- provided in the binding's Load Options, and whether the binding is actually
--- valid (it has a keybind and an action to perform)
---
--- @param binding Binding
--- @return boolean
function Addon:CanBindingLoad(binding)
	---comment
	---@param data Binding.TriStateLoadOption
	---@param validationFunc "fun(input):boolean"
	---@return boolean
	local function ValidateTriStateLoadOption(data, validationFunc)
		if data.selected == 1 then
			if not validationFunc(data.single) then
				return false
			end
		elseif data.selected == 2 then
			local hasAny = false

			for i = 1, #data.multiple do
				if validationFunc(data.multiple[i]) then
					hasAny = true
					break
				end
			end

			if not hasAny then
				return false
			end
		end

		return true
	end

	if binding.keybind == "" then
		return false
	end

	do
		local value = Addon:GetBindingValue(binding)

		if value ~= nil and #tostring(value) == 0 then
			return false
		end
	end

	-- both hovercast and regular targets disabled
	do
		local targets = binding.targets

		if not targets.hovercastEnabled and not targets.regularEnabled then
			return false
		end
	end

	local load = binding.load

	-- If the "never load" toggle has been enabled, there's no point in checking other values.
	if load.never then
		return false
	end

	-- player name
	do
		local playerNameRealm = load.playerNameRealm

		if playerNameRealm.selected then
			local value = playerNameRealm.value

			local name = UnitName("player")
			local realm = GetRealmName()

			if value ~= name and value ~= name .. "-" .. realm then
				return false
			end
		end
	end

	-- class
	do
		local function IsClassIndexSelected(index)
			local _, className = UnitClass("player")
			return className == index
		end

		if not ValidateTriStateLoadOption(load.class, IsClassIndexSelected) then
			return false
		end
	end

	-- race
	do
		local function IsRaceIndexSelected(index)
			local _, raceName = UnitRace("player")
			return raceName == index
		end

		if not ValidateTriStateLoadOption(load.race, IsRaceIndexSelected) then
			return false
		end
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		-- specialization
		do
			local function IsSpecializationIndexSelected(index)
				return index == GetSpecialization()
			end

			if not ValidateTriStateLoadOption(load.specialization, IsSpecializationIndexSelected) then
				return false
			end
		end

		-- talent selected
		do
			local function IsTalentIndexSelected(index)
				local tier = math.ceil(index / 3)
				local column  = index % 3

				if column == 0 then
					column = 3
				end

				local _, _, _, selected, _, _, _, _, _, _, known = GetTalentInfo(tier, column, 1)
				return selected or known
			end

			if not ValidateTriStateLoadOption(load.talent, IsTalentIndexSelected) then
				return false
			end
		end

		-- pvp talent selected
		do
			local function AppendTalentIdsFromSlot(items, slot)
				local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slot);

				if slotInfo and slotInfo.availableTalentIDs then
					for _, id in ipairs(slotInfo.availableTalentIDs) do
						table.insert(items, id)
					end
				end
			end

			local function IsPvPTalentIndexSelected(talentIndex)
				local talentIds = {}
				AppendTalentIdsFromSlot(talentIds, 1)
				AppendTalentIdsFromSlot(talentIds, 2)

				-- talentIds can be empty on the first PLAYER_TALENT_UPDATE event fires before PLAYER_ENTERING_WORLD fires
				if #talentIds == 0 then
					return false
				end

				local talentId = talentIds[talentIndex]
				local _, _, _, selected, _, _, _, _, _, known, grantedByAura = GetPvpTalentInfoByID(talentId)

				return selected or known or grantedByAura
			end

			if not ValidateTriStateLoadOption(load.pvpTalent, IsPvPTalentIndexSelected) then
				return false
			end
		end

		-- war mode
		do
			local warMode = load.warMode

			if warMode.selected then
				if warMode.value == true and not C_PvP.IsWarModeDesired() then
					return false
				elseif warMode.value == false and C_PvP.IsWarModeDesired() then
					return false
				end
			end
		end

		-- covenant
		do
			local function IsCovenantIndexSelected(index)
				return index == C_Covenants.GetActiveCovenantID()
			end

			if not ValidateTriStateLoadOption(load.covenant, IsCovenantIndexSelected) then
				return false
			end
		end
	end

	-- forms
	do
		local function IsFormIndexSelected(index)
			local formIndex = index - 1

			-- 0 is no form/humanoid form and is always known
			if formIndex == 0 then
				return true
			end

			local specId = GetSpecializationInfo(GetSpecialization())

			-- specId can be nil on the first PLAYER_TALENT_UPDATE event fires before PLAYER_ENTERING_WORLD fires
			if specId == nil then
				return false
			end

			local forms = Addon:GetShapeshiftFormsForSpecId(specId)
			local spellId = forms[formIndex]

			return IsSpellKnown(spellId)
		end

		if not ValidateTriStateLoadOption(load.form, IsFormIndexSelected) then
			return false
		end
	end

	-- spell known
	do
		-- If the known spell limiter has been enabled, see if the spell is currrently
		-- avaialble for the player. This is not limited to just spells as the name
		-- implies, using the GetSpellInfo function on an item also returns a valid value.

		local spellKnown = load.spellKnown

		if spellKnown.selected then
			local name = Addon:GetSpellInfo(spellKnown.value)

			if name == nil then
				return false
			end
		end
	end

	-- in group
	do
		local inGroup = load.inGroup

		if inGroup.selected then
			if inGroup.value == Addon.GroupState.SOLO and GetNumGroupMembers() > 0 then
				return false
			else
				if inGroup.value == Addon.GroupState.PARTY_OR_RAID and GetNumGroupMembers() == 0 then
					return false
				elseif inGroup.value == Addon.GroupState.PARTY and (GetNumSubgroupMembers() == 0 or IsInRaid()) then
					return false
				elseif inGroup.value == Addon.GroupState.RAID and not IsInRaid() then
					return false
				end
			end
		end
	end

	-- instance type
	do
		local function IsInInstanceType(type)
			local inInstance, instanceType = IsInInstance()

			-- Convert to lowercase as that is what `IsInInstance` returns
			type = string.lower(type)

			if type == "none" then
				return not inInstance
			else
				if inInstance then
					return type == instanceType
				end

				return false
			end
		end

		if not ValidateTriStateLoadOption(load.instanceType, IsInInstanceType) then
			return false
		end
	end

	-- zone name
	do
		local zoneName = load.zoneName

		if zoneName.selected then
			local realZone = GetRealZoneText()
			local anyTrue = false

			for zone in string.gmatch(zoneName.value, "([^;]+)") do
				local negate = false

				if string.sub(zone, 0, 1) == "!" then
					negate = true
					zone = string.sub(zone, 2)
				end

				if (negate and zone ~= realZone) or (not negate and zone == realZone) then
					anyTrue = true
					break
				end
			end

			if not anyTrue then
				return false
			end
		end
	end

	-- player in group
	do
		local playerInGroup = load.playerInGroup

		if playerInGroup.selected then
			local found = false

			if playerInGroup.value == UnitName("player") then
				found = true
			else
				local unit = IsInRaid() and "raid" or "party"
				local numGroupMembers = GetNumGroupMembers()

				if numGroupMembers == 0 then
					return false
				end

				for i = 1, numGroupMembers do
					local name = UnitName(unit .. i)

					if name == playerInGroup.value then
						found = true
						break
					end
				end
			end

			if not found then
				return false
			end
		end
	end

	-- item equipped
	do
		local equipped = load.equipped

		if equipped.selected then
			if not IsEquippedItem(equipped.value) then
				return false
			end
		end
	end

	return true
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

		if name == nil then
			return false
		end

		if binding.type == Addon.BindingTypes.SPELL and not IsSpellKnown(id) then
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
--- It will construct an /use command that is mix-and-matched from all configured
--- bindings, so if there are two bindings, and one of them has Holy Light with the
--- `[@mouseover,help]` and `[@target]` target priority order, and the other one has
--- Crusader Strike with `[@target,harm]`, it will create a command like this:
--- `/use [@mouseover,help] Holy Light; [@target,harm] Crusader Strike; [@target] Holy Light`
---
--- @param bindings Binding[]
--- @param interactionType number
--- @return string macro
--- @return string segments
function Addon:GetMacroForBindings(bindings, interactionType)
	assert(type(bindings) == "table", "bad argument #1, expected table but got " .. type(bindings))
	assert(type(interactionType) == "number", "bad argument #1, expected number but got " .. type(interactionType))

	local lines = {}

	local macroConditions = {}
	local macroSegments = {}

	-- Add all prefix shared binding options
	do
		local interrupt = false
		local startAutoAttack = false
		local startPetAttack = false
		local cancelQueuedSpell = false

		for _, binding in ipairs(bindings) do
			if binding.type == Addon.BindingTypes.SPELL or binding.type == Addon.BindingTypes.ITEM then
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
				end

				if not interrupt and binding.action.interrupt then
					interrupt = true
					table.insert(lines, "/stopcasting")
				end
			end
		end

		-- add a command to remove the blue casting cursor
		table.insert(lines, "/stopspelltarget")
	end

	-- Add all action groups in order
	do
		-- Parse and sort action groups
		local bindingGroups = {}

		local actionsSequence = {}
		local actions = {}

		local macros = {}
		local appends = {}

		for _, binding in ipairs(bindings) do
			local order = binding.action.executionOrder

			bindingGroups[order] = bindingGroups[order] or {}
			table.insert(bindingGroups[order], binding)
		end

		-- Generate actions for SPELL and ITEM bindings, and insert macro values
		do
			for order, group in pairs(bindingGroups) do
				actions[order] = {}
				macros[order] = {}
				appends[order] = {}

				local nextActionIndex = 1

				for _, binding in ipairs(group) do
					if binding.type == Addon.BindingTypes.SPELL or binding.type == Addon.BindingTypes.ITEM then
						for _, action in ipairs(ConstructActions(binding, interactionType)) do
							table.insert(actions[order], action)

							actionsSequence[action] = nextActionIndex
							nextActionIndex = nextActionIndex + 1
						end
					elseif binding.type == Addon.BindingTypes.MACRO then
						local value = Addon:GetBindingValue(binding)
						table.insert(macros[order], value)
					elseif binding.type == Addon.BindingTypes.APPEND then
						local value = Addon:GetBindingValue(binding)
						table.insert(appends[order], value)
					end
				end
			end
		end

		-- Add all commands to the macro
		for order in pairs(bindingGroups) do
			local localSegments = {}

			-- Put any custom macros on top
			for _, macro in ipairs(macros[order]) do
				table.insert(lines, macro)
			end

			SortActions(actions[order], actionsSequence)

			for index, action in ipairs(actions[order]) do
				local conditions = GetMacroSegmentFromAction(action, interactionType, index == #actions[order])

				if #conditions > 0 then
					conditions = "[" .. conditions .. "] "
				end

				if not Addon:IsStringNilOrEmpty(conditions) then
					table.insert(macroConditions, conditions)
					table.insert(macroSegments, conditions .. action.ability)
					table.insert(localSegments, conditions .. action.ability)
				else
					table.insert(macroSegments, action.ability)
					table.insert(localSegments, action.ability)
				end
			end

			if #localSegments > 0 then
				local command = "/use " .. table.concat(localSegments, "; ")

				-- Insert any APPEND bindings
				for _, append in ipairs(appends[order]) do
					command = command .. "; " .. append
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
				if binding.type == Addon.BindingTypes.SPELL or binding.type == Addon.BindingTypes.ITEM then
					if not targetUnitAfterCast and binding.action.targetUnitAfterCast then
						targetUnitAfterCast = true
						table.insert(lines, "/tar " .. table.concat(macroConditions, ""))
					end
				end
			end
		end
	end

	return table.concat(lines, "\n"), table.concat(macroSegments, "; ")
end
