-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
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

--- @class ClickedInternal
local Addon = select(2, ...)

-- Local support functions

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

-- Private addon API

function Addon:RegisterClickCastHeader()
	if C_AddOns.GetAddOnEnableState("Clique", UnitName("player")) > 0 then
		Addon:ShowAddonIncompatibilityPopup("Clique")
		return
	end

	-- This is mostly based on Clique, mainly to ensure it will continue
	-- working with any addons that integrate with Clique directly, such as oUF.

	--- @type table
	ClickCastHeader = CreateFrame("Frame", "ClickCastHeader", UIParent, "SecureHandlerBaseTemplate,SecureHandlerAttributeTemplate")
	Addon.ClickCastHeader = ClickCastHeader

	ClickCastHeader:SetAttribute("clicked-keybinds", "")
	ClickCastHeader:SetAttribute("clicked-identifiers", "")

	ClickCastHeader:SetAttribute("setup-keybinds", [[
		if currentClickcastButton ~= nil then
			control:RunFor(currentClickcastButton, control:GetAttribute("clear-keybinds"))
		end

		currentClickcastButton = self

		local keybinds = control:GetAttribute("clicked-keybinds")
		local identifiers = control:GetAttribute("clicked-identifiers")
		local button = self:GetAttribute("clicked-sidecar") or self

		if strlen(keybinds) > 0 then
			keybinds = table.new(strsplit("\001", keybinds))
			identifiers = table.new(strsplit("\001", identifiers))

			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				local identifier = identifiers[i]

				self:SetBindingClick(true, keybind, button, identifier)
			end
		end
	]])

	ClickCastHeader:SetAttribute("clear-keybinds", [[
		local keybinds = control:GetAttribute("clicked-keybinds")

		if strlen(keybinds) > 0 then
			keybinds = table.new(strsplit("\001", keybinds))

			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				self:ClearBinding(keybind)
			end
		end

		currentClickcastButton = nil
	]])

	ClickCastHeader:SetAttribute("clickcast_register", [[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_register", frame)
	]])

	ClickCastHeader:SetAttribute("clickcast_unregister", [[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_unregister", frame)
	]])

	ClickCastHeader:SetAttribute("clickcast_onenter", [[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
		frame:RunFor(self, frame:GetAttribute("setup-keybinds"))
	]])

	ClickCastHeader:SetAttribute("clickcast_onleave", [[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
		frame:RunFor(self, frame:GetAttribute("clear-keybinds"))
	]])

	ClickCastHeader:SetAttribute("_onattributechanged", [[
		local button = currentClickcastButton

		if name == "unit-exists" and value == "false" and button ~= nil then
			if not button:IsUnderMouse() or not button:IsVisible() then
				self:RunFor(button, self:GetAttribute("clear-keybinds"))
				currentClickcastButton = nil
			end
		end
	]])

	ClickCastHeader:HookScript("OnAttributeChanged", function(_, name, value)
		local frameName = value and value.GetName and value:GetName()

		if frameName == nil then
			return
		end

		if name == "export_register" then
			Clicked:RegisterClickCastFrame(frameName)
		elseif name == "export_unregister" then
			Clicked:UnregisterClickCastFrame(frameName)
		end
	end)

	RegisterAttributeDriver(ClickCastHeader, "unit-exists", "[@mouseover,exists] true; false")

	-- Hook into the global ClickCastFrames table
	local originalClickCastFrames = ClickCastFrames or {}

	ClickCastFrames = setmetatable({}, {
		__newindex = function(_, frame, options)
			if options ~= nil and options ~= false then
				Clicked:RegisterClickCastFrame(frame)
			else
				Clicked:UnregisterClickCastFrame(frame)
			end
		end
	})

	for frame in pairs(originalClickCastFrames) do
		Clicked:RegisterClickCastFrame(frame)
	end

	-- Hook into Clique because a lot of (older) addons are hardcoded to add Clique-support
	Clique = {}
	Clique.header = ClickCastHeader
	Clique.UpdateRegisteredClicks = function(_, frame)
		safecall(Clicked.RegisterFrameClicks, Clicked, frame, true)
	end
end

--- @param keybinds Keybind[]
function Addon:UpdateClickCastHeader(keybinds)
	if Addon.ClickCastHeader == nil then
		return
	end

	local split = {
		keybinds = {},
		identifiers = {}
	}

	for _, keybind in ipairs(keybinds) do
		table.insert(split.keybinds, keybind.key)
		table.insert(split.identifiers, keybind.identifier)
	end

	Addon.ClickCastHeader:SetAttribute("clicked-keybinds", table.concat(split.keybinds, "\001"))
	Addon.ClickCastHeader:SetAttribute("clicked-identifiers", table.concat(split.identifiers, "\001"))

	Addon.ClickCastHeader:Execute([[
		local button = currentClickcastButton

		if button ~= nil then
			self:RunFor(button, self:GetAttribute("clear-keybinds"))
			self:RunFor(button, self:GetAttribute("setup-keybinds"))
		end
	]])
end
