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

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigIconSelectPage : BindingConfigPage
--- @field private onSelectCallback fun(targets: DataObject[], value: string)
Addon.BindingConfig.IconSelectPage = {
	keepTreeSelection = true
}

--- @protected
--- @param onSelectCallback fun(targets: DataObject[], value: string)
function Addon.BindingConfig.IconSelectPage:Show(onSelectCallback)
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

	self.onSelectCallback = onSelectCallback
end

--- @protected
function Addon.BindingConfig.IconSelectPage:Hide()
	self.onSelectCallback = nil
end

--- @protected
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
			self.onSelectCallback(self.targets, value)
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
