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

local AceGUI = LibStub("AceGUI-3.0")

-- Deprecated in 5.5.0
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
-- Deprecated in 5.5.0
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

--- @class ClickedInternal
local Addon = select(2, ...)

--- @type Frame
local driver

--- @type AceGUIFrame
local frame

--- @type ClickedReadOnlyMultilineEditBox
local editbox

--- @type { hovercast: table<string,string>, macroHandler: table<string,string>, timestamp: number }
local data

-- Local support functions

--- @return string
local function GetBasicinfoString()
	local lines = {}

	table.insert(lines, "Version: " .. Clicked.VERSION)
	table.insert(lines, "Data Version: " .. Addon.DATA_VERSION)
	table.insert(lines, "Project ID: " .. WOW_PROJECT_ID)
	table.insert(lines, "Race: " .. select(2, UnitRace("player")))
	table.insert(lines, "Level: " .. UnitLevel("player"))
	table.insert(lines, "Class: " .. select(2, UnitClass("player")))

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		local configId =  C_ClassTalents.GetActiveConfigID()
		table.insert(lines, "Talents: " .. (configId ~= nil and C_Traits.GenerateImportString(configId) or "unknown"))
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
		local id, name = GetSpecializationInfo(GetSpecialization())
		table.insert(lines, "Specialization: " .. id .. " (" .. name .. ")")
	elseif Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
		local id, name = GetTalentTabInfo(GetPrimaryTalentTree())
		table.insert(lines, "Specialization: " .. id .. " (" .. name .. ")")
	end

	table.insert(lines, "Press Mode: " .. (Addon.db.profile.options.onKeyDown and "AnyDown" or "AnyUp"))
	table.insert(lines, "Autogen: " .. (Addon.db.profile.options.bindUnassignedModifiers and "True" or "False"))

	table.insert(lines, "")

	table.insert(lines, "Possess Bar: " .. driver:GetAttribute("state-possessbar"))
	table.insert(lines, "Override Bar: " .. driver:GetAttribute("state-overridebar"))

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.WOTLK then
		table.insert(lines, "Vehicle: " .. driver:GetAttribute("state-vehicle"))
		table.insert(lines, "Vehicle UI: " .. driver:GetAttribute("state-vehicleui"))
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
		table.insert(lines, "Pet Battle: " .. driver:GetAttribute("state-petbattle"))
	end

	return table.concat(lines, "\n")
end

--- @return string
local function GetLoadedBindings()
	local lines = {}

	for i, command in ipairs(data) do
		if i > 1 then
			table.insert(lines, "")
		end

		table.insert(lines, "----- Loaded binding " .. i .. " -----")
		table.insert(lines, "Keybind: " .. command.keybind)
		table.insert(lines, "Hovercast: " .. tostring(command.hovercast))
		table.insert(lines, "Action: " .. command.action)
		table.insert(lines, "Identifier: " .. command.suffix)

		if type(command.data) == "string" then
			local split = { strsplit("\n", command.data) }

			if #split > 0 then
				table.insert(lines, "")
			end

			for _, line in ipairs(split) do
				table.insert(lines, line)
			end
		elseif type(command.data) == "boolean" then
			table.insert(lines, "Combat: " .. tostring(command.data))
		end
	end

	local function ParseAttributes(heading, attributes)
		if attributes == nil then
			return
		end

		local first = true

		for attribute, value in pairs(attributes) do
			if first then
				table.insert(lines, "")
				table.insert(lines, "----- " .. heading .. " -----")
				first = false
			end

			local split = { strsplit("\n", value) }

			for _, line in ipairs(split) do
				table.insert(lines, attribute .. ": " .. line)
			end
		end
	end

	ParseAttributes("Macro Handler Attributes", data.macroHandler)
	ParseAttributes("Hovercast Attributes", data.hovercast)

	return table.concat(lines, "\n")
end

--- @return string
local function GetUnloadedBindings()
	local lines = {}

	for i, binding in Clicked:IterateConfiguredBindings() do
		if i > 1 then
			table.insert(lines, "")
		end

		table.insert(lines, "----- Unloaded binding " .. binding.uid .. " -----")
		table.insert(lines, "Type: " .. binding.actionType)
		table.insert(lines, "Keybind: " .. binding.keybind)
		table.insert(lines, "Scope: " .. binding.scope)

		local value = Addon:GetBindingValue(binding)
		if value ~= nil then
			table.insert(lines, "Action: " .. value)
		end

		local loadState = Addon:GetCachedBindingState(binding)

		if loadState ~= nil then
			table.insert(lines, "")
			table.insert(lines, "Load state:")

			for event, state in pairs(loadState) do
				table.insert(lines, "  " .. event .. " = " .. tostring(state))
			end
		end
	end

	return table.concat(lines, "\n")
end

--- @return string
local function GetRegisteredClickCastFrames()
	local lines = {}

	for _, clickCastFrame in Clicked:IterateClickCastFrames() do
		if clickCastFrame ~= nil and clickCastFrame.GetName ~= nil then
			local name = clickCastFrame:GetName()

			if name ~= nil then
				local blacklisted = Addon:IsFrameBlacklisted(clickCastFrame)
				table.insert(lines, name .. (blacklisted and " (blacklisted)" or ""))
			end
		end
	end

	table.sort(lines)

	if #lines > 0 then
		table.insert(lines, 1, "----- Registered unit frames -----")
	end

	return table.concat(lines, "\n")
end

--- @return string
local function GetRegisteredClickCastSidecars()
	local lines = {}

	for _, sidecar in Clicked:IterateSidecars() do
		local targetFrameName = sidecar:GetAttribute("clicked-name")

		table.insert(lines, sidecar:GetName() .. (targetFrameName and " (for " .. targetFrameName .. ")" or ""))
	end

	table.sort(lines)

	if #lines > 0 then
		table.insert(lines, 1, "----- Registered sidecars -----")
	end

	return table.concat(lines, "\n")
end

--- @return string
local function GetSerializedProfileString()
	local lines = {}

	table.insert(lines, "----- Saved Global Variables -----")
	table.insert(lines, Clicked:SerializeProfile(Addon.db.global, true, true))
	table.insert(lines, "")
	table.insert(lines, "----- Saved Profile Variables -----")
	table.insert(lines, Clicked:SerializeProfile(Addon.db.profile, true, true))

	return table.concat(lines, "\n")
end

local function UpdateStatusOutputText()
	if frame == nil or not frame:IsVisible() or editbox == nil then
		return
	end

	local text = {}
	table.insert(text, GetBasicinfoString())
	table.insert(text, GetLoadedBindings())
	table.insert(text, GetUnloadedBindings())
	table.insert(text, GetRegisteredClickCastFrames())
	table.insert(text, GetRegisteredClickCastSidecars())
	table.insert(text, GetSerializedProfileString())

	editbox:SetText(table.concat(text, "\n\n"))
end

local function UpdateLastUpdatedTime()
	if frame == nil or not frame:IsVisible() then
		return
	end

	frame:SetStatusText(string.format("Last generated %s seconds ago", math.floor((GetTime() - data.timestamp) + 0.5)))

	C_Timer.After(1, UpdateLastUpdatedTime)
end

local function CreateStateDriver(state, condition)
	RegisterStateDriver(driver, state, condition)
	driver:SetAttribute("_onstate-" .. state, [[ self:CallMethod("UpdateStatusOutputText") ]])
end

-- Private addon API

function Addon:StatusOutput_Initialize()
	driver = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate") --[[@as Frame]]
	driver:Show()

	CreateStateDriver("possessbar", "[possessbar] enabled; disabled")
	CreateStateDriver("overridebar", "[overridebar] enabled; disabled")

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.WOTLK then
		CreateStateDriver("vehicle", "[@vehicle,exists] enabled; disabled")
		CreateStateDriver("vehicleui", "[vehicleui] enabled; disabled")
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
		CreateStateDriver("petbattle", "[petbattle] enabled; disabled")
	end

	driver.UpdateStatusOutputText = UpdateStatusOutputText --- @diagnostic disable-line: inject-field
end

function Addon:StatusOutput_Open()
	if frame ~= nil and frame:IsVisible() then
		return
	end

	frame = AceGUI:Create("Frame") --[[@as AceGUIFrame]]
	frame:SetTitle("Clicked Data Dump")
	frame:SetLayout("Fill")

	editbox = AceGUI:Create("ClickedReadOnlyMultilineEditBox") --[[@as ClickedReadOnlyMultilineEditBox]]
	editbox:SetLabel("")
	frame:AddChild(editbox)

	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
	end)

	UpdateLastUpdatedTime()
	UpdateStatusOutputText()
end

--- @param commands Command[]
function Addon:StatusOutput_HandleCommandsGenerated(commands)
	data = {}
	data.timestamp = GetTime()

	for i, command in ipairs(commands) do
		data[i] = command
	end

	if frame ~= nil and frame:IsVisible() then
		UpdateStatusOutputText()
	end
end

--- @param attributes table<string,string>
function Addon:StatusOutput_UpdateMacroHandlerAttributes(attributes)
	data.macroHandler = attributes

	if frame ~= nil and frame:IsVisible() then
		UpdateStatusOutputText()
	end
end

--- @param attributes table<string,string>
function Addon:StatusOutput_UpdateHovercastAttributes(attributes)
	data.hovercast = attributes

	if frame ~= nil and frame:IsVisible() then
		UpdateStatusOutputText()
	end
end
