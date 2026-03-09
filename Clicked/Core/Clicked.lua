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

local AceConsole = LibStub("AceConsole-3.0")

--- @class SlashCommandHandler
--- @field public HandleSlashCommand fun(self: SlashCommandHandler, args: string[]): boolean

--- @class Addon
local Addon = select(2, ...)

--- Parse a chat command input and handle it appropriately.
---
--- @param input string The data of the chat command, excluding the first word
local function HandleChatCommand(input)
	--- @type string[]
	local args = {}
	local start = 1

	while true do
		local arg, next = AceConsole:GetArgs(input, 1, start)
		table.insert(args, arg)

		if next == 1e9 then
			break
		end

		start = next
	end

	for _, module in Clicked2:IterateModules() do
		if module.HandleSlashCommand ~= nil then
			--- @cast module SlashCommandHandler

			if module:HandleSlashCommand(args) then
				return
			end
		end
	end
	if #args == 1 then
		if args[1] == "opt" or args[1] == "options" then
			Addon:OpenSettingsMenu("Clicked2")
		elseif args[1] == "dump" then
			Addon:StatusOutput_Open()
		elseif (args[1] == "viz" or args[1] == "visualizer") then
			Addon.KeyVisualizer:Open()
		elseif args[1] == "ignore-self-cast-warning" then
			Addon.db.profile.options.ignoreSelfCastWarning = not Addon.db.profile.options.ignoreSelfCastWarning

			if Addon.db.profile.options.ignoreSelfCastWarning then
				Clicked2:LogInfo(Addon.L["Disabled self-cast warning, type this command again to re-enable it."])
			else
				Clicked2:LogInfo(Addon.L["Enabled self-cast warning, type this command again to disable it."])
			end
		end
	end
end

-- Public addon API

function Clicked2:OnInitialize()
	local defaultProfile = select(2, UnitClass("player"))

	Addon.db = LibStub("AceDB-3.0"):New("Clicked2DB", self:GetDatabaseDefaults(), defaultProfile)
	Addon.db.RegisterCallback(self, "OnProfileChanged", "ReloadDatabase")
	Addon.db.RegisterCallback(self, "OnProfileCopied", "ReloadDatabase")
	Addon.db.RegisterCallback(self, "OnProfileReset", "ReloadDatabase")

	self:SetLogLevelFromConfigTable(Addon.db.global)

	Addon:RegisterEventHandlers()
	Addon:UpgradeDatabase()

	AceConsole:RegisterChatCommand("clicked2", HandleChatCommand)
	AceConsole:RegisterChatCommand("cc2", HandleChatCommand)
end

function Clicked2:OnEnable()
--@debug@
	local projectUrl = "https://www.curseforge.com/wow/addons/clicked"
	self:LogWarning("You are using a development version, download the latest release from {url}", projectUrl)
--@end-debug@

	Addon.AddonOptions:Initialize()
	Addon.ProfileOptions:Initialize()
	Addon.BlacklistOptions:Initialize()
	Addon:StatusOutput_Initialize()
end

--- @param system string
--- @return LibLog-1.0.Logger
function Clicked2:CreateSystemLogger(system)
	return Clicked2:ForLogContext({
		system = system
	})
end

-- Private addon API

function Addon:RequestItemLoadForBindings()
	for _, binding in Clicked2:IterateConfiguredBindings() do
		if binding.actionType == Clicked2.ActionType.ITEM then
			local itemId = tonumber(binding.action.itemValue)

			if itemId ~= nil then
				C_Item.RequestLoadItemDataByID(itemId)
			end
		end
	end
end
