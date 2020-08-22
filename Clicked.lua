local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local InCombatLockdown = InCombatLockdown

Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")

Clicked.NAME = "Clicked"
Clicked.VERSION = GetAddOnMetadata(Clicked.NAME, "Version")

Clicked.TYPE_SPELL = "SPELL"
Clicked.TYPE_ITEM = "ITEM"
Clicked.TYPE_MACRO = "MACRO"
Clicked.TYPE_UNIT_SELECT = "UNIT_SELECT" -- not yet implemented
Clicked.TYPE_UNIT_MENU = "UNIT_MENU" -- not yet implemented

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

Clicked.UnitFrames = {}
Clicked.UnitFrameRegisterQueue = {}
Clicked.UnitFrameUnregisterQueue = {}
Clicked.ClickCastRegisterQueue = {}

local macroFrameHandlers = {}
local unitFrameAttributes = {}

local inCombat

function Clicked:OnInitialize()
	local defaultProfile = UnitName("player") .. " - " .. GetRealmName()

	self.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", "ReloadBindings")
	self.db.RegisterCallback(self, "OnProfileCopied", "ReloadBindings")
	self.db.RegisterCallback(self, "OnProfileReset", "ReloadBindings")

	local iconData = LibDataBroker:NewDataObject("Clicked", {
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
	LibDBIcon:Register("Clicked", iconData, self.db.profile.minimap)

	self:RegisterBlizzardUnitFrames()
	self:RegisterOUF()

	self:RegisterAddonConfig()
	self:RegisterBindingConfig()
end

function Clicked:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnteringCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeavingCombat")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ReloadActiveBindingsAndConfig")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "ReloadActiveBindingsAndConfig")
	self:RegisterEvent("BAG_UPDATE", "ReloadActiveBindingsAndConfig")
	self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")

	self:ReloadBindings()
end

function Clicked:OnDisable()
	self:UnregisterEvent("OnEnteringCombat")
	self:UnregisterEvent("OnLeavingCombat")
	self:UnregisterEvent("ReloadActiveBindingsAndConfig")
	self:UnregisterEvent("OnAddonLoaded")
end

function Clicked:ReloadBindings()
	self.bindings = self.db.profile.bindings
	self.activeBindings = {}

	self:ReloadActiveBindingsAndConfig()

	if self.db.profile.minimap.hide then
		LibDBIcon:Hide("Clicked")
	else
		LibDBIcon:Show("Clicked")
	end
end

function Clicked:OnEnteringCombat()
	inCombat = true

	self:ReloadActiveBindings()
end

function Clicked:OnLeavingCombat()
	inCombat = false

	self:ProcessUnitFrameQueue()
	self:ProcessClickCastQueue()

	self:ReloadActiveBindings()
end

function Clicked:OnAddonLoaded()
	self:ProcessUnitFrameQueue()
end

function Clicked:ReloadActiveBindingsAndConfig()
	self:ReloadBindingConfig()
	self:ReloadActiveBindings()
end

local function Trim(s)
	return s:gsub("^%s*(.-)%s*$", "%1")
end

local function StartsWith(str, start)
	return str:sub(1, #start) == start
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
	elseif target.unit == Clicked.TARGET_UNIT_FOCUS then
		flags = AddFlag(flags, "@focus")
	end

	if Clicked:CanTargetUnitBeHostile(target.unit) then
		if target.type == Clicked.TARGET_TYPE_HELP then
			flags = AddFlag(flags, "help")
		elseif target.type == Clicked.TARGET_TYPE_HARM then
			flags = AddFlag(flags, "harm")
		end
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

local function SetFrameAttributes(frame, attributes)
	for _, attribute in ipairs(attributes) do
		frame:SetAttribute(attribute.key, attribute.value)
	end
end

local function ClearFrameAttributes(frame, attributes)
	for _, attribute in ipairs(attributes) do
		frame:SetAttribute(attribute.key, "")
	end
end

local function RegisterAttribute(registry, key,  value)
	table.insert(registry, { key = key, value = value })
end

-- Note: This is a secure function and may not be called during combat
local function ApplyBindings(bindings)
	if InCombatLockdown() then
		return
	end

	local attributes = {}
	local nextMacroFrameHandler = 1
	
	for _, handler in ipairs(bindings) do
		if StartsWith(handler.keybind, "BUTTON") then
			local buttonIndex = handler.keybind:match("^BUTTON(%d+)$")

			RegisterAttribute(attributes, "type" .. buttonIndex, "macro")
			RegisterAttribute(attributes, "macrotext" .. buttonIndex, handler.macro)
		end

		if not Clicked:IsRestrictedKeybind(handler.keybind) then
			local frame

			if nextMacroFrameHandler > #macroFrameHandlers then
				frame = CreateFrame("Button", "ClickedMacroFrameHandler" .. nextMacroFrameHandler, UIParent, "SecureActionButtonTemplate")
				frame:SetAttribute("type", "macro")

				table.insert(macroFrameHandlers, frame)
			else
				frame = macroFrameHandlers[nextMacroFrameHandler]
			end

			nextMacroFrameHandler = nextMacroFrameHandler + 1

			frame:SetAttribute("macrotext", handler.macro)

			ClearOverrideBindings(frame)
			SetOverrideBindingClick(frame, false, handler.keybind, frame:GetName())
		end
	end

	for frame, _ in pairs(Clicked.UnitFrames) do
		ClearFrameAttributes(frame, unitFrameAttributes)

		if #attributes > 0 then
			SetFrameAttributes(frame, attributes)
		end
	end

	unitFrameAttributes = attributes

	for i = nextMacroFrameHandler, #macroFrameHandlers do
		local handler = macroFrameHandlers[i]

		handler:SetAttribute("macrotext", "")
		ClearOverrideBindings(handler)
	end
end

function Clicked:ProcessUnitFrameQueue()
	if InCombatLockdown() then
		return
	end

	local unregisterQueue = self.UnitFrameUnregisterQueue
	self.UnitFrameUnregisterQueue = {}

	for _, frame in ipairs(unregisterQueue) do
		self:UnregisterUnitFrame(frame)
	end

	local registerQueue = self.UnitFrameRegisterQueue
	self.UnitFrameRegisterQueue = {}

	for _, frame in ipairs(registerQueue) do
		self:RegisterUnitFrame(frame.addon, frame.frame, frame.options)
	end
end


function Clicked:ProcessClickCastQueue()
	local queue = self.ClickCastRegisterQueue
	self.clickCastRegisterQueue = {}

	for _, frame in ipairs(queue) do
		self:UpdateRegisteredClicks(frame)
	end
end

function Clicked:RegisterUnitFrame(addon, frame, options)
	if frame == nil then
		return
	end

	-- Already registered, so just update the options in case they have
	-- changed for whatever reason.

	if self.UnitFrames[frame] then
		self.UnitFrames[frame] = options
		return
	end

	-- We can't do anything while in combat, so put the items in a queue that
	-- gets processed when we exit combat.

	if InCombatLockdown() then
		table.insert(self.UnitFrameRegisterQueue, {
			addon = addon,
			frame = frame,
			options = options
		})

		return
	end

	-- If the input frame is a string (from for example Blizzard frame integration),
	-- check if the associated addon is currently loaded and try to convert it to a
	-- frame in the global table.
	--
	-- Built-in Blizzard frames such as the Blizzard_ArenaUI are loaded on-demand
	-- and thus will have to be queued until the addon actually loads.

	if type(frame) == "string" then
		if addon ~= "" and not IsAddOnLoaded(addon) then
			table.insert(self.UnitFrameRegisterQueue, {
				addon = addon,
				frame = frame,
				options = options
			})

			return
		else
			local name = frame
			frame = _G[name]

			if frame == nil then
				print("[Clicked] Unablet to register unit frame: " .. tostring(name))
				return
			end
		end
	end

	-- Skip anything that is not clickable

	if not frame.RegisterForClicks then
		return
	end

	-- if not AceHook:IsHooked(frame, "OnEnter") then
	-- 	AceHook:SecureHookScript(frame, "OnEnter", function(frame)
	-- 		hoveredUnitFrame = frame.unit
	-- 	end)
	-- end

	-- if not AceHook:IsHooked(frame, "OnLeave") then
	-- 	AceHook:SecureHookScript(frame, "OnLeave", function(frame)
	-- 		hoveredUnitFrame = nil
	-- 	end)
	-- end

	SetFrameAttributes(frame, unitFrameAttributes)
	
	self:UpdateRegisteredClicks(frame)
	self.UnitFrames[frame] = options
end

function Clicked:UnregisterUnitFrame(frame)
	if frame == nil then
		return
	end

	if not self.UnitFrames[frame] then
		return
	end

	-- If we're in combat we can't modify any frames, so put any
	-- unregister requests in a queue that gets processed when
	-- we leave combat.

	if InCombatLockdown() then
		table.insert(self.UnitFrameUnregisterQueue, frame)
		return
	end

	ClearFrameAttributes(frame, unitFrameAttributes)

	-- AceHook:Unhook(frame, "OnEnter")
	-- AceHook:Unhook(frame, "OnLeave")

	self.UnitFrames[frame] = nil
end

function Clicked:UpdateRegisteredClicks(frame)
	if frame == nil or frame.RegisterForClicks == nil then
		return
	end

	if InCombatLockdown() then
		table.insert(self.ClickCastRegisterQueue, frame)
		return
	end

	frame:RegisterForClicks("AnyUp")
	frame:EnableMouseWheel(true)
end

-- Note: This is a secure function and may not be called during combat
local function RegisterBindings(bindings)
	if InCombatLockdown() then
		return
	end

	local data = {}

	for _, binding in ipairs(bindings) do
		-- if Clicked:IsRestrictedKeybind(binding.keybind) then
		-- 	for _, attribute in ipairs(GetAttributesForBinding(binding)) do
		-- 		table.insert(attributes, attribute)
		-- 	end
		-- elseif binding.type == Clicked.TARGET_UNIT_MOUSEOVER_FRAME then
		-- 	-- todo
		-- elseif binding.type == Clicked.TYPE_UNIT_SELECT then
		-- 	-- todo
		-- elseif binding.type == Clicked.TYPE_UNIT_MENU then
		-- 	-- todo
		-- else
			local macro = GetMacroForBinding(binding)

			if macro ~= "" then
				table.insert(data, {
					keybind = binding.keybind,
					macro = macro
				})
			end
		-- end
	end

	ApplyBindings(data)
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

	if binding.type == self.TYPE_SPELL and Trim(action.spell) == "" then
		return false
	end

	if binding.type == self.TYPE_MACRO and Trim(action.macro) == "" then
		return false
	end

	if binding.type == self.TYPE_ITEM and Trim(action.item) == "" then
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
		if combat.state == self.COMBAT_STATE_TRUE and not inCombat then
			return false
		elseif combat.state == self.COMBAT_STATE_FALSE and inCombat then
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

function Clicked:CanTargetUnitBeHostile(unit)
	if unit == self.TARGET_UNIT_TARGET then
		return true
	end

	if unit == self.TARGET_UNIT_FOCUS then
		return true
	end

	if unit == self.TARGET_UNIT_MOUSEOVER then
		return true
	end

	if unit == self.TARGET_UNIT_MOUSEOVER_FRAME then
		return true
	end

	return false
end
