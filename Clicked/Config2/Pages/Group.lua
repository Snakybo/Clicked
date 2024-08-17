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

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigGroupPage : BindingConfigPage
--- @field public targets Group[]
Addon.BindingConfig.GroupPage = {
	keepTreeSelection = true
}

function Addon.BindingConfig.GroupPage:Redraw()
	local parent = Addon:GUI_InlineGroup()
	parent:SetTitle(Addon.L["Group Name and Icon"])
	self.container:AddChild(parent)

	-- name text field
	do
		-- TODO: Support multiple targets
		local widget = AceGUI:Create("EditBox") --[[@as AceGUIEditBox]]
		widget:SetText(self.targets[1].name)
		widget:SetFullWidth(true)
		widget:SetCallback("OnEnterPressed", function(_, _, value)
			self.targets[1].name = Addon:TrimString(value)
			widget:SetText(self.targets[1].name)
			widget:ClearFocus()
		end)

		parent:AddChild(widget)
	end

	-- icon field
	do
		local widget = AceGUI:Create("EditBox") --[[@as AceGUIEditBox]]
		widget:SetText(tostring(self.targets[1].displayIcon))
		widget:SetRelativeWidth(0.7)
		widget:SetCallback("OnEnterPressed", function(_, _, value)
			self.targets[1].displayIcon = value
			widget:ClearFocus()
		end)

		parent:AddChild(widget)
	end

	do
		local function OpenIconPicker()
			self.controller:PushPage(self.controller.PAGE_ICON_SELECT)
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Select"])
		widget:SetCallback("OnClick", OpenIconPicker)
		widget:SetRelativeWidth(0.3)

		parent:AddChild(widget)
	end
end
