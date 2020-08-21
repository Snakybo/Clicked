local DataBroker = LibStub("LibDataBroker-1.1")
local Icon = LibStub("LibDBIcon-1.0")

Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")

Clicked.NAME = "Clicked"
Clicked.VERSION = GetAddOnMetadata(Clicked.NAME, "Version")

Clicked.TYPE_SPELL = "SPELL"
Clicked.TYPE_ITEM = "ITEM"
Clicked.TYPE_MACRO = "MACRO"
Clicked.TYPE_UNIT_SELECT = "UNIT_SELECT"	-- nyi
Clicked.TYPE_UNIT_MENU = "UNIT_MENU"		-- nyi

Clicked.TARGET_UNIT_GLOBAL = "GLOBAL"
Clicked.TARGET_UNIT_PLAYER = "PLAYER"
Clicked.TARGET_UNIT_TARGET = "TARGET"
Clicked.TARGET_UNIT_PARTY_1 = "PARTY_1"
Clicked.TARGET_UNIT_PARTY_2 = "PARTY_2"
Clicked.TARGET_UNIT_PARTY_3 = "PARTY_3"
Clicked.TARGET_UNIT_PARTY_4 = "PARTY_4"
Clicked.TARGET_UNIT_PARTY_5 = "PARTY_5"
Clicked.TARGET_UNIT_MOUSEOVER = "MOUSEOVER"
Clicked.TARGET_UNIT_MOUSEOVER_FRAME = "MOUSEOVER_FRAME"		-- nyi

Clicked.TARGET_TYPE_ANY = "ANY"
Clicked.TARGET_TYPE_HELP = "HELP"
Clicked.TARGET_TYPE_HARM = "HARM"

Clicked.COMBAT_STATE_TRUE = "IN_COMBAT"
Clicked.COMBAT_STATE_FALSE = "NOT_IN_COMBAT"

local handlers = {}
local inCombat = false

function Clicked:OnInitialize()
	local defaultProfile = UnitName("player") .. " - " .. GetRealmName()

	self.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", "ReloadBindings")
	self.db.RegisterCallback(self, "OnProfileCopied", "ReloadBindings")
	self.db.RegisterCallback(self, "OnProfileReset", "ReloadBindings")

	local iconData = DataBroker:NewDataObject("Clicked", {
        type = "launcher",
        label = "Clicked",
        icon = "Interface\\Icons\\inv_misc_punchcards_yellow",
        OnClick = function()
            self:OpenBindingConfig()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("Clicked")
		end
    })
    Icon:Register("Clicked", iconData, self.db.profile.minimap)
	
	self:RegisterAddonConfig()
	self:RegisterBindingConfig()
end

function Clicked:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnteringCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeavingCombat")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ReloadActiveBindings")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "ReloadActiveBindingsAndConfig")

	self:ReloadBindings()
end

function Clicked:OnDisable()
	self:UnregisterEvent("OnEnteringCombat")
	self:UnregisterEvent("OnLeavingCombat")
	self:UnregisterEvent("ReloadActiveBindings")
	self:UnregisterEvent("ReloadActiveBindingsAndConfig")
end

function Clicked:ReloadBindings()
	self.bindings = self.db.profile.bindings
	self.activeBindings = {}
	
	self:ReloadActiveBindingsAndConfig()

	if self.db.profile.minimap.hide then
        Icon:Hide("Clicked")
    else
        Icon:Show("Clicked")
    end
end

function Clicked:OnEnteringCombat()
	inCombat = true
	self:ReloadActiveBindings()
end

function Clicked:OnLeavingCombat()
	inCombat = false
	self:ReloadActiveBindings()
end

function Clicked:ReloadActiveBindingsAndConfig()
	self:ReloadBindingConfig()
	self:ReloadActiveBindings()
end

local function Trim(s)
	return s:gsub("^%s*(.-)%s*$", "%1")
end

local function AddMacroFlags(target)
	local function AddFlag(flags, new)
		if #flags > 0 then
			flags = flags .. ","
		end
	
		return flags .. new
	end

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
	end

	if target.type == Clicked.TARGET_TYPE_HELP then
		flags = AddFlag(flags, "help")
	elseif target.type == Clicked.TARGET_TYPE_HARM then
		flags = AddFlag(flags, "harm")
	end

	flags = Trim(flags)

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
		return Trim(binding.action.macro)
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
		end

		-- Append the actual spell or item to use
		
		if binding.type == Clicked.TYPE_SPELL then
			macro = macro .. binding.action.spell
		elseif binding.type == Clicked.TYPE_ITEM then
			macro = macro .. binding.action.item
		end

		return macro
	end
	
	if binding.type == Clicked.TYPE_UNIT_SELECT then
		return "/target @mouseover"
	end

	if binding.type == Clicked.TYPE_UNIT_MENU then
		-- TODO: Open unit menu
		return ""
	end
end

-- Note: This is a secure function and may not be called during combat
local function InitializeHandlerFrames(macros)
	if InCombatLockdown() then
		return
	end
	
	-- Retrieve existing handlers from a cache, or create and cache a new one

	for i, macro in ipairs(macros) do
		local frame

		if i > #handlers then
			frame = CreateFrame("Button", "Clicked Handler (" .. #handlers .. ")", UIParent, "SecureActionButtonTemplate")
			frame:SetAttribute("type", "macro")

			table.insert(handlers, frame)
		else
			frame = handlers[i]
		end

		macro.frame = frame
	end

	-- Fully unregister handlers that are not currently required

	if #handlers > #macros then
		for i = #macros + 1, #handlers do
			local handler = handlers[i]
			
			handler:SetAttribute("macrotext", "")
			ClearOverrideBindings(handler)
		end
	end

	return result
end

-- Note: This is a secure function and may not be called during combat
local function RegisterMacroBindings(macros)
	if InCombatLockdown() then
		return
	end

	InitializeHandlerFrames(macros)

	for _, handler in ipairs(macros) do
		handler.frame:SetAttribute("macrotext", handler.macro)
				
		ClearOverrideBindings(handler.frame)
		SetOverrideBindingClick(handler.frame, true, handler.keybind, handler.frame:GetName())
	end
end

-- Note: This is a secure function and may not be called during combat
local function RegisterBindings(bindings)
	if InCombatLockdown() then
		return
	end
	
	local macros = {}

	for _, binding in ipairs(bindings) do
		local macro = GetMacroForBinding(binding)
		print(binding.keybind .. ": " .. macro)
		if macro ~= "" then
			table.insert(macros, {
				keybind = binding.keybind,
				macro = macro,
				handler = nil
			})
		end
	end

	if #macros > 0 then
		RegisterMacroBindings(macros)
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

	local active = {}
	local activatable = {}

	for i = 1, #self.bindings do
		local binding = self.bindings[i]
		
		if self:IsBindingActive(binding) then
			activatable[binding.keybind] = activatable[binding.keybind] or {}
			table.insert(activatable[binding.keybind], binding)
		end
	end

	for _, bindings in pairs(activatable) do
		local sorted = self:PrioritizeBindings(bindings)
		local binding = sorted[1]

		table.insert(active, binding)
	end
	
	RegisterBindings(active)
end

-- Check if the specified binding is currently active based on the configuration
-- provided in the binding's Load Options, and whether the binding is actually
-- valid (it has a keybind and an action to perform)
function Clicked:IsBindingActive(binding)
	if binding.keybind == "" then
		return false
	end

	local action = binding.action
	
	if binding.type == Clicked.TYPE_SPELL and Trim(action.spell) == "" then
		return false
	end

	if binding.type == Clicked.TYPE_MACRO and Trim(action.macro) == "" then
		return false
	end

	if binding.type == Clicked.TYPE_ITEM and Trim(action.item) == "" then
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
	
	if combat.selected == 1 then
		if combat.state == Clicked.COMBAT_STATE_TRUE and not inCombat then
			return false
		elseif combat.state == Clicked.COMBAT_STATE_FALSE and inCombat then
			return false
		end
	end
	
	-- If the known spell limiter has been enabled, see if the spell is currrently
	-- avaialble for the player. This is not limited to just spells as the name
	-- implies, using the GetSpellInfo function on an item also returns a valid value.

	local spellKnown = load.spellKnown

	if spellKnown.selected == 1 then
		local name = GetSpellInfo(spellKnown.spell)

		if name == nil then
			return false
		end
	end
	
	return true
end

-- Since there can be multiple bindings active with the same keybind, we need to
-- prioritize them at runtime somehow, this function will attempt to order the
-- input list of bindings in a way that makes sense to the user.
-- 
-- For example, if there is a binding that should only load in combat, it should
-- be prioritzed over generic or out-of-combat only bindings.
function Clicked:PrioritizeBindings(bindings)
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

-- Check if the specified keybind is "restricted", a restricted keybind
-- is not allowed to do various actions as it is required for core game
-- input (such as left and right mouse buttons).
--
-- Restricted keybinds can still be used for bindings, but they will
-- have limited functionality.
function Clicked:IsRestrictedKeybind(keybind)
    return keybind == "BUTTON1" or keybind == "BUTTON2"
end

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end
