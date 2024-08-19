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

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigMacroTab : BindingConfigTab
Addon.BindingConfig.BindingMacroTab = {}

function Addon.BindingConfig.BindingMacroTab:Redraw()

	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return binding.action.macroName
		end

		--- @param value string
		local function OnEnterPressed(_, _, value)
			value = string.trim(value)

			for _, binding in ipairs(self.bindings) do
				binding.action.macroName = value
			end

			Addon.BindingConfig.Window:RedrawTree()
		end

		local widget = AceGUI:Create("ClickedEditBox") --[[@as AceGUIEditBox]]
		widget:SetFullWidth(true)
		widget:SetCallback("OnEnterPressed", OnEnterPressed)

		Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Macro name"])

		self.container:AddChild(widget)
	end

	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return tostring(binding.action.macroIcon)
		end

		--- @param value string
		local function OnEnterPressed(_, _, value)
			value = string.trim(value)
			local id = tonumber(value)

			for _, binding in ipairs(self.bindings) do
				binding.action.macroIcon = id or value
			end

			Addon.BindingConfig.Window:RedrawTree()
		end

		local widget = AceGUI:Create("ClickedEditBox") --[[@as AceGUIEditBox]]
		widget:SetRelativeWidth(0.7)
		widget:SetCallback("OnEnterPressed", OnEnterPressed)

		Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Macro icon"])

		self.container:AddChild(widget)
	end

	do
		--- @param bindings Binding[]
		--- @param value string
		local function OnSelect(bindings, value)
			for _, binding in ipairs(bindings) do
				binding.action.macroIcon = value
			end

			Addon.BindingConfig.Window:RedrawTree()
		end

		local function OnClick()
			Addon.BindingConfig.Window:PushPage(Addon.BindingConfig.Window.PAGE_ICON_SELECT, OnSelect)
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Select"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.3)

		self.container:AddChild(widget)
	end

	do
		local hoverCastOnly = true

		for _, binding in ipairs(self.bindings) do
			if not binding.targets.hovercastEnabled and binding.targets.regularEnabled then
				hoverCastOnly = false
				break
			end
		end

		if hoverCastOnly then
			local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
			widget:SetText("\n" .. Addon.L["This macro will only execute when hovering over unit frames, in order to interact with the selected target use the [@mouseover] conditional."] .. "\n\n")
			widget:SetFullWidth(true)

			self.container:AddChild(widget)
		end
	end

	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return binding.action.macroValue
		end


		local function OnEnterPressed(_, _, value)
			value = string.trim(value)

			for _, binding in ipairs(self.bindings) do
				binding.action.macroValue = value
				Clicked:ReloadBinding(binding, true)
			end
		end

		local widget = AceGUI:Create("ClickedMultiLineEditBox") --[[@as AceGUIMultiLineEditBox]]
		widget:SetFullWidth(true)
		widget:SetFullHeight(true)
		widget:SetCallback("OnEnterPressed", OnEnterPressed)

		Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Macro text"])

		Addon.Media:UseMonoFont(widget)

		self.container:AddChild(widget)
	end
end
