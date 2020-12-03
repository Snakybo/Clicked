Clicked.BindingTypes = {
	SPELL = "SPELL",
	ITEM = "ITEM",
	MACRO = "MACRO",
	UNIT_SELECT = "UNIT_SELECT",
	UNIT_MENU = "UNIT_MENU"
}

Clicked.CommandType = {
	TARGET = "target",
	MENU = "menu",
	MACRO = "macro"
}

Clicked.TargetUnits = {
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
	FOCUS = "FOCUS",
	MOUSEOVER = "MOUSEOVER",
	CURSOR = "CURSOR"
}

Clicked.TargetHostility = {
	ANY = "ANY",
	HELP = "HELP",
	HARM = "HARM"
}

Clicked.TargetVitals = {
	ANY = "ANY",
	ALIVE = "ALIVE",
	DEAD = "DEAD"
}

Clicked.MacroMode = {
	FIRST = "FIRST",
	APPEND = "APPEND",
	LAST = "LAST"
}

Clicked.CombatState = {
	IN_COMBAT = "IN_COMBAT",
	NOT_IN_COMBAT = "NOT_IN_COMBAT"
}

Clicked.WarModeState = {
	IN_WAR_MODE = "IN_WAR_MODE",
	NOT_IN_WAR_MODE = "NOT_IN_WAR_MODE"
}

Clicked.GroupState = {
	PARTY_OR_RAID = "IN_GROUP_PARTY_OR_RAID",
	PARTY = "IN_GROUP_PARTY",
	RAID = "IN_GROUP_RAID",
	SOLO = "IN_GROUP_SOLO"
}

Clicked.PetState = {
	ACTIVE = "ACTIVE",
	INACTIVE = "INACTIVE"
}

Clicked.InteractionType = {
	REGULAR = 1,
	HOVERCAST = 2
}

Clicked.EVENT_BINDINGS_CHANGED = "CLICKED_BINDINGS_CHANGED"
Clicked.EVENT_BINDING_PROCESSOR_COMPLETE = "CLICKED_BINDING_PROCESSOR_COMPLETE"

local activeBindings
local pendingReload

local function GetMacroSegmentFromAction(action, interactionType)
	local flags = {}
	local impliedExists = false

	if action.unit == Clicked.TargetUnits.PLAYER then
		table.insert(flags, "@player")
	elseif action.unit == Clicked.TargetUnits.TARGET then
		table.insert(flags, "@target")
	elseif action.unit == Clicked.TargetUnits.TARGET_OF_TARGET then
		table.insert(flags, "@targettarget")
	elseif action.unit == Clicked.TargetUnits.MOUSEOVER then
		table.insert(flags, "@mouseover")
	elseif action.unit == Clicked.TargetUnits.PET then
		table.insert(flags, "@pet")
	elseif action.unit == Clicked.TargetUnits.PET_TARGET then
		table.insert(flags, "@pettarget")
	elseif action.unit == Clicked.TargetUnits.PARTY_1 then
		table.insert(flags, "@party1")
	elseif action.unit == Clicked.TargetUnits.PARTY_2 then
		table.insert(flags, "@party2")
	elseif action.unit == Clicked.TargetUnits.PARTY_3 then
		table.insert(flags, "@party3")
	elseif action.unit == Clicked.TargetUnits.PARTY_4 then
		table.insert(flags, "@party4")
	elseif action.unit == Clicked.TargetUnits.PARTY_5 then
		table.insert(flags, "@party5")
	elseif action.unit == Clicked.TargetUnits.FOCUS then
		table.insert(flags, "@focus")
	elseif action.unit == Clicked.TargetUnits.CURSOR then
		table.insert(flags, "@cursor")
	end

	if Clicked:CanUnitBeHostile(action.unit) then
		if action.hostility == Clicked.TargetHostility.HELP then
			table.insert(flags, "help")
			impliedExists = true
		elseif action.hostility == Clicked.TargetHostility.HARM then
			table.insert(flags, "harm")
			impliedExists = true
		end
	end

	if Clicked:CanUnitBeDead(action.unit) then
		if action.vitals == Clicked.TargetVitals.ALIVE then
			table.insert(flags, "nodead")
			impliedExists = true
		elseif action.vitals == Clicked.TargetVitals.DEAD then
			table.insert(flags, "dead")
			impliedExists = true
		end
	end

	if action.pet == Clicked.PetState.ACTIVE then
		table.insert(flags, "pet")
	elseif action.pet == Clicked.PetState.INACTIVE then
		table.insert(flags, "nopet")
	end

	if not impliedExists and interactionType == Clicked.InteractionType.REGULAR and Clicked:CanUnitHaveFollowUp(action.unit) then
		table.insert(flags, "exists")
	end

	if action.combat == Clicked.CombatState.IN_COMBAT then
		table.insert(flags, "combat")
	elseif action.combat == Clicked.CombatState.NOT_IN_COMBAT then
		table.insert(flags, "nocombat")
	end

	if #action.forms > 0 then
		table.insert(flags, "form:" .. action.forms)
	end

	return table.concat(flags, ",")
end

local function ConstructAction(binding, target)
	local action = {}
	local data = Clicked:GetActiveBindingData(binding)

	action.ability = data.value

	do
		local combat = binding.load.combat

		if combat.selected then
			action.combat = combat.value
		else
			action.combat = ""
		end
	end

	do
		local pet = binding.load.pet

		if pet.selected then
			action.pet = pet.value
		else
			action.pet = ""
		end
	end

	do
		local form = binding.load.form
		local forms = {}

		-- Forms need to be zero-indexed
		if form.selected == 1 then
			forms[1] = form.single - 1
		elseif form.selected == 2 then
			for i = 1, #form.multiple do
				forms[i] = form.multiple[i] - 1
			end
		end

		if select(2, UnitClass("player")) == "DRUID" then
			local specId = GetSpecializationInfo(GetSpecialization())
			local all = Clicked:GetShapeshiftFormsForSpecId(specId)
			local available = {}
			local result = {}

			for _, spellId in ipairs(all) do
				if IsSpellKnown(spellId) then
					table.insert(available, spellId)
				end
			end

			for i = 1, #forms do
				local formId = forms[i]

				-- 0 is [form:0] aka humanoid
				if formId == 0 then
					table.insert(result, formId)

					-- Incarnation: Tree of Life does not show up as a shapeshift form,
					-- but it will always be NUM_SHAPESHIFT_FORMS + 1 (See: #9)
					if IsSpellKnown(33891) then
						table.insert(result, GetNumShapeshiftForms() + 1)
					end
				else
					for j = 1, #available do
						if available[j] == all[formId] then
							table.insert(result, j)
							break
						end
					end
				end
			end

			forms = result
		end

		action.forms = table.concat(forms, "/")
	end

	if Clicked:IsRestrictedKeybind(binding.keybind) or target.unit == nil then
		action.unit = Clicked.TargetUnits.MOUSEOVER
	else
		action.unit = target.unit
	end

	if target.hostility ~= Clicked.TargetHostility.ANY then
		action.hostility = target.hostility
	else
		action.hostility = ""
	end

	if target.vitals ~= Clicked.TargetVitals.ANY then
		action.vitals = target.vitals
	else
		action.vitals = ""
	end

	return action
end

local function ConstructActions(binding, interactionType)
	local actions = {}

	if binding.targets.hovercast.enabled and interactionType == Clicked.InteractionType.HOVERCAST then
		local action = ConstructAction(binding, binding.targets.hovercast)
		table.insert(actions, action)
	end

	if binding.targets.regular.enabled and interactionType == Clicked.InteractionType.REGULAR then
		for _, target in ipairs(binding.targets.regular) do
			local action = ConstructAction(binding, target)
			table.insert(actions, action)

			if not Clicked:CanUnitHaveFollowUp(target.unit) then
				break
			end
		end
	end

	return actions
end

local function SortActions(left, right)
	-- 1. @mouseover
	if left.unit == Clicked.TargetUnits.MOUSEOVER and right.unit ~= Clicked.TargetUnits.MOUSEOVER then
		return true
	end

	if left.unit ~= Clicked.TargetUnits.MOUSEOVER and right.unit == Clicked.TargetUnits.MOUSEOVER then
		return false
	end

	-- 2. any hostility flags (help, harm)
	if #left.hostility > 0 and #right.hostility == 0 then
		return true
	end

	if #left.hostility == 0 and #right.hostility > 0 then
		return false
	end

	-- 3. any vitals flags (dead, nodead)
	if #left.vitals > 0 and #right.vitals == 0 then
		return true
	end

	if #left.vitals == 0 and #right.vitals > 0 then
		return false
	end

	-- 4. any combat flags (combat, nocombat)
	if #left.combat > 0 and #right.combat == 0 then
		return true
	end

	if #left.combat == 0 and #right.combat > 0 then
		return false
	end

	-- 5. any form flags (forms:N)
	if #left.forms > 0 and #right.forms == 0 then
		return true
	end

	if #left.forms == 0 and #right.forms > 0 then
		return false
	end

	-- 6. @player
	if left.unit == Clicked.TargetUnits.PLAYER and right.unit ~= Clicked.TargetUnits.PLAYER then
		return false
	end

	if left.unit ~= Clicked.TargetUnits.PLAYER and right.unit == Clicked.TargetUnits.PLAYER then
		return true
	end

	-- 7. default
	if left.unit == Clicked.TargetUnits.DEFAULT and right.unit ~= Clicked.TargetUnits.DEFAULT then
		return false
	end

	if left.unit ~= Clicked.TargetUnits.DEFAULT and right.unit == Clicked.TargetUnits.DEFAULT then
		return true
	end

	return false
end

local function GetInternalBindingType(binding)
	if binding.type == Clicked.BindingTypes.SPELL then
		return Clicked.BindingTypes.MACRO
	end

	if binding.type == Clicked.BindingTypes.ITEM then
		return Clicked.BindingTypes.MACRO
	end

	return binding.type
end

local function ProcessBuckets(hovercast, regular)
	local function Process(keybind, bindings, interactionType)
		if #bindings == 0 then
			return nil
		end

		local reference = bindings[1]
		local command = {
			keybind = keybind,
			hovercast = interactionType == Clicked.InteractionType.HOVERCAST
		}

		command.prefix, command.suffix = Clicked:CreateAttributeIdentifier(command.keybind, command.hovercast)

		if GetInternalBindingType(reference) == Clicked.BindingTypes.MACRO then
			command.action = Clicked.CommandType.MACRO
			command.data, command.macroFlags = Clicked:GetMacroForBindings(bindings, interactionType)
		elseif reference.type == Clicked.BindingTypes.UNIT_SELECT then
			command.action = Clicked.CommandType.TARGET
		elseif reference.type == Clicked.BindingTypes.UNIT_MENU then
			command.action = Clicked.CommandType.MENU
		else
			error("Unhandled binding type: " .. reference.type)
		end

		return command
	end

	local commands = {}

	for keybind, bindings in pairs(hovercast) do
		local command = Process(keybind, bindings, Clicked.InteractionType.HOVERCAST)
		table.insert(commands, command)
	end

	for keybind, bindings in pairs(regular) do
		local command = Process(keybind, bindings, Clicked.InteractionType.REGULAR)
		table.insert(commands, command)
	end

	Clicked:SendMessage(Clicked.EVENT_BINDING_PROCESSOR_COMPLETE, commands)
	Clicked:ProcessCommands(commands)
end

local function GenerateBuckets(bindings)
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

	local hovercast = {}
	local regular = {}

	for _, binding in ipairs(bindings) do
		local key = binding.keybind

		if binding.targets.hovercast.enabled then
			hovercast[key] = hovercast[key] or {}
			Insert(hovercast[key], binding)
		end

		if binding.targets.regular.enabled then
			regular[key] = regular[key] or {}
			Insert(regular[key], binding)
		end
	end

	return hovercast, regular
end

--- Reloads the active bindings, this will go through all configured bindings
--- and check their (current) validity using the CanBindingLoad function.
--- If there are multiple bindings that use the same keybind it will use the
--- PrioritizeBindings function to sort them.
function Clicked:ReloadActiveBindings()
	if InCombatLockdown() then
		pendingReload = true
		return
	end

	activeBindings = {}

	for _, binding in self:IterateConfiguredBindings() do
		if self:CanBindingLoad(binding) then
			table.insert(activeBindings, binding)
		end
	end

	local hovercast, regular = GenerateBuckets(activeBindings)
	ProcessBuckets(hovercast, regular)

	self:SendMessage(self.EVENT_BINDINGS_CHANGED)
end

function Clicked:ReloadActiveBindingsIfPending()
	if not pendingReload then
		return
	end

	pendingReload = false
	self:ReloadActiveBindings()
end

function Clicked:IterateActiveBindings()
	return ipairs(activeBindings)
end

--- Check if the specified binding is currently active based on the configuration
--- provided in the binding's Load Options, and whether the binding is actually
--- valid (it has a keybind and an action to perform)
---
--- @param binding table
--- @return boolean
function Clicked:CanBindingLoad(binding)
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
		local data = self:GetActiveBindingData(binding)

		if data ~= nil and data.value ~= nil and #data.value == 0 then
			return false
		end
	end

	-- both hovercast and regular targets disabled
	do
		local targets = binding.targets

		if not targets.hovercast.enabled and not targets.regular.enabled then
			return false
		end
	end

	local load = binding.load

	do
		-- If the "never load" toggle has been enabled, there's no point in checking other
		-- values.

		if load.never then
			return false
		end
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

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
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
				if warMode.value == Clicked.WarModeState.IN_WAR_MODE and not C_PvP.IsWarModeDesired() then
					return false
				elseif warMode.value == Clicked.WarModeState.NOT_IN_WAR_MODE and C_PvP.IsWarModeDesired() then
					return false
				end
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

			local forms = self:GetShapeshiftFormsForSpecId(specId)
			local spellId = forms[formIndex]

			return IsSpellKnown(spellId)
		end

		if not ValidateTriStateLoadOption(load.form, IsFormIndexSelected) then
			return false
		end
	end

	do
		-- If the known spell limiter has been enabled, see if the spell is currrently
		-- avaialble for the player. This is not limited to just spells as the name
		-- implies, using the GetSpellInfo function on an item also returns a valid value.

		local spellKnown = load.spellKnown

		if spellKnown.selected then
			local name = GetSpellInfo(spellKnown.value)

			if name == nil then
				return false
			end
		end
	end

	do
		local inGroup = load.inGroup

		if inGroup.selected then
			if inGroup.value == Clicked.GroupState.SOLO and GetNumGroupMembers() > 0 then
				return false
			else
				if inGroup.value == Clicked.GroupState.PARTY_OR_RAID and GetNumGroupMembers() == 0 then
					return false
				elseif inGroup.value == Clicked.GroupState.PARTY and (GetNumSubgroupMembers() == 0 or IsInRaid()) then
					return false
				elseif inGroup.value == Clicked.GroupState.RAID and not IsInRaid() then
					return false
				end
			end
		end
	end

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
--- @param bindings table
--- @param interactionType string
--- @return string
--- @return table
function Clicked:GetMacroForBindings(bindings, interactionType)
	local result = {}
	local interruptCurrentCast = false
	local startAutoAttack = false

	local actions = {}

	-- add a segment to remove the blue casting cursor
	table.insert(result, "/click " .. Clicked.STOP_CASTING_BUTTON_NAME)

	for _, binding in ipairs(bindings) do
		local data = Clicked:GetActiveBindingData(binding)
		local shared = Clicked:GetSharedBindingData(binding)

		if binding.type == Clicked.BindingTypes.MACRO then
			if data.mode == Clicked.MacroMode.FIRST then
				table.insert(result, data.value)
			end
		else
			local extra = {}

			if not interruptCurrentCast and shared.interruptCurrentCast then
				interruptCurrentCast = true
				table.insert(extra, "/stopcasting")
			end

			if not startAutoAttack and interactionType == Clicked.InteractionType.REGULAR then
				for _, target in ipairs(binding.targets.regular) do
					if target.unit == Clicked.TargetUnits.TARGET and target.hostility ~= Clicked.TargetHostility.HELP then
						startAutoAttack = true
						table.insert(extra, "/startattack [@target,harm]")
						break
					end

					if not Clicked:CanUnitHaveFollowUp(target.unit) then
						break
					end
				end
			end

			for i = #extra, 1, - 1 do
				table.insert(result, 1, extra[i])
			end

			for _, action in ipairs(ConstructActions(binding, interactionType)) do
				table.insert(actions, action)
			end
		end
	end

	-- Now sort the actions according to the above schema

	table.sort(actions, SortActions)

	-- Construct a valid macro from the data

	local allFlags = {}
	local segments = {}

	for _, action in ipairs(actions) do
		local flags = GetMacroSegmentFromAction(action, interactionType)

		if #flags > 0 then
			flags = "[" .. flags .. "] "
		end

		table.insert(allFlags, flags)
		table.insert(segments, flags .. action.ability)
	end

	if #segments > 0 then
		local command = "/use " .. table.concat(segments, "; ")

		for _, binding in ipairs(bindings) do
			local data = Clicked:GetActiveBindingData(binding)

			if binding.type == Clicked.BindingTypes.MACRO and data.mode == Clicked.MacroMode.APPEND then
				command = command .. "; " .. data.value
			end
		end

		table.insert(result, command)
	end

	for _, binding in ipairs(bindings) do
		local data = Clicked:GetActiveBindingData(binding)

		if binding.type == Clicked.BindingTypes.MACRO and data.mode == Clicked.MacroMode.LAST then
			table.insert(result, data.value)
		end
	end

	return table.concat(result, "\n"), allFlags
end
