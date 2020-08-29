Clicked.TYPE_SPELL = "SPELL"
Clicked.TYPE_ITEM = "ITEM"
Clicked.TYPE_MACRO = "MACRO"
Clicked.TYPE_UNIT_SELECT = "UNIT_SELECT"
Clicked.TYPE_UNIT_MENU = "UNIT_MENU"

Clicked.TARGET_UNIT_GLOBAL = "GLOBAL"
Clicked.TARGET_UNIT_PLAYER = "PLAYER"
Clicked.TARGET_UNIT_TARGET = "TARGET"
Clicked.TARGET_UNIT_PARTY_1 = "PARTY_1"
Clicked.TARGET_UNIT_PARTY_2 = "PARTY_2"
Clicked.TARGET_UNIT_PARTY_3 = "PARTY_3"
Clicked.TARGET_UNIT_PARTY_4 = "PARTY_4"
Clicked.TARGET_UNIT_PARTY_5 = "PARTY_5"
Clicked.TARGET_UNIT_FOCUS = "FOCUS"
Clicked.TARGET_UNIT_MOUSEOVER = "MOUSEOVER"
Clicked.TARGET_UNIT_MOUSEOVER_FRAME = "MOUSEOVER_FRAME"	-- not yet implemented

Clicked.TARGET_TYPE_ANY = "ANY"
Clicked.TARGET_TYPE_HELP = "HELP"
Clicked.TARGET_TYPE_HARM = "HARM"

Clicked.COMBAT_STATE_TRUE = "IN_COMBAT"
Clicked.COMBAT_STATE_FALSE = "NOT_IN_COMBAT"

Clicked.EVENT_BINDINGS_CHANGED = "CLICKED_BINDINGS_CHANGED"

local configuredBindings = {}
local activeBindings = {}

local function GetMacroSegmentFromAction(action)
	local flags = {}

	if action.unit == Clicked.TARGET_UNIT_PLAYER then
		table.insert(flags, "@player")
	elseif action.unit == Clicked.TARGET_UNIT_TARGET then
		table.insert(flags, "@target")
	elseif action.unit == Clicked.TARGET_UNIT_MOUSEOVER then
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
	end

	if Clicked:CanBindingTargetUnitBeHostile(action.unit) then
		if action.type == Clicked.TARGET_TYPE_HELP then
			table.insert(flags, "help")
		elseif action.type == Clicked.TARGET_TYPE_HARM then
			table.insert(flags, "harm")
		end
	end

	if #flags > 0 then
		table.insert(flags, "exists")
	end

	if action.combat == Clicked.COMBAT_STATE_TRUE then
		table.insert(flags, "combat")
	elseif action.combat == Clicked.COMBAT_STATE_FALSE then
		table.insert(flags, "nocombat")
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

	if binding.load.combat.selected then
		action.combat = binding.load.combat.state
	else
		action.combat = ""
	end

	action.unit = target.unit
	action.type = target.type

	return action
end

local function ConstructActions(binding)
	local actions = {}

	if binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM then
		if not Clicked:IsRestrictedKeybind(binding.keybind) then
			for _, target in ipairs(binding.targets) do
				local action = ConstructAction(binding, target)
				table.insert(actions, action)
			end
		else
			local action = ConstructAction(binding, {
				unit = Clicked.TARGET_UNIT_MOUSEOVER,
				type = Clicked.TARGET_TYPE_ANY
			})
			table.insert(actions, action)
		end
	end

	return actions
end

local function SortActions(left, right)
	if #left.combat > 0 and #right.combat == 0 then
		return true
	end

	if #left.combat == 0 and #right.combat > 0 then
		return true
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

	if left.type ~= Clicked.TARGET_TYPE_ANY and right == Clicked.TARGET_TYPE_ANY then
		return true
	end

	if left.type == Clicked.TARGET_TYPE_ANY and right ~= Clicked.TARGET_TYPE_ANY then
		return false
	end

	return false
end

local function GetMacroForBindings(bindings)
	local result = {}
	local stopCasting = false

	-- First go through all passed bindings and insert any custom macros
	-- or /stopcasting prefixes if required, custom macros will always
	-- have presendence over spells or items, so when mixing and matching
	-- macro bindings with the other types will require some attention from
	-- the user in order to not early-out as soon as the macro is executed,
	-- mainly the macro shouldn't end with a [] clause as that will always be
	-- activated.

	for _, binding in ipairs(bindings) do
		if binding.type == Clicked.TYPE_MACRO then
			table.insert(result, binding.action.macro)
		elseif binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM then
			if not stopCasting and binding.action.stopCasting then
				stopCasting = true
				table.insert(result, 1, "/stopcasting")
			end
		end
	end

	-- Construct an /use command that correctly prioritizes all specified bindings.
	-- It will prioritize bindings in the following order:
	--
	-- 1. all @mouseover bindings with the help or harm tag and a combat/nocombat flag
	-- 2. all remaining @mouseover bindings with a combat/nocombat flag
	-- 3. any remaining bindings with the help or harm tag and a combat/nocombat flag
	-- 4. any remaining bindings with the combat/nocombat
	-- 5. all @mouseover bindings with the help or harm tag
	-- 6. all remaining @mouseover bindings
	-- 7. any remaining bindings with the help or harm tag
	-- 8. any remaining bindings
	--
	-- In text, this boils down to: combat -> mouseover -> hostility -> default
	--
	-- It will construct an /use command that is mix-and-matched from all configured
	-- bindings, so if there are two bindings, and one of them has Holy Light with the
	-- [@mouseover,help] and [@target] target priority order, and the other one has
	-- Crusader Strike with [@target,harm], it will create a command like this:
	-- /use [@mouseover,help] Holy Light; [@target,harm] Crusader Strike; [@target] Holy Light

	local actions = {}

	for _, binding in ipairs(bindings) do
		for _, action in ipairs(ConstructActions(binding)) do
			table.insert(actions, action)
		end
	end

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
		local prefix = "/use "
		table.insert(result, prefix .. table.concat(segments, "; "))
	end

	return table.concat(result, "\n")
end

-- Note: This is a secure function and may not be called during combat
local function ProcessActiveBindings()
	if InCombatLockdown() then
		return
	end

	local commands = {}

	for keybind, bindings in Clicked:IterateActiveBindings() do
		local command = {
			keybind = keybind,
			data = GetMacroForBindings(bindings),
			valid = false
		}

		local binding = bindings[1]

		if binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM or binding.type == Clicked.TYPE_MACRO then
			command.action = Clicked.COMMAND_ACTION_MACRO
			command.valid = command.valid or (command.data ~= nil and command.data ~= "")
		elseif binding.type == Clicked.TYPE_UNIT_SELECT then
			command.action = Clicked.COMMAND_ACTION_TARGET
			command.valid = command.valid or true
		elseif binding.type == Clicked.TYPE_UNIT_MENU then
			command.action = Clicked.COMMAND_ACTION_MENU
			command.valid = command.valid or true
		else
			error("Clicked: Unhandled binding type: " .. binding.type)
		end

		if command.valid then
			table.insert(commands, command)
		end
	end

	Clicked:ProcessCommands(commands)
end

local function FilterBindings(bindings)
	local function ConvertType(binding)
		if binding.type == Clicked.TYPE_SPELL then
			return Clicked.TYPE_MACRO
		end

		if binding.type == Clicked.TYPE_ITEM then
			return Clicked.TYPE_MACRO
		end

		return binding.type
	end

	local filtered = {}
	local last = ""

	for _, binding in ipairs(bindings) do
		local type = ConvertType(binding)

		if last == "" or type == last then
			table.insert(filtered, binding)
		end
	end

	return filtered
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

-- Reloads the active bindings, this will go through all configured bindings
-- and check their (current) validity using the IsBindingActive function.
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
		if self:IsBindingActive(binding) then
			activatable[binding.keybind] = activatable[binding.keybind] or {}
			table.insert(activatable[binding.keybind], binding)
		end
	end

	for keybind, bindings in pairs(activatable) do
		local filtered = FilterBindings(bindings)
		activeBindings[keybind] = filtered
	end

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

-- Check if the specified binding is currently active based on the configuration
-- provided in the binding's Load Options, and whether the binding is actually
-- valid (it has a keybind and an action to perform)
function Clicked:IsBindingActive(binding)
	if binding.keybind == "" then
		return false
	end

	local action = binding.action

	if binding.type == self.TYPE_SPELL and action.spell == "" then
		return false
	end

	if binding.type == self.TYPE_MACRO and action.macro == "" then
		return false
	end

	if binding.type == self.TYPE_ITEM and action.item == "" then
		return false
	end

	local load = binding.load

	-- If the "never load" toggle has been enabled, there's no point in checking other
	-- values.

	if load.never then
		return false
	end

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

	-- If the combat limiter has been enabled, see if the player's current combat state
	-- matches the specified value.
	--
	-- Note: This works because the OnEnteringCombat event seems to happen _just_ before
	-- the InCombatLockdown() status changes.

	local combat = load.combat

	if combat.selected then
		if combat.state == self.COMBAT_STATE_TRUE and not self:IsPlayerInCombat() then
			return false
		elseif combat.state == self.COMBAT_STATE_FALSE and self:IsPlayerInCombat() then
			return false
		end
	end

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

	return true
end

function Clicked:GetNewBindingTemplate()
	return {
		type = Clicked.TYPE_SPELL,
		keybind = "",
		action = {
			stopCasting = false,
			spell = "",
			item = "",
			macro = ""
		},
		targets = {
			self:GetNewBindingTargetTemplate()
		},
		load = {
			never = false,
			specialization = {
				selected = 0,
				single = GetSpecialization(),
				multiple = {
					GetSpecialization()
				}
			},
			combat = {
				selected = false,
				state = Clicked.COMBAT_STATE_TRUE
			},
			spellKnown = {
				selected = false,
				spell = ""
			}
		}
	}
end

function Clicked:GetNewBindingTargetTemplate()
	return {
		unit = Clicked.TARGET_UNIT_TARGET,
		type = Clicked.TARGET_TYPE_ANY
	}
end
