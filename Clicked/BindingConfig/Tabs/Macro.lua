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

--- @class BindingConfigMacroTab : BindingConfigTab
Addon.BindingConfig.BindingMacroTab = {}

--- @protected
function Addon.BindingConfig.BindingMacroTab:Redraw()
	-- macro name
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

	-- macro icon
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

	-- icon select button
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

	-- activate on
	do
		local items = {
			key = Addon.L["Key press"],
			unitframe = Addon.L["Unit frame"],
			all = Addon.L["Both"]
		}

		local order = { "key", "unitframe", "all" }

		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			if binding.actionType ~= Clicked.ActionType.MACRO then
				return Helpers.IGNORE_VALUE
			end

			if binding.targets.hovercastEnabled and binding.targets.regularEnabled then
				return items.all
			elseif binding.targets.hovercastEnabled then
				return items.unitframe
			else
				return items.key
			end
		end

		--- @param binding Binding
		--- @return string
		local function GetRawValue(binding)
			if binding.targets.hovercastEnabled and binding.targets.regularEnabled then
				return "all"
			elseif binding.targets.hovercastEnabled then
				return "unitframe"
			else
				return "key"
			end
		end

		--- @param value string
		local function OnValueChanged(_, _, value)
			for _, binding in ipairs(self.bindings) do
				binding.targets.regularEnabled = value == "key" or value == "all"
				binding.targets.hovercastEnabled = value == "unitframe" or value == "all"
				Addon:ReloadBinding(binding, "targets")
			end

			self.controller:RedrawTab()
		end

		local widget = AceGUI:Create("ClickedDropdown") --[[@as AceGUIDropdown]]
		widget:SetCallback("OnValueChanged", OnValueChanged)
		widget:SetList(items, order)
		widget:SetFullWidth(true)

		Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Activate on"], GetRawValue)

		self.container:AddChild(widget)
	end

	-- hovercast-only warning
	do
		local hide = FindInTableIf(self.bindings, function(binding)
			return binding.actionType ~= Clicked.ActionType.MACRO or Addon:IsMacroCastEnabled(binding)
		end)

		if not hide then
			local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
			widget:SetText("\n" .. Addon.L["This macro will only execute when hovering over unit frames, in order to interact with the selected target use the [@mouseover] conditional."] .. "\n")
			widget:SetFullWidth(true)

			self.container:AddChild(widget)
		end
	end

	-- append mode instructions
	do
		local hide = FindInTableIf(self.bindings, function(binding)
			return binding.actionType == Clicked.ActionType.MACRO
		end)

		if not hide then
			local msg = {
				Addon.L["This mode will directly append the macro text onto an automatically generated command generated by other bindings using the specified keybind. Generally, this means that it will be the last section of a '/cast' command."],
				Addon.L["With this mode you're not writing a macro command. You're adding parts to an already existing command, so writing '/cast Holy Light' will not work, in order to cast Holy Light simply type 'Holy Light'."]
			}

			local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
			widget:SetText("\n" .. table.concat(msg, "\n\n") .. "\n")
			widget:SetFullWidth(true)

			self.container:AddChild(widget)
		end
	end

	-- macro text
	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return binding.action.macroValue
		end


		--- @param value string
		local function OnEnterPressed(_, _, value)
			value = string.trim(value)

			for _, binding in ipairs(self.bindings) do
				binding.action.macroValue = value
				Addon:ReloadBinding(binding, "value")
			end
		end

		local widget = AceGUI:Create("ClickedMultiLineEditBox") --[[@as AceGUIMultiLineEditBox]]
		widget:SetFullWidth(true)
		widget:SetNumLines(10)
		widget:SetCallback("OnEnterPressed", OnEnterPressed)

		Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Macro text"])

		Addon.Media:UseMonoFont(widget)

		self.container:AddChild(widget)
	end
end
