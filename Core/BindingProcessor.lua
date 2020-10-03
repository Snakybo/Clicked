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
	PLAYER = "PLAYER",
	GLOBAL = "GLOBAL",
	TARGET = "TARGET",
	TARGET_OF_TARGET = "TARGET_OF_TARGET",
	PARTY_1 = "PARTY_1",
	PARTY_2 = "PARTY_2",
	PARTY_3 = "PARTY_3",
	PARTY_4 = "PARTY_4",
	PARTY_5 = "PARTY_5",
	FOCUS = "FOCUS",
	MOUSEOVER = "MOUSEOVER",
	HOVERCAST = "HOVERCAST",
	CURSOR = "CURSOR"
}

Clicked.TargetHostility = {
	ANY = "ANY",
	HELP = "HELP",
	HARM = "HARM"
}

Clicked.TargetStatus = {
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

Clicked.EVENT_BINDINGS_CHANGED = "CLICKED_BINDINGS_CHANGED"
Clicked.EVENT_BINDING_PROCESSOR_COMPLETE = "CLICKED_BINDING_PROCESSOR_COMPLETE"

local configuredBindings = {}
local activeBindings = {}

local function GetMacroSegmentFromAction(action)
	local flags = {}

	if action.unit == Clicked.TargetUnits.PLAYER then
		table.insert(flags, "@player")
	elseif action.unit == Clicked.TargetUnits.TARGET then
		table.insert(flags, "@target")
	elseif action.unit == Clicked.TargetUnits.TARGET_OF_TARGET then
		table.insert(flags, "@targettarget")
	elseif action.unit == Clicked.TargetUnits.MOUSEOVER or action.unit == Clicked.TargetUnits.HOVERCAST then
		table.insert(flags, "@mouseover")
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
		elseif action.hostility == Clicked.TargetHostility.HARM then
			table.insert(flags, "harm")
		end
	end

	if Clicked:CanUnitBeDead(action.unit) then
		if action.status == Clicked.TargetStatus.ALIVE then
			table.insert(flags, "nodead")
		elseif action.status == Clicked.TargetStatus.DEAD then
			table.insert(flags, "dead")
		end
	end

	if Clicked:CanUnitHaveFollowUp(action.unit) then
		table.insert(flags, "exists")
	end

	if action.combat == Clicked.CombatState.IN_COMBAT then
		table.insert(flags, "combat")
	elseif action.combat == Clicked.CombatState.NOT_IN_COMBAT then
		table.insert(flags, "nocombat")
	end

	if #action.stance > 0 then
		table.insert(flags, "stance:" .. action.stance)
	end

	return table.concat(flags, ",")
end

local function ConstructAction(binding, target)
	local action = {}

	if binding.type == Clicked.BindingTypes.SPELL then
		action.ability = binding.action.spell
	elseif binding.type == Clicked.BindingTypes.ITEM then
		action.ability = binding.action.item
	end

	do
		local combat = binding.load.combat

		if combat.selected then
			action.combat = combat.value
		else
			action.combat = ""
		end
	end

	do
		local stance = binding.load.stance

		-- stances need to be 0 indexed
		if stance.selected == 1 then
			action.stance = tostring(stance.single - 1)
		elseif stance.selected == 2 then
			local stances = {}

			for i = 1, #stance.multiple do
				stances[i] = stance.multiple[i] - 1
			end

			action.stance = table.concat(stances, "/")
		else
			action.stance = ""
		end
	end

	if Clicked:IsRestrictedKeybind(binding.keybind) then
		action.unit = Clicked.TargetUnits.HOVERCAST
	else
		action.unit = target.unit
	end

	action.hostility = target.hostility
	action.status = target.status

	return action
end

local function ConstructActions(binding)
	local actions = {}

	-- The primary target is a bit special, it can contain the GLOBAL or HOVERCAST target
	-- (as those cannot have predecessors or successors), additionally if the binding is
	-- using a restricted keybind, we're treating it as HOVERCAST internally.

	local action = ConstructAction(binding, binding.primaryTarget)
	table.insert(actions, action)

	if Clicked:CanUnitHaveFollowUp(binding.primaryTarget.unit) then
		for _, target in ipairs(binding.secondaryTargets) do
			table.insert(actions, ConstructAction(binding, target))
		end
	end

	return actions
end

local function SortActions(left, right)
	if #left.combat > 0 and #right.combat == 0 then
		return true
	end

	if #left.combat == 0 and #right.combat > 0 then
		return false
	end

	if #left.stance > 0 and #right.stance == 0 then
		return true
	end

	if #left.stance == 0 and #right.stance > 0 then
		return false
	end

	if left.unit ~= nil and right.unit == nil then
		return true
	end

	if left.unit == nil and right.unit ~= nil then
		return false
	end

	if left.unit == Clicked.TargetUnits.MOUSEOVER and right.unit ~= Clicked.TargetUnits.MOUSEOVER then
		return true
	end

	if left.unit ~= Clicked.TargetUnits.MOUSEOVER and right.unit == Clicked.TargetUnits.MOUSEOVER then
		return false
	end

	if left.unit == Clicked.TargetUnits.PLAYER and right.unit ~= Clicked.TargetUnits.PLAYER then
		return false
	end

	if left.unit ~= Clicked.TargetUnits.PLAYER and right.unit == Clicked.TargetUnits.PLAYER then
		return true
	end

	if left.hostility ~= nil and right.hostility == nil then
		return true
	end

	if left.hostility == nil and right.hostility ~= nil then
		return false
	end

	if left.hostility ~= Clicked.TargetHostility.ANY and right.hostility == Clicked.TargetHostility.ANY then
		return true
	end

	if left.hostility == Clicked.TargetHostility.ANY and right.hostility ~= Clicked.TargetHostility.ANY then
		return false
	end

	return false
end

-- Construct a valid macro that correctly prioritizes all specified bindings.
-- It will prioritize bindings in the following order:
--
-- 1. All custom macros
-- 2. All @mouseover bindings with the help or harm tag and a combat/nocombat flag
-- 3. All remaining @mouseover bindings with a combat/nocombat flag
-- 4. Any remaining bindings with the help or harm tag and a combat/nocombat flag
-- 5. Any remaining bindings with the combat/nocombat
-- 6. All @mouseover bindings with the help or harm tag
-- 7. All remaining @mouseover bindings
-- 8. Any remaining bindings with the help or harm tag
-- 9. Any remaining bindings
--
-- In text, this boils down to: combat -> mouseover -> hostility -> default
--
-- It will construct an /use command that is mix-and-matched from all configured
-- bindings, so if there are two bindings, and one of them has Holy Light with the
-- [@mouseover,help] and [@target] target priority order, and the other one has
-- Crusader Strike with [@target,harm], it will create a command like this:
-- /use [@mouseover,help] Holy Light; [@target,harm] Crusader Strike; [@target] Holy Light
local function GetMacroForBindings(bindings)
	local result = {}
	local stopcasting = false

	local actions = {}

	for _, binding in ipairs(bindings) do
		if binding.type == Clicked.BindingTypes.MACRO then
			if binding.action.macroMode == Clicked.MacroMode.FIRST then
				table.insert(result, binding.action.macroText)
			end
		else
			if not stopcasting and (binding.type == Clicked.BindingTypes.SPELL or binding.type == Clicked.BindingTypes.ITEM) and binding.action.stopCasting then
				stopcasting = true
				table.insert(result, 1, "/stopcasting")
			end

			for _, action in ipairs(ConstructActions(binding)) do
				table.insert(actions, action)
			end
		end
	end


	-- add a segment to remove the blue casting cursor
	table.insert(result, "/click " .. Clicked.STOP_CASTING_BUTTON_NAME)

	-- Now sort the actions according to the above schema

	table.sort(actions, SortActions)

	-- Construct a valid macro from the data

	local segments = {}

	for _, action in ipairs(actions) do
		local flags = GetMacroSegmentFromAction(action)

		if #flags > 0 then
			flags = "[" .. flags .. "] "
		end

		table.insert(segments, flags .. action.ability)
	end

	if #segments > 0 then
		local command = "/use " .. table.concat(segments, "; ")

		for _, binding in ipairs(bindings) do
			if binding.type == Clicked.BindingTypes.MACRO and binding.action.macroMode == Clicked.MacroMode.APPEND then
				command = command .. "; " .. binding.action.macroText
			end
		end

		table.insert(result, command)
	end

	for _, binding in ipairs(bindings) do
		if binding.type == Clicked.BindingTypes.MACRO and binding.action.macroMode == Clicked.MacroMode.LAST then
			table.insert(result, binding.action.macroText)
		end
	end

	return table.concat(result, "\n")
end

-- Note: This is a secure function and may not be called during combat
local function ProcessActiveBindings()
	if InCombatLockdown() then
		return
	end

	local commands = {}

	local function Process(keybind, bucket, hovercast)
		if #bucket == 0 then
			return nil
		end

		local reference = bucket[1]

		local valid = false
		local command = {
			keybind = keybind,
			hovercast = hovercast
		}

		if reference.type == Clicked.BindingTypes.SPELL or reference.type == Clicked.BindingTypes.ITEM or reference.type == Clicked.BindingTypes.MACRO then
			command.action = Clicked.CommandType.MACRO
			command.data = GetMacroForBindings(bucket)
			valid = command.data ~= nil and command.data ~= ""
		elseif reference.type == Clicked.BindingTypes.UNIT_SELECT then
			command.action = Clicked.CommandType.TARGET
			valid = true
		elseif reference.type == Clicked.BindingTypes.UNIT_MENU then
			command.action = Clicked.CommandType.MENU
			valid = true
		else
			error("Unhandled binding type: " .. reference.type)
		end

		if valid then
			table.insert(commands, command)
		end
	end

	for keybind, bindings in Clicked:IterateActiveBindings() do
		Process(keybind, bindings.hovercast, true)
		Process(keybind, bindings.regular, false)
	end

	Clicked:SendMessage(Clicked.EVENT_BINDING_PROCESSOR_COMPLETE, commands)
	Clicked:ProcessCommands(commands)
end

local function FilterBindings(activatable)
	local function ConvertType(binding)
		if binding.type == Clicked.BindingTypes.SPELL then
			return Clicked.BindingTypes.MACRO
		end

		if binding.type == Clicked.BindingTypes.ITEM then
			return Clicked.BindingTypes.MACRO
		end

		return binding.type
	end

	local result = {}

	for keybind, bindings in pairs(activatable) do
		result[keybind] = {
			hovercast = {},
			regular = {}
		}

		for _, binding in ipairs(bindings) do
			local bucket

			if binding.type == Clicked.BindingTypes.UNIT_SELECT then
				bucket = result[keybind].hovercast
			elseif binding.type == Clicked.BindingTypes.UNIT_MENU then
				bucket = result[keybind].hovercast
			elseif Clicked:IsRestrictedKeybind(keybind) then
				bucket = result[keybind].hovercast
			elseif binding.primaryTarget.unit == Clicked.TargetUnits.HOVERCAST then
				bucket = result[keybind].hovercast
			else
				bucket = result[keybind].regular
			end

			if #bucket == 0 then
				table.insert(bucket, binding)
			else
				local reference = bucket[1]

				if ConvertType(binding) == ConvertType(reference) then
					table.insert(bucket, binding)
				end
			end
		end
	end

	return result
end

function Clicked:CreateNewBinding()
	local binding = self:GetNewBindingTemplate()

	table.insert(configuredBindings, binding)
	self:ReloadActiveBindings()

	return binding
end

function Clicked:DeleteBinding(binding)
	for index, other in ipairs(configuredBindings) do
		if other == binding then
			table.remove(configuredBindings, index)
			self:ReloadActiveBindings()
			break
		end
	end
end

function Clicked:SetBindingAt(index, binding)
	configuredBindings[index] = binding
	self:ReloadActiveBindings()
end

-- Reloads the active bindings, this will go through all configured bindings
-- and check their (current) validity using the CanBindingLoad function.
-- If there are multiple bindings that use the same keybind it will use the
-- PrioritizeBindings function to sort them.
--
-- Note: This is a secure function and may not be called during combat
function Clicked:ReloadActiveBindings()
	if InCombatLockdown() then
		return false
	end

	activeBindings = {}
	configuredBindings = self.db.profile.bindings

	local activatable = {}

	for _, binding in self:IterateConfiguredBindings() do
		if self:CanBindingLoad(binding) then
			activatable[binding.keybind] = activatable[binding.keybind] or {}
			table.insert(activatable[binding.keybind], binding)
		end
	end

	activeBindings = FilterBindings(activatable)
	ProcessActiveBindings()

	self:SendMessage(self.EVENT_BINDINGS_CHANGED)
end

function Clicked:GetNumConfiguredBindings()
	return #configuredBindings
end

function Clicked:IterateConfiguredBindings()
	return ipairs(configuredBindings)
end

function Clicked:GetNumActiveBindings()
	return #activeBindings
end

function Clicked:IterateActiveBindings()
	return pairs(activeBindings)
end

function Clicked:IsBindingActive(binding)
	local result = false

	if activeBindings[binding.keybind] ~= nil then
		local bindings = activeBindings[binding.keybind]

		for _, other in ipairs(bindings.regular) do
			if other == binding then
				result = true
				break
			end
		end

		for _, other in ipairs(bindings.hovercast) do
			if other == binding then
				result = true
				break
			end
		end
	end

	-- Stances are a bit unique as a load option as they don't actually
	-- unload the binding, which may be confusing listed as "loaded" in the
	-- configuration UI whilst the player is not in the specified stance.
	-- This will ensure that the UI dynamically updates based on the current
	-- stance.

	do
		local load = binding.load
		local stance = load.stance

		if stance.selected == 1 then
			local id = stance.single - 1

			if id == 0 then
				for i = 1, GetNumShapeshiftForms() do
					local _, active = GetShapeshiftFormInfo(i)

					if active then
						result = false
					end
				end
			else
				local _, active = GetShapeshiftFormInfo(id)

				if not active then
					result = false
				end
			end
		elseif stance.selected == 2 then
			local anyValid = false

			for i = 1, #stance.multiple do
				local id = stance.multiple[i] - 1

				if id == 0 then
					local isInStance = false

					for j = 1, GetNumShapeshiftForms() do
						local _, active = GetShapeshiftFormInfo(j)

						if active then
							isInStance = true
						end
					end

					if not isInStance then
						anyValid = true
					end
				else
					local _, _, active = GetShapeshiftFormInfo(id)

					if not active then
						anyValid = true
						break
					end
				end
			end

			if not anyValid then
				result = false
			end
		end
	end

	return result
end

-- Check if the specified binding is currently active based on the configuration
-- provided in the binding's Load Options, and whether the binding is actually
-- valid (it has a keybind and an action to perform)
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

	local action = binding.action

	if binding.type == Clicked.BindingTypes.SPELL and action.spell == "" then
		return false
	end

	if binding.type == Clicked.BindingTypes.MACRO and action.macroText == "" then
		return false
	end

	if binding.type == Clicked.BindingTypes.ITEM and action.item == "" then
		return false
	end

	local load = binding.load

	do
		-- If the "never load" toggle has been enabled, there's no point in checking other
		-- values.

		if load.never then
			return false
		end
	end

	if not self:IsClassic() then
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

	do
		-- If the combat limiter has been enabled, see if the player's current combat state
		-- matches the specified value.
		--
		-- Note: This works because the OnEnteringCombat event seems to happen _just_ before
		-- the InCombatLockdown() status changes.

		local combat = load.combat

		if combat.selected then
			if combat.value == Clicked.CombatState.IN_COMBAT and not self:IsPlayerInCombat() then
				return false
			elseif combat.value == Clicked.CombatState.NOT_IN_COMBAT and self:IsPlayerInCombat() then
				return false
			end
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
