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

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")

--- @class ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

-- Private addon API

function Addon:GeneralOptions_Initialize()
	local config = {
		type = "group",
		name = L["Clicked"],
		args = {
			minimapIcon = {
				name = L["Enable minimap icon"],
				desc = L["Enable or disable the minimap icon."],
				type = "toggle",
				order = 100,
				width = "full",
				set = function(_, val)
					Addon.db.profile.options.minimap.hide = not val

					if val then
						LibDBIcon:Show("Clicked")
					else
						LibDBIcon:Hide("Clicked")
					end
				end,
				get = function(_)
					return not Addon.db.profile.options.minimap.hide
				end
			},
			onKeyDown = {
				name = L["Cast on key down rather than key up"],
				desc = L["This option will make bindings trigger on the 'down' portion of a button press rather than the 'up' portion."],
				type = "toggle",
				order = 200,
				width = "full",
				set = function(_, val)
					Addon.db.profile.options.onKeyDown = val

					for _, frame in Clicked:IterateClickCastFrames() do
						Clicked:RegisterFrameClicks(frame, true)
					end

					Clicked:RegisterFrameClicks(_G[Addon.MACRO_FRAME_HANDLER_NAME], false)
					Clicked:ReloadActiveBindings()

					Addon:ShowInformationPopup(L["If you are using custom unit frames you may have to adjust a setting within the unit frame configuration panel to enable support for this, and potentially even a UI reload."])
				end,
				get = function()
					return Addon.db.profile.options.onKeyDown
				end
			},
			tooltips = {
				name = L["Show abilities in unit tooltips"],
				desc = L["If enabled unit tooltips will be augmented to show abilities and keybinds that can be used on the target."],
				type = "toggle",
				order = 300,
				width = "full",
				set = function(_, val)
					Addon.db.profile.options.tooltips = val
				end,
				get = function()
					return Addon.db.profile.options.tooltips
				end
			}
		}
	}

	AceConfig:RegisterOptionsTable("Clicked", config)
	AceConfigDialog:AddToBlizOptions("Clicked", L["Clicked"])
end
