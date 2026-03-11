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

--- @class ClickCastModule : ClickedModule, AceEvent-3.0
--- @field public frame ClickCastHeader
--- @field private attributes table<string, string>
--- @field private frames Button[]
--- @field private sidecars Button[]
--- @field private registerQueue { frame: Button|string, addon: string }[]
--- @field private registerClicksQueue Button[]
--- @field private unregisterQueue Button[]
local Prototype = {
	attributes = {},
	frames = {},
	sidecars = {},
	registerQueue = {},
	registerClicksQueue = {},
	unregisterQueue = {}
}

--- @protected
function Prototype:OnInitialize()
	-- This is based on Clique, mainly to ensure it will works with any addons that integrate with Clique directly, such as oUF
	do
		self.frame = CreateFrame("Frame", "ClickCastHeader", UIParent, "SecureHandlerBaseTemplate,SecureHandlerAttributeTemplate")
		self.frame:SetAttribute("setup-keybinds", [[
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
		self.frame:SetAttribute("clear-keybinds", [[
			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				self:ClearBinding(keybind)
			end

			currentClickcastButton = nil
		]])
		self.frame:SetAttribute("clickcast_register", [[
			local frame = self:GetAttribute("clickcast_button")
			self:SetAttribute("export_register", frame)
		]])
		self.frame:SetAttribute("clickcast_unregister", [[
			local frame = self:GetAttribute("clickcast_button")
			self:SetAttribute("export_unregister", frame)
		]])
		self.frame:SetAttribute("clickcast_onenter", [[
			local frame = self:GetParent():GetFrameRef("clickcast_header")
			frame:RunFor(self, frame:GetAttribute("setup-keybinds"))
		]])
		self.frame:SetAttribute("clickcast_onleave", [[
			local frame = self:GetParent():GetFrameRef("clickcast_header")
			frame:RunFor(self, frame:GetAttribute("clear-keybinds"))
		]])
		self.frame:SetAttribute("_onattributechanged", [[
			local button = currentClickcastButton

			if name == "unit-exists" and value == "false" and button ~= nil then
				if not button:IsUnderMouse() or not button:IsVisible() then
					self:RunFor(button, self:GetAttribute("clear-keybinds"))
					currentClickcastButton = nil
				end
			end
		]])
		self.frame:HookScript("OnAttributeChanged", function(_, name, value)
			local frameName = value and value.GetName and value:GetName()

			if frameName == nil then
				return
			end

			if name == "export_register" then
				Addon.ClickCast:RegisterFrame(frameName)
			elseif name == "export_unregister" then
				Addon.ClickCast:UnregisterFrame(frameName)
			end
		end)

		Addon.AttributeHandler:UpdateRestrictedEnvironment(self.frame)
		RegisterAttributeDriver(self.frame, "unit-exists", "[@mouseover,exists] true; false")

		ClickCastHeader = self.frame
	end

	-- Hook into the global `ClickCastFrames` table
	do
		--- @type table<Button, boolean>
		local originalClickCastFrames = ClickCastFrames or {}

		--- @type table<Button, boolean>
		ClickCastFrames = setmetatable({}, {
			--- @param frame Button
			--- @param options boolean
			__newindex = function(_, frame, options)
				if options ~= nil and options ~= false then
					Addon.ClickCast:RegisterFrame(frame)
				else
					Addon.ClickCast:UnregisterFrame(frame)
				end
			end
		})

		for frame in pairs(originalClickCastFrames) do
			Addon.ClickCast:RegisterFrame(frame)
		end
	end

	-- Hook into Clique because a lot of (older) addons are hardcoded to add Clique-support
	do
		if Clique ~= nil then
			-- TODO: Enable this, currently it always errors because Clicked 1.x creates this, too.
			--error("Unable to load Clicked because Clique is enabled")
		end

		Clique = {}
		Clique.header = ClickCastHeader
		Clique.UpdateRegisteredClicks = function(_, frame)
			Addon:SafeCall(Clicked2.RegisterFrameClicks, Clicked2, frame)
		end
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD, self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED, self)
	self:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED, self)

	self:RegisterMessage("CLICKED_CLICK_CAST_ATTRIBUTES_CHANGED", self.CLICKED_CLICK_CAST_ATTRIBUTES_CHANGED, self)

	self:LogDebug("Initialized click-cast module")

	Addon:RegisterBlizzardUnitFrames()
end

--- @param frame Button
function Prototype:RegisterClicks(frame)
	if frame == nil or frame.RegisterForClicks == nil then
		return
	end

	if InCombatLockdown() or not self.initialized then
		self.registerClicksQueue = self.registerClicksQueue or {}

		table.insert(self.registerClicksQueue, frame)
		return
	end

	frame:RegisterForClicks(Addon.db.profile.options.onKeyDown and "AnyDown" or "AnyUp")
	frame:EnableMouseWheel(true)

	self:LogVerbose("Registered clicks for frame {frameName}", frame:GetName())
end

--- @param frame Button|string
--- @param addon? string
function Prototype:RegisterFrame(frame, addon)
	if frame == nil then
		return
	end

	-- We can't do anything while in combat, so put the items in a queue that gets processed when we exit combat.

	local function TryEnqueue()
		self.registerQueue = self.registerQueue or {}

		--- @type fun(item: { frame: Button, addon: string }): boolean
		local function Predicate(item)
			return item.addon == addon and item.frame == frame
		end

		if Addon.TableContainsPredicate(self.registerQueue, Predicate) then
			return
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
		end

		local name = frame
		frame = _G[name] --[[@as Button]]

		if frame == nil or frame.GetName == nil then
			return self:LogError("Unable to register frame: {frameName}", name)
		end
	end

	for _, existing in ipairs(self.frames) do
		if existing == frame then
			return self:LogVerbose("Frame {frameName} has already been registered!", frame:GetName())
		end
	end

	local name = frame:GetName()

	-- Skip anything that is not clickable
	if frame.RegisterForClicks == nil then
		return self:LogDebug("Ignoring frame {frameName} because it does not have a RegisterForClicks function", name)
	end

	if Addon.Blacklist:IsFrameBlacklisted(frame) then
		return self:LogDebug("Ignoring frame {frameName} because it has been blacklisted", name)
	end

	if name == nil then
		self:CreateSidecar(frame, nil)
	end

	self:RegisterClicks(frame)
	self:UpdateClickCastFrame(frame, self.attributes)

	if frame:GetAttribute("*type2") == "menu" then
		frame:SetAttribute("*type2", "togglemenu")
	end

	table.insert(self.frames, frame)

	self:SendMessage("CLICKED_CLICKCAST_FRAME_REGISTERED", frame)

	if name ~= nil then
		self:LogVerbose("Registered frame {frameName}", name)
	end
end

--- @param frame Button|string
function Prototype:UnregisterFrame(frame)
	if frame == nil then
		return
	end

	if type(frame) == "string" then
		local name = frame
		frame = _G[name] --[[@as Button]]

		if frame == nil or frame.GetName == nil then
			return self:LogError("Unable to unregister frame: {frameName}", name)
		end
	end

	-- If we're in combat we can't modify any frames, so put any unregister requests in a queue that gets processed when we leave combat.

	if InCombatLockdown() or not Addon:IsInitialized() then
		self.unregisterQueue = self.unregisterQueue or {}

		if Addon.TableContainsItem(self.unregisterQueue, frame) then
			return
		end

		table.insert(self.unregisterQueue, frame)
		return
	end

	local index = Addon.TableIndexOfItem(self.frames, frame)
	if index == 0 then
		return
	end

	Addon.AttributeHandler:ApplyAttributes(frame)

	self.frame:UnwrapScript(frame, "OnEnter")
	self.frame:UnwrapScript(frame, "OnLeave")

	-- TODO: Unregister sidecar?

	table.remove(self.frames, index)

	self:SendMessage("CLICKED_CLICKCAST_FRAME_UNREGISTERED", frame)

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

function Prototype:IterateFrames()
	return ipairs(self.frames)
end

function Prototype:IterateSidecars()
	return ipairs(self.sidecars)
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
			self:UnregisterFrame(frame)
		end
	end

	do
		local queue = self.registerQueue
		self.registerQueue = {}

		for _, frame in ipairs(queue) do
			self:RegisterFrame(frame.frame, frame.addon)
		end
	end

	do
		local queue = self.registerClicksQueue
		self.registerClicksQueue = {}

		for _, frame in ipairs(queue) do
			self:RegisterClicks(frame)
		end
	end
end

--- @private
--- @param frame Button
--- @param attributes table<string,string>
--- @param setup? string
--- @param clear? string
function Prototype:UpdateClickCastFrame(frame, attributes, setup, clear)
	Addon.AttributeHandler:ApplyAttributes(frame, attributes)

	if self.frame ~= nil then
		setup = setup or self.frame:GetAttribute("setup-keybinds")
		clear = clear or self.frame:GetAttribute("clear-keybinds")

		self.frame:UnwrapScript(frame, "OnEnter")
		self.frame:UnwrapScript(frame, "OnLeave")
		self.frame:WrapScript(frame, "OnEnter", setup)
		self.frame:WrapScript(frame, "OnLeave", clear)
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
	self.frame:Execute([[
		local button = currentClickcastButton

		if button ~= nil then
			self:RunFor(button, self:GetAttribute("clear-keybinds"))
		end
	]])

	Addon.AttributeHandler:UpdateRestrictedEnvironment(self.frame, keybinds)
	self.frame:Execute([[
		local button = currentClickcastButton

		if button ~= nil then
			self:RunFor(button, self:GetAttribute("setup-keybinds"))
		end
	]])

	local setup = self.frame:GetAttribute("setup-keybinds")
	local clear = self.frame:GetAttribute("clear-keybinds")

	for _, frame in ipairs(self.frames) do
		self:UpdateClickCastFrame(frame, newAttributes, setup, clear)
	end

	self.attributes = newAttributes
end

--- @type ClickCastModule
Addon.ClickCast = Clicked2:NewModule("ClickCast", Prototype, "AceEvent-3.0")
