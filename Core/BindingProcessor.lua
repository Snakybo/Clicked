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
	HOVERCAST = "HOVERCAST",
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

Clicked.Classes = {
	WARRIOR = "WARRIOR",
	PALADIN = "PALADIN",
	HUNTER = "HUNTER",
	ROGUE = "ROGUE",
	PRIEST = "PRIEST",
	DEATH_KNIGHT = "DEATHKNIGHT",
	SHAMAN = "SHAMAN",
	MAGE = "MAGE",
	WARLOCK = "WARLOCK",
	MONK = "MONK",
	DRUID = "DRUID",
	DEMON_HUNTER = "DEMONHUNTER"
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
		elseif action.hostility == Clicked.TargetHostility.HARM then
			table.insert(flags, "harm")
		end
	end

	if Clicked:CanUnitBeDead(action.unit) then
		if action.vitals == Clicked.TargetVitals.ALIVE then
			table.insert(flags, "nodead")
		elseif action.vitals == Clicked.TargetVitals.DEAD then
			table.insert(flags, "dead")
		end
	end

	if action.pet == Clicked.PetState.ACTIVE then
		table.insert(flags, "pet")
	elseif action.pet == Clicked.PetState.INACTIVE then
		table.insert(flags, "nopet")
	end

	if Clicked:CanUnitHaveFollowUp(action.unit) then
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
	local data = Clicked:GetActiveBindingAction(binding)

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

	if Clicked:IsRestrictedKeybind(binding.keybind) then
		action.unit = Clicked.TargetUnits.HOVERCAST
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

local function ConstructActions(binding)
	local actions = {}

	-- The primary target is a bit special, it can contain the DEFAULT or HOVERCAST target
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
function Clicked:GetMacroForBindings(bindings)
	local result = {}
	local interruptCurrentCast = false
	local startAutoAttack = false

	local actions = {}

	for _, binding in ipairs(bindings) do
		local data = Clicked:GetActiveBindingAction(binding)

		if binding.type == Clicked.BindingTypes.MACRO then
			if data.mode == Clicked.MacroMode.FIRST then
				table.insert(result, data.value)
			end
		else
			local extra = {}

			if not interruptCurrentCast and data.interruptCurrentCast then
				interruptCurrentCast = true
				table.insert(extra, "/stopcasting")
			end

			if not startAutoAttack then
				local valid = false

				if binding.primaryTarget.unit == Clicked.TargetUnits.TARGET then
					valid = true
				else
					for _, target in ipairs(binding.secondaryTargets) do
						if target.unit == Clicked.TargetUnits.TARGET then
							valid = true
						end
					end
				end

				if valid then
					startAutoAttack = true
					table.insert(extra, "/startattack [@target,harm,exists]")
				end
			end

			for i = #extra, 1, - 1 do
				table.insert(result, 1, extra[i])
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
			local data = Clicked:GetActiveBindingAction(binding)

			if binding.type == Clicked.BindingTypes.MACRO and data.mode == Clicked.MacroMode.APPEND then
				command = command .. "; " .. data.value
			end
		end

		table.insert(result, command)
	end

	for _, binding in ipairs(bindings) do
		local data = Clicked:GetActiveBindingAction(binding)

		if binding.type == Clicked.BindingTypes.MACRO and data.mode == Clicked.MacroMode.APPEND then
			table.insert(result, data.value)
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
			command.data = Clicked:GetMacroForBindings(bucket)
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

	for keybind, buckets in Clicked:IterateActiveBindings() do
		Process(keybind, buckets.hovercast, true)
		Process(keybind, buckets.regular, false)
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

function Clicked:GetBindingAt(index)
	return configuredBindings[index]
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

function Clicked:GetBindingIndex(binding)
	for i, e in ipairs(configuredBindings) do
		if e == binding then
			return i
		end
	end

	return 0
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

	do
		local data = self:GetActiveBindingAction(binding)

		if data ~= nil and data.value ~= nil and #data.value == 0 then
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
			local _, identifier = UnitClass("player")
			return identifier == index
		end

		if not ValidateTriStateLoadOption(load.class, IsClassIndexSelected) then
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

	-- forms
	do
		local function IsFormIndexSelected(index)
			local formIndex = index - 1

			-- 0 is no form/humanoid form and is always known
			if formIndex == 0 then
				return true
			end

			local specId = GetSpecializationInfo(GetSpecialization())
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
