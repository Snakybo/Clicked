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

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--- @class Addon
local Addon = select(2, ...)

--- @class AddonOptions
local AddonOptions = {}

function AddonOptions:Initialize()
	AceConfig:RegisterOptionsTable("Clicked2", self:CreateOptionsTable())
	AceConfigDialog:AddToBlizOptions("Clicked2", Addon.L["Clicked2"])
end

--- @private
--- @return AceConfig.OptionsTable
function AddonOptions:CreateOptionsTable()
	local result = {
		type = "group",
		name = Addon.L["Clicked2"],
		args = {
			onKeyDown = {
				name = Addon.L["Cast on key down rather than key up"],
				desc = Addon.L["This option will make bindings trigger on the 'down' portion of a button press rather than the 'up' portion."],
				type = "toggle",
				order = 200,
				width = "full",
				set = function(_, val)
					Addon.db.profile.options.onKeyDown = val

					for _, frame in Addon.ClickCast:IterateFrames() do
						Addon.ClickCast:RegisterClicks(frame)
					end

					Addon.ClickCast:RegisterClicks(Addon.GlobalCast.frame)
					Clicked2:ProcessActiveBindings()

					Addon:ShowInformationPopup(Addon.L["If you are using custom unit frames you may have to adjust a setting within the unit frame configuration panel to enable support for this, and potentially even a UI reload."])
				end,
				get = function()
					return Addon.db.profile.options.onKeyDown
				end
			},
			bindUnassignedModifiers = {
				name = Addon.L["Bind unassigned modifier keys automatically"],
				desc = Addon.L["If enabled, modifier key combinations that aren't bound will be bound to the main key, for example, binding 'Q' will also bind 'SHIFT-Q', 'AlT-Q', and 'CTRL-Q'."],
				type = "toggle",
				order = 400,
				width = "full",
				set = function (_, val)
					Addon.db.profile.options.bindUnassignedModifiers = val
					Clicked2:ProcessActiveBindings()
				end,
				get = function ()
					return Addon.db.profile.options.bindUnassignedModifiers
				end
			},
			autoBindActionBar = {
				name = Addon.L["Automatically bind all action bar abilities"],
				desc = Addon.L["If enabled, all abilities on the action bar will automatically be appended to a binding on the same key, this will make Clicked fall back to the action bar when all other macro conditions are not met.\n\nNote that this only supports spells and items, not macros."],
				type = "toggle",
				order = 500,
				width = "full",
				set = function (_, val)
					Addon.db.profile.options.autoBindActionBar = val
					Clicked2:ProcessActiveBindings()
				end,
				get = function ()
					return Addon.db.profile.options.autoBindActionBar
				end
			},
			disableInHouse = {
				name = Addon.L["Disable bindings in house editor mode"],
				desc = Addon.L["If enabled, bindings will be disabled whilst in the house editor."],
				type = "toggle",
				order = 600,
				width = "full",
				hidden = Addon.EXPANSION < Addon.Expansion.TWW,
				set = function (_, val)
					Addon.db.profile.options.disableInHouse = val
					Addon:ReloadBindings("HOUSE_EDITOR_MODE_CHANGED")
				end,
				get = function ()
					return Addon.db.profile.options.disableInHouse
				end
			},
			logLevel = Mixin(Clicked2:GetLogLevelOptionObject(Addon.db.global), {
				order = 700
			})
		}
	}

	for _, module in Clicked2:IterateModules() do
		--- @cast module AceModule|AddonOptionsProvider
		local handler = module.GetAddonOptions

		if type(handler) == "function" then
			for key, option in pairs(handler(module)) do
				result.args[module.moduleName .. "_" .. key] = option
			end
		end
	end

	return result
end

Addon.AddonOptions = AddonOptions
