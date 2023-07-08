-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

--- @class ClickedInternal
local Addon = select(2, ...)

--- @type AceGUIFrame?
local frame
--- @type AceGUIScrollFrame
local scrollFrame
local scrollFrameStatus

--- @type "talents"
local currentType
--- @type Binding
local currentBinding
--- @type Binding.MutliFieldLoadOption
local currentBackingField
--- @type TalentInfo[]
local currentTalents

--- @param name string
--- @return boolean
local function DoesTalentExist(name)
	for _, item in ipairs(currentTalents) do
		if item.text == name then
			return true
		end
	end

	return false
end

--- @param container AceGUIContainer
local function BuildTalentPanel(container)
	local function AddSeparator()
		local widget = AceGUI:Create("Heading") --[[@as AceGUIHeading]]
		widget:SetFullWidth(true)
		widget:SetText(Addon.L["Or"])

		container:AddChild(widget)
	end

	--- @param operation "AND"|"OR"
	--- @param position integer
	local function AddAddButton(operation, position)
		local function OnClick()
			table.insert(currentBackingField.entries, position, {
				operation = operation,
				value = ""
			})

			Addon:BindingConfig_Redraw()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetCallback("OnClick", OnClick)
		widget:SetText(Addon.L["Add"])

		widget:SetFullWidth(true)
		container:AddChild(widget)
	end

	for i = 1, #currentBackingField.entries do
		local entry = currentBackingField.entries[i]

		if entry.operation == "OR" then
			AddSeparator()
		end

		do
			local function OnClick()
				entry.negated = not entry.negated
				Clicked:ReloadBinding(currentBinding, true)
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(entry.negated and Addon.L["Not"] or "")
			widget:SetCallback("OnClick", OnClick)
			widget:SetRelativeWidth(0.2)

			container:AddChild(widget)
		end

		do
			local widget = Addon:GUI_AutoFillEditBox(entry, "value", currentBinding)
			widget:SetInputError(not DoesTalentExist(entry.value))
			widget:SetValues(currentTalents)

			widget:SetRelativeWidth(0.65)

			container:AddChild(widget)
		end

		do
			local function OnClick()
				table.remove(currentBackingField.entries, i)

				if #currentBackingField.entries > 0 then
					do
						local first = currentBackingField.entries[1]

						if first.operation == "OR" then
							first.operation = "AND"
						end
					end

					do
						local next = currentBackingField.entries[i]

						if next ~= nil and entry.operation == "OR" and next.operation == "AND" then
							next.operation = "OR"
						end
					end
				end

				Clicked:ReloadBinding(currentBinding, true)
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(Addon.L["X"])
			widget:SetCallback("OnClick", OnClick)
			widget:SetDisabled(#currentBackingField.entries == 1)
			widget:SetRelativeWidth(0.14)

			container:AddChild(widget)
		end

		if i == #currentBackingField.entries or currentBackingField.entries[i + 1].operation == "OR" then
			AddAddButton("AND", i + 1)
		end
	end

	AddSeparator()
	AddAddButton(#currentBackingField.entries == 0 and "AND" or "OR", #currentBackingField.entries + 1)
end

--- @param title string
--- @param type "talents"
--- @param backingField Binding.MutliFieldLoadOption
--- @param talents TalentInfo[]
local function OpenFrame(title, type, binding, backingField, talents)

	currentType = type
	currentBinding = binding
	currentBackingField = backingField
	currentTalents = talents

	frame = AceGUI:Create("ClickedFrame") --[[@as ClickedFrame]]
	frame:SetTitle(title)
	frame:EnableResize(false)
	frame:SetWidth(350)
	frame:SetHeight(450)
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		frame = nil
	end)

	scrollFrameStatus = {}
	scrollFrame = AceGUI:Create("ScrollFrame") --[[@as AceGUIScrollFrame]]
	scrollFrame:SetLayout("Flow")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetStatusTable(scrollFrameStatus)

	frame:AddChild(scrollFrame)

	BuildTalentPanel(scrollFrame)
end

-- Private addon API

--- @class TalentFrame
local TalentFrame = {}

--- Open the talent selection UI
---
--- @param binding Binding
--- @param backingField Binding.MutliFieldLoadOption
--- @param talents TalentInfo[]
function TalentFrame:OpenForTalents(binding, backingField, talents)
	if frame ~= nil and frame:IsVisible() then
		return
	end

	OpenFrame(Addon.L["Select talents"], "talents", binding, backingField, talents)
end

function TalentFrame:Close()
	if frame == nil or not frame:IsVisible() then
		return
	end

	frame:Hide()
end

function TalentFrame:Redraw()
	if frame == nil or not frame:IsVisible() then
		return
	end


	local offset = scrollFrameStatus.offset
	local scrollvalue = scrollFrameStatus.scrollvalue

	scrollFrame:ReleaseChildren()
	BuildTalentPanel(scrollFrame)

	scrollFrameStatus.offset = offset
	scrollFrameStatus.scrollvalue = scrollvalue
	scrollFrame:FixScroll()
end

Addon.TalentFrame = TalentFrame
