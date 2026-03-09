-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

--- @class Addon
local Addon = select(2, ...)

--- @param frame Button
--- @param attributes table<string,string>
--- @param setup string
--- @param clear string
local function UpdateClickCastFrame(frame, attributes, setup, clear)
	Addon.ClickCast:ApplyAttributes(frame, attributes)

	if Addon.clickCastHeader ~= nil then
		Addon.clickCastHeader:UnwrapScript(frame, "OnEnter")
		Addon.clickCastHeader:UnwrapScript(frame, "OnLeave")
		Addon.clickCastHeader:WrapScript(frame, "OnEnter", setup)
		Addon.clickCastHeader:WrapScript(frame, "OnLeave", clear)
	end
end

--- @class ClickCastHeaderModule : AceModule, AceEvent-3.0, LibLog-1.0.Logger
local Prototype = {}

--- @protected
function Prototype:OnInitialize()
	-- This is mostly based on Clique, mainly to ensure it will works with any addons that integrate with Clique directly, such as oUF.

	Addon.clickCastHeader = CreateFrame("Frame", "ClickCastHeader", UIParent, "SecureHandlerBaseTemplate,SecureHandlerAttributeTemplate")
	Addon.clickCastHeader:SetAttribute("setup-keybinds", [[
		if currentClickcastButton ~= nil then
			control:RunFor(currentClickcastButton, control:GetAttribute("clear-keybinds"))
		end

		currentClickcastButton = self

		local button = self:GetAttribute("clicked-sidecar") or self

		for i = 1, table.maxn(keybinds) do
			local keybind = keybinds[i]
			local identifier = identifiers[i]

			self:SetBindingClick(true, keybind, button, identifier)
		end
	]])
	Addon.clickCastHeader:SetAttribute("clear-keybinds", [[
		for i = 1, table.maxn(keybinds) do
			local keybind = keybinds[i]
			self:ClearBinding(keybind)
		end

		currentClickcastButton = nil
	]])
	Addon.clickCastHeader:SetAttribute("clickcast_register", [[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_register", frame)
	]])
	Addon.clickCastHeader:SetAttribute("clickcast_unregister", [[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_unregister", frame)
	]])
	Addon.clickCastHeader:SetAttribute("clickcast_onenter", [[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
		frame:RunFor(self, frame:GetAttribute("setup-keybinds"))
	]])
	Addon.clickCastHeader:SetAttribute("clickcast_onleave", [[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
		frame:RunFor(self, frame:GetAttribute("clear-keybinds"))
	]])
	Addon.clickCastHeader:SetAttribute("_onattributechanged", [[
		local button = currentClickcastButton

		if name == "unit-exists" and value == "false" and button ~= nil then
			if not button:IsUnderMouse() or not button:IsVisible() then
				self:RunFor(button, self:GetAttribute("clear-keybinds"))
				currentClickcastButton = nil
			end
		end
	]])
	Addon.clickCastHeader:HookScript("OnAttributeChanged", function(_, name, value)
		local frameName = value and value.GetName and value:GetName()

		if frameName == nil then
			return
		end

		if name == "export_register" then
			Clicked2:RegisterClickCastFrame(frameName)
		elseif name == "export_unregister" then
			Clicked2:UnregisterClickCastFrame(frameName)
		end
	end)

	Addon.ClickCast:UpdateRestrictedEnvironment(ClickCastHeader)
	RegisterAttributeDriver(Addon.clickCastHeader, "unit-exists", "[@mouseover,exists] true; false")

	ClickCastHeader = Addon.clickCastHeader

	-- Hook into the global `ClickCastFrames` table
	local originalClickCastFrames = ClickCastFrames or {}

	ClickCastFrames = setmetatable({}, {
		__newindex = function(_, frame, options)
			if options ~= nil and options ~= false then
				Clicked2:RegisterClickCastFrame(frame)
			else
				Clicked2:UnregisterClickCastFrame(frame)
			end
		end
	})

	for frame in pairs(originalClickCastFrames) do
		Clicked2:RegisterClickCastFrame(frame)
	end

	-- Hook into Clique because a lot of (older) addons are hardcoded to add Clique-support
	if Clique ~= nil then
		--error("Unable to load Clicked because Clique is enabled")
	end

	Clique = {}
	Clique.header = ClickCastHeader
	Clique.UpdateRegisteredClicks = function(_, frame)
		Addon:SafeCall(Clicked2.RegisterFrameClicks, Clicked2, frame)
	end

	--- @type table<string, string>
	self.attributes = {}

	--- @type Button[]
	self.frames = {}

	--- @type Button[]
	self.sidecars = {}

	--- @type { frame: Button, addon: string }[]
	self.registerQueue = {}

	--- @type Button[]
	self.unregisterQueue = {}

	self:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD, self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED, self)
	self:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED, self)

	self:RegisterMessage("CLICKED_CLICK_CAST_ATTRIBUTES_CHANGED", self.CLICKED_CLICK_CAST_ATTRIBUTES_CHANGED, self)

	self:LogDebug("Initialized click-cast header module")

	Addon:RegisterBlizzardUnitFrames()
end

--- @param frame Button|string
--- @param addon? string
function Prototype:RegisterClickCastFrame(frame, addon)
	if frame == nil then
		return
	end

	-- We can't do anything while in combat, so put the items in a queue that gets processed when we exit combat.

	local function TryEnqueue()
		self.registerQueue = self.registerQueue or {}

		for i = 1, #self.registerQueue do
			local element = self.registerQueue[i]

			if element.addon == addon and element.frame == frame then
				return
			end
		end

		table.insert(self.registerQueue, {
			addon = addon,
			frame = frame
		})
	end

	if InCombatLockdown() or not self.initialized then
		TryEnqueue()
		return
	end

	for _, existing in ipairs(self.frames) do
		if existing == frame then
			return self:LogVerbose("Frame {frameName} has already been registered!", frame:GetName())
		end
	end

	-- If the input frame is a string (from for example Blizzard frame integration),
	-- check if the associated addon is currently loaded and try to convert it to a
	-- frame in the global table.
	--
	-- Built-in Blizzard frames such as the Blizzard_ArenaUI are loaded on-demand
	-- and thus will have to be queued until the addon actually loads.

	if type(frame) == "string" then
		if addon ~= nil and not C_AddOns.IsAddOnLoaded(addon) then
			TryEnqueue()
			return
		else
			local name = frame --[[@as string]]
			frame = _G[name]

			if frame == nil then
				return self:LogError("Unable to register frame: {frameName}", name)
			end
		end
	end

	local name = frame:GetName()

	-- Skip anything that is not clickable
	if frame.RegisterForClicks == nil then
		return self:LogDebug("Ignoring frame {frameName} because it does not have a RegisterForClicks function", name)
	end

	if Addon:IsFrameBlacklisted(frame) then
		return self:LogDebug("Ignoring frame {frameName} because it has been blacklisted", name)
	end

	if name == nil then
		self:CreateSidecar(frame, nil)
	end

	Clicked2:RegisterFrameClicks(frame)

	local setup = Addon.clickCastHeader:GetAttribute("setup-keybinds")
	local clear = Addon.clickCastHeader:GetAttribute("clear-keybinds")
	UpdateClickCastFrame(frame, self.attributes, setup, clear)

	if frame:GetAttribute("*type2") == "menu" then
		frame:SetAttribute("*type2", "togglemenu")
	end

	table.insert(self.frames, frame)

	-- TODO: Make this listen to an event
	Addon.BlacklistOptions:RegisterFrame(frame)

	self:SendMessage("CLICKED_FRAME_REGISTERED", frame)

	if name ~= nil then
		self:LogVerbose("Registered frame {frameName}", name)
	end
end

--- @param frame Button|string
function Prototype:UnregisterClickCastFrame(frame)
	if frame == nil then
		return
	end

	if type(frame) == "string" then
		local name = frame
		frame = _G[name]

		if frame == nil then
			return self:LogError("Unable to unregister frame: {frameName}", name)
		end
	end

	-- If we're in combat we can't modify any frames, so put any unregister requests in a queue that gets processed when we leave combat.

	local function TryEnqueue()
		for i = 1, #self.unregisterQueue do
			local element = self.unregisterQueue[i]

			if element == frame then
				return
			end
		end

		table.insert(self.unregisterQueue, frame)
	end

	if InCombatLockdown() or not Addon:IsInitialized() then
		TryEnqueue()
		return
	end

	local index = Addon.TableIndexOfItem(self.frames, frame)
	if index == 0 then
		return
	end

	Addon.ClickCast:ApplyAttributes(frame)

	Addon.clickCastHeader:UnwrapScript(frame, "OnEnter")
	Addon.clickCastHeader:UnwrapScript(frame, "OnLeave")

	-- TODO: Unregister sidecar?

	table.remove(self.frames, index)

	self:SendMessage("CLICKED_FRAME_UNREGISTERED", frame)

	self:LogVerbose("Unregistered frame {frameName}", frame:GetName())
end

--- @param frame Button
--- @param name string?
--- @return Button
function Prototype:CreateSidecar(frame, name)
	local sidecarId = frame:GetAttribute("clicked-sidecar")

	--- @param sidecar Button
	local function UpdateName(sidecar)
		if name ~= nil then
			sidecar:SetAttribute("clicked-name", name)
		end
	end

	if sidecarId == nil then
		local frameName = "ClickedSidecar" .. tostring(#self.sidecars + 1)

		local sidecar = CreateFrame("Button", frameName, frame, "SecureUnitButtonTemplate") --[[@as Button]]
		sidecar:SetAttribute("useparent*", true)

		frame:SetAttribute("clicked-sidecar", frameName)
		frame:SetAttribute("clicked-name", name)

		table.insert(self.sidecars, sidecar)

		self:LogVerbose("Created sidecar for frame {frameName}", name)

		UpdateName(sidecar)
		return sidecar
	end

	local sidecar = _G[sidecarId]
	UpdateName(sidecar)

	return sidecar
end

--- @private
function Prototype:ProcessQueue()
	if InCombatLockdown() then
		return
	end

	do
		local queue = self.unregisterQueue
		self.unregisterQueue = {}

		for _, frame in ipairs(queue) do
			self:UnregisterClickCastFrame(frame)
		end
	end

	do
		local queue = self.registerQueue
		self.registerQueue = {}

		for _, frame in ipairs(queue) do
			self:RegisterClickCastFrame(frame.frame, frame.addon)
		end
	end
end

--- @private
function Prototype:PLAYER_ENTERING_WORLD()
	self.initialized = true

	self:ProcessQueue()
end

--- @private
function Prototype:PLAYER_REGEN_ENABLED()
	self:ProcessQueue()
end

--- @private
function Prototype:ADDON_LOADED()
	self:ProcessQueue()
end

--- @private
function Prototype:CLICKED_CLICK_CAST_ATTRIBUTES_CHANGED(_, keybinds, newAttributes)
	Addon.clickCastHeader:Execute([[
		local button = currentClickcastButton

		if button ~= nil then
			self:RunFor(button, self:GetAttribute("clear-keybinds"))
		end
	]])

	Addon.ClickCast:UpdateRestrictedEnvironment(Addon.clickCastHeader, keybinds)
	Addon.clickCastHeader:Execute([[
		local button = currentClickcastButton

		if button ~= nil then
			self:RunFor(button, self:GetAttribute("setup-keybinds"))
		end
	]])

	local setup = Addon.clickCastHeader:GetAttribute("setup-keybinds")
	local clear = Addon.clickCastHeader:GetAttribute("clear-keybinds")

	for _, frame in ipairs(self.frames) do
		UpdateClickCastFrame(frame, newAttributes, setup, clear)
	end

	self.attributes = newAttributes
end

--- @param frame Button|string
--- @param addon? string
--- @see Clicked2.UnregisterClickCastFrame
function Clicked2:RegisterClickCastFrame(frame, addon)
	Prototype:RegisterClickCastFrame(frame, addon)
end

--- @param frame Button
--- @param name string?
--- @return Button
function Clicked2:CreateSidecar(frame, name)
	return Prototype:CreateSidecar(frame, name)
end

--- @param frame Button|string
--- @see Clicked2.RegisterClickCastFrame
function Clicked2:UnregisterClickCastFrame(frame)
	Prototype:UnregisterClickCastFrame(frame)
end

function Clicked2:IterateClickCastFrames()
	return ipairs(Prototype.frames)
end

function Clicked2:IterateSidecars()
	return ipairs(Prototype.sidecars)
end

Clicked2:NewModule("ClickCastHeader", Prototype, "AceEvent-3.0")
