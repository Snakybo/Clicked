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

local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

--- @class (partial) Addon
local Addon = select(2, ...)

--- @class MinimapModule : AceModule, LibLog-1.0.Logger, OptionMenuDriver
local Prototype = {}

--- @protected
function Prototype:OnInitialize()
	local iconData = LibDataBroker:NewDataObject("Clicked2", {
		type = "launcher",
		label = Addon.L["Clicked2"],
		icon = "Interface\\Icons\\inv_misc_punchcards_yellow",
		OnClick = function()
			Addon.BindingConfig.Window:Open()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(Addon.L["Clicked2"])
		end
	})

	LibDBIcon:Register(Addon.L["Clicked2"], iconData, Addon.db.profile.options.minimap)
	LibDBIcon:AddButtonToCompartment(Addon.L["Clicked2"])

	self:LogDebug("Initialized minimap module")
end

--- @param enabled boolean
function Prototype:SetMinimapButtonEnabled(enabled)
	self:LogDebug("Set minimap button visibility to {visible}", enabled)

	Addon.db.profile.options.minimap.hide = not enabled

	if enabled then
		LibDBIcon:Show(Addon.L["Clicked2"])
	else
		LibDBIcon:Hide(Addon.L["Clicked2"])
	end
end

--- @param enabled boolean
function Prototype:SetCompartmentButtonEnabled(enabled)
	self:LogDebug("Set addon compartment button visibility to {visible}", enabled)

	if enabled then
		LibDBIcon:AddButtonToCompartment(Addon.L["Clicked2"])
	else
		LibDBIcon:RemoveButtonFromCompartment(Addon.L["Clicked2"])
	end
end

--- @return string
--- @return string
function Prototype:GetOptionMenu()
	return "Clicked2", Addon.L["Clicked2"]
end

--- @return table<string, AceConfig.OptionsTable>
function Prototype:GetOptionTable()
	return {
		minimapIcon = {
			name = Addon.L["Enable minimap icon"],
			desc = Addon.L["Enable or disable the minimap icon."],
			type = "toggle",
			order = 100,
			width = "full",
			set = function(_, val)
				self:SetMinimapButtonEnabled(val)
			end,
			get = function(_)
				return self:IsMinimapButtonEnabled()
			end
		},
		addonCompartmentButton = {
			name = Addon.L["Enable addon compartment button"],
			desc = Addon.L["Enable or disable the addon compartment button."],
			type = "toggle",
			order = 101,
			width = "full",
			hidden = Addon.EXPANSION < Addon.Expansions.DF,
			set = function (_, val)
				self:SetCompartmentButtonEnabled(val)
			end,
			get = function()
				return self:IsCompartmentButtonEnabled()
			end
		}
	}
end

--- @return boolean
function Prototype:IsMinimapButtonEnabled()
	return not Addon.db.profile.options.minimap.hide
end

--- @return boolean
function Prototype:IsCompartmentButtonEnabled()
	return LibDBIcon:IsButtonInCompartment(Addon.L["Clicked2"])
end

Clicked2:NewModule("Minimap", Prototype)
