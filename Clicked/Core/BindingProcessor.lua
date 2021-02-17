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
	ARENA_1 = "ARENA_1",
	ARENA_2 = "ARENA_2",
	ARENA_3 = "ARENA_3",
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

local activeBindings = {}

local hovercastBucket = {}
local regularBucket = {}

local isPendingReload = false

local function GetMacroSegmentFromAction(action, interactionType, isLast)
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
	elseif action.unit == Clicked.TargetUnits.ARENA_1 then
		table.insert(flags, "@arena1")
	elseif action.unit == Clicked.TargetUnits.ARENA_2 then
		table.insert(flags, "@arena2")
	elseif action.unit == Clicked.TargetUnits.ARENA_3 then
		table.insert(flags, "@arena3")
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
		elseif action.vitals == Clicked.TargetVitals.DEAD then
			table.insert(flags, "dead")
			impliedExists = true
		end
	end

	if action.pet == Clicked.PetState.ACTIVE then
		table.insert(flags, "pet")
		impliedExists = true
	elseif action.pet == Clicked.PetState.INACTIVE then
		table.insert(flags, "nopet")
	end

	if not impliedExists and interactionType == Clicked.InteractionType.REGULAR and not isLast then
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
	local action = {
		ability = Clicked:GetActiveBindingValue(binding)
	}

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

		if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
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
		end
	end

	return actions
end

local function SortActions(actions, indexMap)
	local function SortFunc(left, right)
		local priority = {
			-- 1. Mouseover targets always come first
			{ left = left.unit, right = right.unit, value = Clicked.TargetUnits.MOUSEOVER, comparison = "eq" },

			-- 2. Hostility, vitals, combat, and form flags take presedence over actions
			--    that don't specify them explicitly
			{ left = #left.hostility, right = #right.hostility, value = 0, comparison = "gt" },
			{ left = #left.vitals, right = #right.vitals, value = 0, comparison = "gt" },
			{ left = #left.combat, right = #right.combat, value = 0, comparison = "gt" },
			{ left = #left.forms, right = #right.forms, value = 0, comparison = "gt" },

			-- 3. Any actions that do not meet any of the criteria in this list will be placed here

			-- 4. The player, cursor, and default targets will always come last
			{ left = left.unit, right = right.unit, value = Clicked.TargetUnits.PLAYER, comparison = "neq" },
			{ left = left.unit, right = right.unit, value = Clicked.TargetUnits.CURSOR, comparison = "neq" },
			{ left = left.unit, right = right.unit, value = Clicked.TargetUnits.DEFAULT, comparison = "neq" }
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

local function GetInternalBindingType(binding)
	if binding.type == Clicked.BindingTypes.SPELL then
		return Clicked.BindingTypes.MACRO
	end

	if binding.type == Clicked.BindingTypes.ITEM then
		return Clicked.BindingTypes.MACRO
	end

	return binding.type
end

local function ProcessBuckets()
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
			command.data = Clicked:GetMacroForBindings(bindings, interactionType)
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

	for keybind, bindings in pairs(hovercastBucket) do
		local command = Process(keybind, bindings, Clicked.InteractionType.HOVERCAST)
		table.insert(commands, command)
	end

	for keybind, bindings in pairs(regularBucket) do
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

	table.wipe(hovercastBucket)
	table.wipe(regularBucket)

	for _, binding in ipairs(bindings) do
		local key = binding.keybind

		if binding.targets.hovercast.enabled then
			hovercastBucket[key] = hovercastBucket[key] or {}
			Insert(hovercastBucket[key], binding)
		end

		if binding.targets.regular.enabled then
			regularBucket[key] = regularBucket[key] or {}
			Insert(regularBucket[key], binding)
		end
	end
end

local function IsHovercastSpellOrItemValidOnUnit(binding, target, isInCombat, isFriend, isDead)
	if not binding.targets.hovercast.enabled then
		return false
	end

	if binding.type ~= Clicked.BindingTypes.SPELL and binding.type ~= Clicked.BindingTypes.ITEM then
		return false
	end

	local spell = Clicked:GetActiveBindingValue(binding)

	do
		local combat = binding.load.combat

		if combat.selected then
			if combat.value == Clicked.CombatState.IN_COMBAT and not isInCombat or
			   combat.value == Clicked.CombatState.NOT_IN_COMBAT and isInCombat then
				return false
			end
		end
	end

	do
		local hovercast = binding.targets.hovercast

		if hovercast.hostility == Clicked.TargetHostility.HELP and not isFriend or
		   hovercast.hostility == Clicked.TargetHostility.HARM and isFriend then
			return false
		end

		if hovercast.vitals == Clicked.TargetVitals.DEAD and not isDead or
		   hovercast.vitals == Clicked.TargetVitals.ALIVE and isDead then
			return false
		end
	end

	return true
end

--- Reloads the active bindings, this will go through all configured bindings
--- and check their (current) validity using the CanBindingLoad function.
--- If there are multiple bindings that use the same keybind it will use the
--- PrioritizeBindings function to sort them.
function Clicked:ReloadActiveBindings()
	if InCombatLockdown() then
		isPendingReload = true
		return
	end

	table.wipe(activeBindings)

	for _, binding in self:IterateConfiguredBindings() do
		if self:CanBindingLoad(binding) then
			table.insert(activeBindings, binding)
		end
	end

	GenerateBuckets(activeBindings)
	ProcessBuckets()

	self:SendMessage(self.EVENT_BINDINGS_CHANGED)
end

--- Reload the active bindings if required. This will mainly be the case if `ReloadActiveBindings`
--- was called during combat or some other scenario in which it was not currently allowed to reload.
---
--- @see ReloadActiveBindings
function Clicked:ReloadActiveBindingsIfPending()
	if not isPendingReload then
		return
	end

	isPendingReload = false
	self:ReloadActiveBindings()
end

--- Create an interator for the currently active bindings for use in a `for in` loop.
function Clicked:IterateActiveBindings()
	return ipairs(activeBindings)
end

--- Get all active hovercast bindings that are currently valid for the specified unit.
--- A binding is considered valid if the state of the unit meets the target and load conditions
--- specified in the binding, for example: the `combat`/`nocombat` option, `help`/`harm` option,
--- or `dead`/`nodead` option.
---
---@param unit string
---@return table
function Clicked:GetHovercastBindingsForUnit(unit)
	local result = {}

	local isInCombat = Clicked.IsPlayerInCombat()
	local isFriend = UnitIsFriend("player", unit)
	local isDead = UnitIsDeadOrGhost(unit)

	for _, binding in self:IterateActiveBindings() do
		if IsHovercastSpellOrItemValidOnUnit(binding, unit, isInCombat, isFriend, isDead) then
			table.insert(result, binding)
		end
	end

	return result
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
		local value = self:GetActiveBindingValue(binding)

		if value ~= nil and #value == 0 then
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
				if warMode.value == Clicked.WarModeState.IN_WAR_MODE and not C_PvP.IsWarModeDesired() then
					return false
				elseif warMode.value == Clicked.WarModeState.NOT_IN_WAR_MODE and C_PvP.IsWarModeDesired() then
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

			local forms = self:GetShapeshiftFormsForSpecId(specId)
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
			local name = GetSpellInfo(spellKnown.value)

			if name == nil then
				return false
			end
		end
	end

	-- in group
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
	local interrupt = false
	local startAutoAttack = false
	local cancelQueuedSpell = false
	local targetUnitAfterCast = false

	local actions = {}
	local actionIndexMap = {}

	-- add a segment to remove the blue casting cursor
	table.insert(result, "/click " .. Clicked.STOP_CASTING_BUTTON_NAME)

	for _, binding in ipairs(bindings) do
		local value = Clicked:GetActiveBindingValue(binding)

		if binding.type == Clicked.BindingTypes.MACRO then
			if binding.action.macroMode == Clicked.MacroMode.FIRST then
				table.insert(result, value)
			end
		else
			local extra = {}

			if not interrupt and binding.action.interrupt then
				interrupt = true
				table.insert(extra, "/stopcasting")
			end

			if not startAutoAttack and binding.action.allowStartAttack and interactionType == Clicked.InteractionType.REGULAR then
				for _, target in ipairs(binding.targets.regular) do
					if target.unit == Clicked.TargetUnits.TARGET and target.hostility ~= Clicked.TargetHostility.HELP then
						startAutoAttack = true
						table.insert(extra, "/startattack [@target,harm]")
						break
					end
				end
			end

			if not cancelQueuedSpell and binding.action.cancelQueuedSpell then
				cancelQueuedSpell = true
				table.insert(extra, "/cancelqueuedspell")
			end

			for i = #extra, 1, - 1 do
				table.insert(result, 1, extra[i])
			end

			local next = 1

			for _, action in ipairs(ConstructActions(binding, interactionType)) do
				table.insert(actions, action)

				actionIndexMap[action] = next
				next = next + 1
			end
		end
	end

	-- Now sort the actions according to the above schema

	SortActions(actions, actionIndexMap)

	-- Construct a valid macro from the data

	local allFlags = {}
	local segments = {}

	for i, action in ipairs(actions) do
		local flags = GetMacroSegmentFromAction(action, interactionType, i == #actions)

		if #flags > 0 then
			flags = "[" .. flags .. "] "
		end

		table.insert(allFlags, flags)
		table.insert(segments, flags .. action.ability)
	end

	if #segments > 0 then
		local command = "/use " .. table.concat(segments, "; ")

		for _, binding in ipairs(bindings) do
			local value = Clicked:GetActiveBindingValue(binding)

			if binding.type == Clicked.BindingTypes.MACRO and binding.action.macroMode == Clicked.MacroMode.APPEND then
				command = command .. "; " .. value
			end
		end

		table.insert(result, command)
	end

	for _, binding in ipairs(bindings) do
		local value = Clicked:GetActiveBindingValue(binding)

		if not targetUnitAfterCast and binding.action.targetUnitAfterCast then
			targetUnitAfterCast = true
			table.insert(result, "/tar " .. table.concat(allFlags, ""))
		end

		if binding.type == Clicked.BindingTypes.MACRO and binding.action.macroMode == Clicked.MacroMode.LAST then
			table.insert(result, value)
		end
	end

	return table.concat(result, "\n")
end
