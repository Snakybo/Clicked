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

local function AddFlag(flags, new)
    if #flags > 0 then
        flags = flags .. ","
    end

    return flags .. new
end

local function AddMacroFlags(target)
	local flags = ""

	if target.unit == Clicked.TARGET_UNIT_PLAYER then
		flags = AddFlag(flags, "@player")
	elseif target.unit == Clicked.TARGET_UNIT_TARGET then
		flags = AddFlag(flags, "@target")
	elseif target.unit == Clicked.TARGET_UNIT_MOUSEOVER then
		flags = AddFlag(flags, "@mouseover")
	elseif target.unit == Clicked.TARGET_UNIT_PARTY_1 then
		flags = AddFlag(flags, "@party1")
	elseif target.unit == Clicked.TARGET_UNIT_PARTY_2 then
		flags = AddFlag(flags, "@party2")
	elseif target.unit == Clicked.TARGET_UNIT_PARTY_3 then
		flags = AddFlag(flags, "@party3")
	elseif target.unit == Clicked.TARGET_UNIT_PARTY_4 then
		flags = AddFlag(flags, "@party4")
	elseif target.unit == Clicked.TARGET_UNIT_PARTY_5 then
		flags = AddFlag(flags, "@party5")
	elseif target.unit == Clicked.TARGET_UNIT_FOCUS then
		flags = AddFlag(flags, "@focus")
	end

	if Clicked:CanBindingTargetUnitBeHostile(target.unit) then
		if target.type == Clicked.TARGET_TYPE_HELP then
			flags = AddFlag(flags, "help")
		elseif target.type == Clicked.TARGET_TYPE_HARM then
			flags = AddFlag(flags, "harm")
		end
	end

	if #flags > 0 then
		flags = AddFlag(flags, "exists")
	end

	return flags
end

local function GetMacroForBinding(binding)
	-- If the player provieded a custom macro, just return that with some basic
	-- sanity checking to remove empty strings so we don't end up with frames
	-- that aren't functional.
	-- Though this shouldn't ever be the case when using IsBindingActive

	if binding.type == Clicked.TYPE_MACRO then
		return binding.action.macro
	end

	-- If the action is to cast a spell or use an item, we can create a custom
	-- macro on-demand.

	if binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM then
		local macro = ""

		-- Prepend the /stopcasting command if desired

		if binding.action.stopCasting then
			macro = macro .. "/stopcasting\n"
		end

		macro = macro .. "/use "

		-- If the keybinding is not restricted, we can append a bunch of target
		-- and type flags to the macro.

		if not Clicked:IsRestrictedKeybind(binding.keybind) then
			for _, target in ipairs(binding.targets) do
				local flags = AddMacroFlags(target)

				if #flags > 0 then
					macro = macro .. "[" .. flags .. "] "
				end
			end
		else
			macro = macro .. "[@mouseover] "
		end

		-- Append the actual spell or item to use

		if binding.type == Clicked.TYPE_SPELL then
			macro = macro .. binding.action.spell
		elseif binding.type == Clicked.TYPE_ITEM then
			macro = macro .. binding.action.item
		end

		return macro
	end

	return nil
end

-- Note: This is a secure function and may not be called during combat
local function ProcessActiveBindings()
	if InCombatLockdown() then
		return
	end

	local commands = {}

	for _, binding in Clicked:IterateActiveBindings() do
		local command = {
			keybind = binding.keybind,
			valid = false
		}

		if binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM or type == Clicked.TYPE_MACRO then
			command.action = Clicked.COMMAND_ACTION_MACRO
			command.data = GetMacroForBinding(binding)
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

-- Since there can be multiple bindings active with the same keybind, we need to
-- prioritize them at runtime somehow, this function will attempt to order the
-- input list of bindings in a way that makes sense to the user.
--
-- For example, if there is a binding that should only load in combat, it should
-- be prioritzed over generic or out-of-combat only bindings.
local function PrioritizeBindings(bindings)
	if #bindings == 1 then
		return bindings
	end

	local ordered = {}

	for _, binding in ipairs(bindings) do
		local load = binding.load
		local combat = load.combat

		if combat.selected == 1 then
			table.insert(ordered, 1, binding)
		else
			table.insert(ordered, binding)
		end
	end

	return ordered
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

	for _, bindings in pairs(activatable) do
		local sorted = PrioritizeBindings(bindings)
		local binding = sorted[1]

		table.insert(activeBindings, binding)
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
	return ipairs(activeBindings)
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
