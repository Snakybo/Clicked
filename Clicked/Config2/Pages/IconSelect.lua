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

local MEDIA_ADDON_NAME = "ClickedMedia"

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigIconSelectPage : BindingConfigPage
Addon.BindingConfig.IconSelectPage = {}

function Addon.BindingConfig.IconSelectPage:Show()
	if not C_AddOns.IsAddOnLoaded(MEDIA_ADDON_NAME) then
		local loaded, reason = C_AddOns.LoadAddOn(MEDIA_ADDON_NAME)

		if not loaded then
			if reason == "DISABLED" then
				C_AddOns.EnableAddOn(MEDIA_ADDON_NAME)
				C_AddOns.LoadAddOn(MEDIA_ADDON_NAME)
			else
				error("Unable to load " .. MEDIA_ADDON_NAME ": " .. reason)
			end
		end
	end
end

function Addon.BindingConfig.IconSelectPage:Redraw()
	--- @type ClickedSearchBox
	local searchBox

	do
		local widget = AceGUI:Create("ClickedSearchBox") --[[@as ClickedSearchBox]]
		widget:DisableButton(true)
		widget:SetPlaceholderText(Addon.L["Search..."])
		widget:SetRelativeWidth(0.75)
		searchBox = widget

		self.container:AddChild(widget)
	end

	do
		local function OnClick()
			self.controller:PopPage(self)
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Cancel"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.25)

		self.container:AddChild(widget)
	end

	do
		local function OnIconSelected(_, _, value)
			for _, target in ipairs(self.targets) do
				if target.type == Clicked.DataObjectType.BINDING then
					--- @cast target Binding
					if target.actionType == Addon.BindingTypes.MACRO then
						target.action.macroIcon = value
					end
				elseif target.type == Clicked.DataObjectType.GROUP then
					--- @cast target Group
					target.displayIcon = value
				end
			end

			self.controller:PopPage(self)
		end

		local scrollFrame = AceGUI:Create("ClickedIconSelectorList") --[[@as ClickedIconSelectorList]]
		scrollFrame:SetLayout("Flow")
		scrollFrame:SetFullWidth(true)
		scrollFrame:SetFullHeight(true)
		scrollFrame:SetIcons(ClickedMedia:GetIcons())
		scrollFrame:SetSearchHandler(searchBox)
		scrollFrame:SetCallback("OnIconSelected", OnIconSelected)

		self.container:AddChild(scrollFrame)
	end
end
