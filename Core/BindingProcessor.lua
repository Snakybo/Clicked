Clicked.TYPE_SPELL = "SPELL"
Clicked.TYPE_ITEM = "ITEM"
Clicked.TYPE_MACRO = "MACRO"
Clicked.TYPE_UNIT_SELECT = "UNIT_SELECT"
Clicked.TYPE_UNIT_MENU = "UNIT_MENU"

Clicked.TARGET_UNIT_PLAYER = "PLAYER"
Clicked.TARGET_UNIT_GLOBAL = "GLOBAL"
Clicked.TARGET_UNIT_TARGET = "TARGET"
Clicked.TARGET_UNIT_PARTY_1 = "PARTY_1"
Clicked.TARGET_UNIT_PARTY_2 = "PARTY_2"
Clicked.TARGET_UNIT_PARTY_3 = "PARTY_3"
Clicked.TARGET_UNIT_PARTY_4 = "PARTY_4"
Clicked.TARGET_UNIT_PARTY_5 = "PARTY_5"
Clicked.TARGET_UNIT_FOCUS = "FOCUS"
Clicked.TARGET_UNIT_MOUSEOVER = "MOUSEOVER"
Clicked.TARGET_UNIT_HOVERCAST = "HOVERCAST"
Clicked.TARGET_UNIT_CURSOR = "CURSOR"

Clicked.MACRO_MODE_FIRST = "FIRST"
Clicked.MACRO_MODE_APPEND = "APPEND"
Clicked.MACRO_MODE_LAST = "LAST"

Clicked.TARGET_HOSTILITY_ANY = "ANY"
Clicked.TARGET_HOSTILITY_HELP = "HELP"
Clicked.TARGET_HOSTILITY_HARM = "HARM"

Clicked.LOAD_IN_COMBAT_TRUE = "IN_COMBAT"
Clicked.LOAD_IN_COMBAT_FALSE = "NOT_IN_COMBAT"

Clicked.LOAD_IN_GROUP_PARTY_OR_RAID = "IN_GROUP_PARTY_OR_RAID"
Clicked.LOAD_IN_GROUP_PARTY = "IN_GROUP_PARTY"
Clicked.LOAD_IN_GROUP_RAID = "IN_GROUP_RAID"
Clicked.LOAD_IN_GROUP_SOLO = "IN_GROUP_SOLO"

Clicked.EVENT_BINDINGS_CHANGED = "CLICKED_BINDINGS_CHANGED"

--@alpha@
Clicked.EVENT_BINDING_PROCESSOR_COMPLETE = "CLICKED_BINDING_PROCESSOR_COMPLETE"
--@end-alpha@

local configuredBindings = {}
local activeBindings = {}

local function GetMacroSegmentFromAction(action)
	local flags = {}

	if action.unit == Clicked.TARGET_UNIT_PLAYER then
		table.insert(flags, "@player")
	elseif action.unit == Clicked.TARGET_UNIT_TARGET then
		table.insert(flags, "@target")
	elseif action.unit == Clicked.TARGET_UNIT_MOUSEOVER or action.unit == Clicked.TARGET_UNIT_HOVERCAST then
		table.insert(flags, "@mouseover")
	elseif action.unit == Clicked.TARGET_UNIT_PARTY_1 then
		table.insert(flags, "@party1")
	elseif action.unit == Clicked.TARGET_UNIT_PARTY_2 then
		table.insert(flags, "@party2")
	elseif action.unit == Clicked.TARGET_UNIT_PARTY_3 then
		table.insert(flags, "@party3")
	elseif action.unit == Clicked.TARGET_UNIT_PARTY_4 then
		table.insert(flags, "@party4")
	elseif action.unit == Clicked.TARGET_UNIT_PARTY_5 then
		table.insert(flags, "@party5")
	elseif action.unit == Clicked.TARGET_UNIT_FOCUS then
		table.insert(flags, "@focus")
	elseif action.unit == Clicked.TARGET_UNIT_CURSOR then
		table.insert(flags, "@cursor")
	end

	if Clicked:CanUnitBeHostile(action.unit) then
		if action.hostility == Clicked.TARGET_HOSTILITY_HELP then
			table.insert(flags, "help")
		elseif action.hostility == Clicked.TARGET_HOSTILITY_HARM then
			table.insert(flags, "harm")
		end
	end

	if Clicked:CanUnitHaveFollowUp(action.unit) then
		table.insert(flags, "exists")
	end

	if action.combat == Clicked.LOAD_IN_COMBAT_TRUE then
		table.insert(flags, "combat")
	elseif action.combat == Clicked.LOAD_IN_COMBAT_FALSE then
		table.insert(flags, "nocombat")
	end

	if #action.stance > 0 then
		table.insert(flags, "stance:" .. action.stance)
	end

	return table.concat(flags, ",")
end

local function ConstructAction(binding, target)
	local action = {}

	if binding.type == Clicked.TYPE_SPELL then
		action.ability = binding.action.spell
	elseif binding.type == Clicked.TYPE_ITEM then
		action.ability = binding.action.item
	end

	do
		local combat = binding.load.combat

		if combat.selected then
			action.combat = combat.state
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
		action.unit = Clicked.TARGET_UNIT_HOVERCAST
	else
		action.unit = target.unit
	end

	action.hostility = target.hostility

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

	if left.unit == Clicked.TARGET_UNIT_MOUSEOVER and right.unit ~= Clicked.TARGET_UNIT_MOUSEOVER then
		return true
	end

	if left.unit ~= Clicked.TARGET_UNIT_MOUSEOVER and right.unit == Clicked.TARGET_UNIT_MOUSEOVER then
		return false
	end

	if left.unit == Clicked.TARGET_UNIT_PLAYER and right.unit ~= Clicked.TARGET_UNIT_PLAYER then
		return false
	end

	if left.unit ~= Clicked.TARGET_UNIT_PLAYER and right.unit == Clicked.TARGET_UNIT_PLAYER then
		return true
	end

	if left.hostility ~= nil and right.hostility == nil then
		return true
	end

	if left.hostility == nil and right.hostility ~= nil then
		return false
	end

	if left.hostility ~= Clicked.TARGET_HOSTILITY_ANY and right.hostility == Clicked.TARGET_HOSTILITY_ANY then
		return true
	end

	if left.hostility == Clicked.TARGET_HOSTILITY_ANY and right.hostility ~= Clicked.TARGET_HOSTILITY_ANY then
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
		if binding.type == Clicked.TYPE_MACRO then
			if binding.action.macroMode == Clicked.MACRO_MODE_FIRST then
				table.insert(result, binding.action.macrotext)
			end
		else
			if not stopcasting and (binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM) and binding.action.stopcasting then
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
			if binding.type == Clicked.TYPE_MACRO and binding.action.macroMode == Clicked.MACRO_MODE_APPEND then
				command = command .. "; " .. binding.action.macrotext
			end
		end

		table.insert(result, command)
	end

	for _, binding in ipairs(bindings) do
		if binding.type == Clicked.TYPE_MACRO and binding.action.macroMode == Clicked.MACRO_MODE_LAST then
			table.insert(result, binding.action.macrotext)
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

		if reference.type == Clicked.TYPE_SPELL or reference.type == Clicked.TYPE_ITEM or reference.type == Clicked.TYPE_MACRO then
			command.action = Clicked.COMMAND_ACTION_MACRO
			command.data = GetMacroForBindings(bucket)
			valid = command.data ~= nil and command.data ~= ""
		elseif reference.type == Clicked.TYPE_UNIT_SELECT then
			command.action = Clicked.COMMAND_ACTION_TARGET
			valid = true
		elseif reference.type == Clicked.TYPE_UNIT_MENU then
			command.action = Clicked.COMMAND_ACTION_MENU
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

	--@alpha@
	Clicked:SendMessage(Clicked.EVENT_BINDING_PROCESSOR_COMPLETE, commands)
	--@end-alpha@

	Clicked:ProcessCommands(commands)
end

local function FilterBindings(activatable)
	local function ConvertType(binding)
		if binding.type == Clicked.TYPE_SPELL then
			return Clicked.TYPE_MACRO
		end

		if binding.type == Clicked.TYPE_ITEM then
			return Clicked.TYPE_MACRO
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

			if binding.type == Clicked.TYPE_UNIT_SELECT then
				bucket = result[keybind].hovercast
			elseif binding.type == Clicked.TYPE_UNIT_MENU then
				bucket = result[keybind].hovercast
			elseif Clicked:IsRestrictedKeybind(keybind) then
				bucket = result[keybind].hovercast
			elseif binding.primaryTarget.unit == Clicked.TARGET_UNIT_HOVERCAST then
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
	if binding.keybind == "" then
		return false
	end

	local action = binding.action

	if binding.type == self.TYPE_SPELL and action.spell == "" then
		return false
	end

	if binding.type == self.TYPE_MACRO and action.macrotext == "" then
		return false
	end

	if binding.type == self.TYPE_ITEM and action.item == "" then
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

	if self.WOW_MAINLINE_RELEASE then
		do
			-- If the specialization limiter has been enabled, see if the player's current
			-- specialization matches one of the specified specializations.

			local specialization = load.specialization

			if specialization.selected == 1 then
				if specialization.single ~= GetSpecialization() then
					return false
				end
			elseif specialization.selected == 2 then
				local spec = GetSpecialization()
				local contains = false

				for i = 1, #specialization.multiple do
					if specialization.multiple[i] == spec then
						contains = true
					end
				end

				if not contains then
					return false
				end
			end
		end

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

			local talent = load.talent

			if talent.selected == 1 then
				if not IsTalentIndexSelected(talent.single) then
					return false
				end
			elseif talent.selected == 2 then
				local hasAny = false

				for i = 1, #talent.multiple do
					if IsTalentIndexSelected(talent.multiple[i]) then
						hasAny = true
						break
					end
				end

				if not hasAny then
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
			if combat.state == self.LOAD_IN_COMBAT_TRUE and not self:IsPlayerInCombat() then
				return false
			elseif combat.state == self.LOAD_IN_COMBAT_FALSE and self:IsPlayerInCombat() then
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
			local name = GetSpellInfo(spellKnown.spell)

			if name == nil then
				return false
			end
		end
	end

	do
		local inGroup = load.inGroup

		if inGroup.selected then
			if inGroup.state == self.LOAD_IN_GROUP_SOLO and GetNumGroupMembers() > 0 then
				return false
			else
				if inGroup.state == self.LOAD_IN_GROUP_PARTY_OR_RAID and GetNumGroupMembers() == 0 then
					return false
				elseif inGroup.state == self.LOAD_IN_GROUP_PARTY and (GetNumSubgroupMembers() == 0 or IsInRaid()) then
					return false
				elseif inGroup.state == self.LOAD_IN_GROUP_RAID and not IsInRaid() then
					return false
				end
			end
		end
	end

	do
		local playerInGroup = load.playerInGroup

		if playerInGroup.selected then
			local found = false

			if playerInGroup.player == UnitName("player") then
				found = true
			else
				local unit = IsInRaid() and "raid" or "party"
				local numGroupMembers = GetNumGroupMembers()

				if numGroupMembers == 0 then
					return false
				end

				for i = 1, numGroupMembers do
					local name = UnitName(unit .. i)

					if name == playerInGroup.player then
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
