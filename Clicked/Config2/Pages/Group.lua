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

--- @class ClickedInternal
local Addon = select(2, ...)

local Helpers = Addon.BindingConfig.Helpers

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigGroupPage : BindingConfigPage
--- @field public targets Group[]
Addon.BindingConfig.GroupPage = {
	keepTreeSelection = true
}

--- @protected
function Addon.BindingConfig.GroupPage:Redraw()
	do
		--- @param group Group
		--- @return string
		local function ValueSelector(group)
			return group.name
		end

		--- @param value string
		local function OnEnterPressed(_, _, value)
			value = string.trim(value)

			for _, group in ipairs(self.targets) do
				group.name = value
			end

			Addon.BindingConfig.Window:RedrawTree()
		end

		local widget = AceGUI:Create("ClickedEditBox") --[[@as AceGUIEditBox]]
		widget:SetFullWidth(true)
		widget:SetCallback("OnEnterPressed", OnEnterPressed)

		Helpers:HandleWidget(widget, self.targets, ValueSelector, Addon.L["Group name"])

		self.container:AddChild(widget)
	end

	-- icon field
	do
		--- @param group Group
		--- @return string
		local function ValueSelector(group)
			return tostring(group.displayIcon)
		end

		--- @param value string
		local function OnEnterPressed(_, _, value)
			for _, group in ipairs(self.targets) do
				group.displayIcon = value
			end

			Addon.BindingConfig.Window:RedrawTree()
		end

		local widget = AceGUI:Create("ClickedEditBox") --[[@as AceGUIEditBox]]
		widget:SetRelativeWidth(0.7)
		widget:SetCallback("OnEnterPressed", OnEnterPressed)

		Helpers:HandleWidget(widget, self.targets, ValueSelector, Addon.L["Group icon"])

		self.container:AddChild(widget)
	end

	do
		--- @param bindings Group[]
		--- @param value string
		local function OnSelect(bindings, value)
			for _, binding in ipairs(bindings) do
				binding.displayIcon = value
			end

			Addon.BindingConfig.Window:RedrawTree()
		end

		local function OnClick()
			self.controller:PushPage(self.controller.PAGE_ICON_SELECT, OnSelect)
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Select"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.3)

		self.container:AddChild(widget)
	end
end
